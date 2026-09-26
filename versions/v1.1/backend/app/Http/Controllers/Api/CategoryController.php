<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class CategoryController extends Controller
{
    public function index()
    {
        return response()->json(Category::withCount('products')->get());
    }

    public function store(Request $request)
    {
        abort_unless($request->user()?->isAdmin(), 403, 'Hanya admin yang dapat melakukan aksi ini.');

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
        ]);

        $category = Category::create([
            'name' => $validated['name'],
            'slug' => Str::slug($validated['name']),
        ]);

        return response()->json($category, 201);
    }

    public function show(Category $category)
    {
        return response()->json($category->load('products'));
    }

    public function update(Request $request, Category $category)
    {
        abort_unless($request->user()?->isAdmin(), 403, 'Hanya admin yang dapat melakukan aksi ini.');

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
        ]);

        $category->update([
            'name' => $validated['name'],
            'slug' => Str::slug($validated['name']),
        ]);

        return response()->json($category);
    }

    public function destroy(Request $request, Category $category)
    {
        abort_unless($request->user()?->isAdmin(), 403, 'Hanya admin yang dapat melakukan aksi ini.');

        $category->delete();

        return response()->json(['message' => 'Kategori berhasil dihapus.']);
    }
}
