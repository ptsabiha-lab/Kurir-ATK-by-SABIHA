<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Institution;
use Illuminate\Http\Request;

class InstitutionController extends Controller
{
    public function index()
    {
        return response()->json(Institution::paginate(20));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'type' => ['required', 'in:pemerintahan,swasta,pendidikan,lainnya'],
            'address' => ['required', 'string'],
            'phone' => ['nullable', 'string', 'max:20'],
            'contact_person' => ['nullable', 'string', 'max:255'],
        ]);

        $institution = Institution::create($validated);

        return response()->json($institution, 201);
    }

    public function show(Institution $institution)
    {
        return response()->json($institution);
    }

    public function update(Request $request, Institution $institution)
    {
        abort_unless($request->user()?->isAdmin(), 403, 'Hanya admin yang dapat melakukan aksi ini.');

        $validated = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'type' => ['sometimes', 'in:pemerintahan,swasta,pendidikan,lainnya'],
            'address' => ['sometimes', 'string'],
            'phone' => ['nullable', 'string', 'max:20'],
            'contact_person' => ['nullable', 'string', 'max:255'],
        ]);

        $institution->update($validated);

        return response()->json($institution);
    }

    public function destroy(Request $request, Institution $institution)
    {
        abort_unless($request->user()?->isAdmin(), 403, 'Hanya admin yang dapat melakukan aksi ini.');

        $institution->delete();

        return response()->json(['message' => 'Instansi berhasil dihapus.']);
    }
}
