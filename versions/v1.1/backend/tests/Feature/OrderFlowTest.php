<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class OrderFlowTest extends TestCase
{
    use RefreshDatabase;

    private Product $product;

    protected function setUp(): void
    {
        parent::setUp();

        $category = Category::create(['name' => 'Kertas', 'slug' => 'kertas']);

        $this->product = Product::create([
            'category_id' => $category->id,
            'name' => 'Kertas A4',
            'sku' => 'SKU-A4',
            'price' => 55000,
            'stock' => 10,
            'unit' => 'rim',
        ]);
    }

    private function placeOrder(User $customer, int $quantity = 3): Order
    {
        Sanctum::actingAs($customer);

        $response = $this->postJson('/api/orders', [
            'shipping_address' => 'Jl. Merdeka No. 1',
            'items' => [['product_id' => $this->product->id, 'quantity' => $quantity]],
        ])->assertCreated();

        return Order::findOrFail($response->json('id'));
    }

    public function test_customer_can_place_order_and_stock_is_reduced(): void
    {
        $order = $this->placeOrder(User::factory()->create(['role' => 'customer']));

        $this->assertSame('pending', $order->status);
        $this->assertSame(165000, (int) $order->total_price);
        $this->assertSame(7, $this->product->fresh()->stock);
    }

    public function test_order_is_rejected_when_stock_is_insufficient(): void
    {
        Sanctum::actingAs(User::factory()->create(['role' => 'customer']));

        $this->postJson('/api/orders', [
            'shipping_address' => 'Jl. Merdeka No. 1',
            'items' => [['product_id' => $this->product->id, 'quantity' => 11]],
        ])->assertUnprocessable();

        $this->assertSame(10, $this->product->fresh()->stock);
    }

    public function test_customer_cancelling_pending_order_restores_stock(): void
    {
        $customer = User::factory()->create(['role' => 'customer']);
        $order = $this->placeOrder($customer);

        $this->deleteJson("/api/orders/{$order->id}")->assertOk();

        $this->assertSame('cancelled', $order->fresh()->status);
        $this->assertSame(10, $this->product->fresh()->stock);
    }

    public function test_customer_cannot_cancel_another_customers_order(): void
    {
        $order = $this->placeOrder(User::factory()->create(['role' => 'customer']));

        Sanctum::actingAs(User::factory()->create(['role' => 'customer']));
        $this->deleteJson("/api/orders/{$order->id}")->assertForbidden();
    }

    public function test_cancelled_order_cannot_be_reopened(): void
    {
        $order = $this->placeOrder(User::factory()->create(['role' => 'customer']));

        Sanctum::actingAs(User::factory()->create(['role' => 'admin']));
        $this->putJson("/api/orders/{$order->id}", ['status' => 'cancelled'])->assertOk();
        $this->putJson("/api/orders/{$order->id}", ['status' => 'confirmed'])->assertUnprocessable();

        $this->assertSame(10, $this->product->fresh()->stock);
    }

    public function test_only_admin_can_list_couriers(): void
    {
        $kurir = User::factory()->create(['role' => 'kurir']);

        Sanctum::actingAs(User::factory()->create(['role' => 'customer']));
        $this->getJson('/api/couriers')->assertForbidden();

        Sanctum::actingAs(User::factory()->create(['role' => 'admin']));
        $this->getJson('/api/couriers')->assertOk()->assertJsonCount(1)->assertJsonPath('0.id', $kurir->id);
    }

    public function test_full_delivery_flow_updates_order_status(): void
    {
        $order = $this->placeOrder(User::factory()->create(['role' => 'customer']));
        $kurir = User::factory()->create(['role' => 'kurir']);

        Sanctum::actingAs(User::factory()->create(['role' => 'admin']));
        $deliveryId = $this->postJson('/api/deliveries', [
            'order_id' => $order->id,
            'kurir_id' => $kurir->id,
        ])->assertCreated()->json('id');

        $this->assertSame('processing', $order->fresh()->status);

        Sanctum::actingAs($kurir);
        $this->getJson('/api/deliveries')->assertOk()->assertJsonPath('data.0.id', $deliveryId);

        $this->putJson("/api/deliveries/{$deliveryId}", ['status' => 'in_transit'])->assertOk();
        $this->assertSame('shipped', $order->fresh()->status);

        $this->putJson("/api/deliveries/{$deliveryId}", ['status' => 'delivered'])->assertOk();
        $this->assertSame('delivered', $order->fresh()->status);
    }

    public function test_delivery_cannot_be_assigned_to_non_courier(): void
    {
        $order = $this->placeOrder(User::factory()->create(['role' => 'customer']));
        $notKurir = User::factory()->create(['role' => 'customer']);

        Sanctum::actingAs(User::factory()->create(['role' => 'admin']));
        $this->postJson('/api/deliveries', [
            'order_id' => $order->id,
            'kurir_id' => $notKurir->id,
        ])->assertUnprocessable();
    }
}
