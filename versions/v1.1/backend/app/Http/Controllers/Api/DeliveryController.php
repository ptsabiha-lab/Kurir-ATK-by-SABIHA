<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Delivery;
use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class DeliveryController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $query = Delivery::with(['order.items.product', 'kurir']);

        if ($user->isKurir()) {
            $query->where('kurir_id', $user->id);
        } elseif (! $user->isAdmin()) {
            $query->whereHas('order', fn ($q) => $q->where('user_id', $user->id));
        }

        return response()->json($query->latest()->paginate(20));
    }

    public function store(Request $request)
    {
        abort_unless($request->user()->isAdmin(), 403, 'Hanya admin yang dapat menugaskan pengiriman.');

        $validated = $request->validate([
            'order_id' => ['required', 'exists:orders,id', 'unique:deliveries,order_id'],
            'kurir_id' => ['required', Rule::exists('users', 'id')->where('role', 'kurir')],
            'notes' => ['nullable', 'string'],
        ]);

        $order = Order::findOrFail($validated['order_id']);

        if ($order->status === 'cancelled') {
            throw ValidationException::withMessages([
                'order_id' => 'Pesanan yang sudah dibatalkan tidak dapat dikirim.',
            ]);
        }

        $delivery = Delivery::create([
            'order_id' => $validated['order_id'],
            'kurir_id' => $validated['kurir_id'],
            'status' => 'assigned',
            'tracking_number' => 'TRK-'.now()->format('Ymd').'-'.strtoupper(Str::random(8)),
            'notes' => $validated['notes'] ?? null,
        ]);

        if (in_array($order->status, ['pending', 'confirmed'], true)) {
            $order->update(['status' => 'processing']);
        }

        return response()->json($delivery->load(['order', 'kurir']), 201);
    }

    public function show(Request $request, Delivery $delivery)
    {
        abort_unless(
            $request->user()->isAdmin() || $delivery->kurir_id === $request->user()->id || $delivery->order->user_id === $request->user()->id,
            403
        );

        return response()->json($delivery->load(['order.items.product', 'kurir']));
    }

    public function update(Request $request, Delivery $delivery)
    {
        abort_unless(
            $request->user()->isAdmin() || $delivery->kurir_id === $request->user()->id,
            403,
            'Hanya admin atau kurir yang ditugaskan yang dapat mengubah status.'
        );

        $validated = $request->validate([
            'status' => ['required', 'in:assigned,picked_up,in_transit,delivered,failed'],
            'notes' => ['nullable', 'string'],
        ]);

        $delivery->update([
            'status' => $validated['status'],
            'notes' => $validated['notes'] ?? $delivery->notes,
            'delivered_at' => $validated['status'] === 'delivered' ? now() : $delivery->delivered_at,
        ]);

        if ($validated['status'] === 'delivered') {
            $delivery->order->update(['status' => 'delivered']);
        } elseif ($validated['status'] === 'in_transit') {
            $delivery->order->update(['status' => 'shipped']);
        }

        return response()->json($delivery->fresh(['order.items.product', 'kurir']));
    }
}
