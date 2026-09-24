<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class OrderController extends Controller
{
    public function index(Request $request)
    {
        $query = Order::with(['items.product', 'institution']);

        if (! $request->user()->isAdmin()) {
            $query->where('user_id', $request->user()->id);
        }

        return response()->json($query->latest()->paginate(20));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'institution_id' => ['nullable', 'exists:institutions,id'],
            'shipping_address' => ['required', 'string'],
            'notes' => ['nullable', 'string'],
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['required', 'exists:products,id'],
            'items.*.quantity' => ['required', 'integer', 'min:1'],
        ]);

        $order = DB::transaction(function () use ($validated, $request) {
            $totalPrice = 0;
            $itemsData = [];

            foreach ($validated['items'] as $item) {
                $product = Product::lockForUpdate()->findOrFail($item['product_id']);

                if ($product->stock < $item['quantity']) {
                    throw ValidationException::withMessages([
                        'items' => "Stok produk \"{$product->name}\" tidak mencukupi (tersisa {$product->stock}).",
                    ]);
                }

                $subtotal = $product->price * $item['quantity'];
                $totalPrice += $subtotal;

                $itemsData[] = [
                    'product' => $product,
                    'quantity' => $item['quantity'],
                    'price' => $product->price,
                    'subtotal' => $subtotal,
                ];
            }

            $order = Order::create([
                'order_number' => 'ATK-'.now()->format('Ymd').'-'.strtoupper(Str::random(6)),
                'user_id' => $request->user()->id,
                'institution_id' => $validated['institution_id'] ?? null,
                'status' => 'pending',
                'total_price' => $totalPrice,
                'shipping_address' => $validated['shipping_address'],
                'notes' => $validated['notes'] ?? null,
            ]);

            foreach ($itemsData as $data) {
                $order->items()->create([
                    'product_id' => $data['product']->id,
                    'quantity' => $data['quantity'],
                    'price' => $data['price'],
                    'subtotal' => $data['subtotal'],
                ]);

                $data['product']->decrement('stock', $data['quantity']);
            }

            return $order;
        });

        return response()->json($order->load('items.product'), 201);
    }

    public function show(Request $request, Order $order)
    {
        abort_unless($request->user()->isAdmin() || $order->user_id === $request->user()->id, 403);

        return response()->json($order->load(['items.product', 'institution', 'delivery']));
    }

    public function update(Request $request, Order $order)
    {
        abort_unless($request->user()->isAdmin(), 403, 'Hanya admin yang dapat mengubah status pesanan.');

        $validated = $request->validate([
            'status' => ['required', 'in:pending,confirmed,processing,shipped,delivered,cancelled'],
        ]);

        $order->update($validated);

        return response()->json($order);
    }

    public function destroy(Request $request, Order $order)
    {
        abort_unless($request->user()->isAdmin() || ($order->user_id === $request->user()->id && $order->status === 'pending'), 403);

        $order->delete();

        return response()->json(['message' => 'Pesanan berhasil dibatalkan.']);
    }
}
