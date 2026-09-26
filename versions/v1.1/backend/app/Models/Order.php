<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Support\Facades\DB;

#[Fillable(['order_number', 'user_id', 'institution_id', 'status', 'total_price', 'shipping_address', 'notes'])]
class Order extends Model
{
    use HasFactory;

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function institution(): BelongsTo
    {
        return $this->belongsTo(Institution::class);
    }

    public function items(): HasMany
    {
        return $this->hasMany(OrderItem::class);
    }

    public function delivery(): HasOne
    {
        return $this->hasOne(Delivery::class);
    }

    public function isCancellable(): bool
    {
        return in_array($this->status, ['pending', 'confirmed'], true);
    }

    /**
     * Batalkan pesanan dan kembalikan stok setiap produk di dalamnya.
     */
    public function cancel(): void
    {
        DB::transaction(function () {
            foreach ($this->items()->with('product')->get() as $item) {
                $item->product?->increment('stock', $item->quantity);
            }

            $this->update(['status' => 'cancelled']);
        });
    }
}
