<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Product;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $admin = User::create([
            'name' => 'Admin Kurir ATK',
            'email' => 'admin@kuriratk.test',
            'password' => Hash::make('password'),
            'role' => 'admin',
        ]);

        $kurir = User::create([
            'name' => 'Kurir Satu',
            'email' => 'kurir@kuriratk.test',
            'password' => Hash::make('password'),
            'role' => 'kurir',
        ]);

        $customer = User::create([
            'name' => 'Pelanggan Demo',
            'email' => 'customer@kuriratk.test',
            'password' => Hash::make('password'),
            'role' => 'customer',
        ]);

        $categories = [
            'Alat Tulis' => ['Pulpen', 'Pensil', 'Penghapus', 'Penggaris'],
            'Kertas' => ['Kertas A4', 'Kertas F4', 'Buku Tulis'],
            'Peralatan Kantor' => ['Stapler', 'Isi Stapler', 'Map Plastik', 'Lem'],
        ];

        foreach ($categories as $categoryName => $products) {
            $category = Category::create([
                'name' => $categoryName,
                'slug' => Str::slug($categoryName),
            ]);

            foreach ($products as $productName) {
                Product::create([
                    'category_id' => $category->id,
                    'name' => $productName,
                    'sku' => 'SKU-'.strtoupper(Str::random(8)),
                    'description' => "Produk {$productName} berkualitas untuk kebutuhan ATK.",
                    'price' => random_int(2000, 50000),
                    'stock' => random_int(50, 200),
                    'unit' => 'pcs',
                    'is_active' => true,
                ]);
            }
        }

        $this->command->info('Akun demo:');
        $this->command->info('Admin    : admin@kuriratk.test / password');
        $this->command->info('Kurir    : kurir@kuriratk.test / password');
        $this->command->info('Customer : customer@kuriratk.test / password');
    }
}
