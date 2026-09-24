<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Katalog ATK - Kurir ATK by SABIHA</title>
    <style>
        :root {
            --brand: #2563eb;
            --brand-dark: #1d4ed8;
            --bg: #f8fafc;
            --card: #ffffff;
            --border: #e2e8f0;
            --text: #0f172a;
            --muted: #64748b;
        }
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            background: var(--bg);
            color: var(--text);
        }
        header.site {
            background: var(--brand);
            color: white;
            padding: 24px 20px;
        }
        header.site h1 { margin: 0; font-size: 22px; }
        header.site p { margin: 4px 0 0; opacity: .9; font-size: 14px; }
        .container { max-width: 1100px; margin: 0 auto; padding: 24px 20px 60px; }
        .toolbar {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-bottom: 20px;
            align-items: center;
        }
        .search-form { display: flex; gap: 8px; flex: 1; min-width: 220px; }
        .search-form input {
            flex: 1;
            padding: 10px 14px;
            border: 1px solid var(--border);
            border-radius: 8px;
            font-size: 14px;
        }
        .search-form button, .btn {
            padding: 10px 16px;
            background: var(--brand);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
        }
        .search-form button:hover, .btn:hover { background: var(--brand-dark); }
        .categories { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 24px; }
        .categories a {
            padding: 6px 14px;
            border-radius: 999px;
            border: 1px solid var(--border);
            background: var(--card);
            color: var(--text);
            text-decoration: none;
            font-size: 13px;
        }
        .categories a.active { background: var(--brand); color: white; border-color: var(--brand); }
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 18px;
        }
        .card {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: 12px;
            overflow: hidden;
            display: flex;
            flex-direction: column;
        }
        .card .thumb {
            aspect-ratio: 4 / 3;
            background: linear-gradient(135deg, #dbeafe, #eff6ff);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 32px;
        }
        .card .body { padding: 14px; display: flex; flex-direction: column; gap: 6px; flex: 1; }
        .card .sku { font-size: 11px; color: var(--muted); text-transform: uppercase; letter-spacing: .05em; }
        .card h3 { margin: 0; font-size: 16px; }
        .card .category-badge {
            font-size: 12px;
            color: var(--brand);
            background: #eff6ff;
            padding: 2px 8px;
            border-radius: 999px;
            width: fit-content;
        }
        .card .desc { font-size: 13px; color: var(--muted); flex: 1; }
        .card .footer { display: flex; justify-content: space-between; align-items: center; margin-top: 8px; }
        .card .price { font-weight: 700; font-size: 16px; }
        .card .stock { font-size: 12px; color: var(--muted); }
        .empty { text-align: center; padding: 60px 20px; color: var(--muted); }
        .pagination { display: flex; justify-content: center; margin-top: 32px; }
        .pagination nav { display: flex; gap: 4px; flex-wrap: wrap; justify-content: center; }
    </style>
</head>
<body>
    <header class="site">
        <h1>Kurir ATK by SABIHA</h1>
        <p>Katalog Alat Tulis Kantor &mdash; pengadaan untuk instansi, sekolah, dan umum</p>
    </header>

    <div class="container">
        <div class="toolbar">
            <form class="search-form" method="GET" action="{{ route('catalog') }}">
                @if($selectedCategory)
                    <input type="hidden" name="category" value="{{ $selectedCategory }}">
                @endif
                <input type="text" name="q" value="{{ $search }}" placeholder="Cari produk ATK...">
                <button type="submit">Cari</button>
            </form>
        </div>

        <div class="categories">
            <a href="{{ route('catalog', ['q' => $search]) }}" class="{{ !$selectedCategory ? 'active' : '' }}">Semua</a>
            @foreach($categories as $category)
                <a href="{{ route('catalog', ['category' => $category->id, 'q' => $search]) }}"
                   class="{{ $selectedCategory === $category->id ? 'active' : '' }}">
                    {{ $category->name }}
                </a>
            @endforeach
        </div>

        @if($products->isEmpty())
            <div class="empty">Tidak ada produk yang ditemukan.</div>
        @else
            <div class="grid">
                @foreach($products as $product)
                    <div class="card">
                        <div class="thumb">📦</div>
                        <div class="body">
                            <span class="sku">{{ $product->sku }}</span>
                            <h3>{{ $product->name }}</h3>
                            @if($product->category)
                                <span class="category-badge">{{ $product->category->name }}</span>
                            @endif
                            <p class="desc">{{ $product->description }}</p>
                            <div class="footer">
                                <span class="price">Rp{{ number_format($product->price, 0, ',', '.') }}</span>
                                <span class="stock">Stok: {{ $product->stock }} {{ $product->unit }}</span>
                            </div>
                        </div>
                    </div>
                @endforeach
            </div>

            <div class="pagination">
                {{ $products->links() }}
            </div>
        @endif
    </div>
</body>
</html>
