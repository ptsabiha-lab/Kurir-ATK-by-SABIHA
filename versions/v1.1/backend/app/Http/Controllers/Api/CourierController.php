<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class CourierController extends Controller
{
    /**
     * Daftar kurir yang dapat ditugaskan (khusus admin).
     */
    public function index(Request $request)
    {
        abort_unless($request->user()->isAdmin(), 403, 'Hanya admin yang dapat melihat daftar kurir.');

        return response()->json(
            User::where('role', 'kurir')->orderBy('name')->get(['id', 'name', 'email', 'phone'])
        );
    }
}
