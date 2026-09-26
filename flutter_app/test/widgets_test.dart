import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kurir_atk/models/category.dart';
import 'package:kurir_atk/models/product.dart';
import 'package:kurir_atk/theme/app_theme.dart';
import 'package:kurir_atk/widgets/product_card.dart';
import 'package:kurir_atk/widgets/state_view.dart';

Product _product({int stock = 10}) => Product(
      id: 1,
      categoryId: 1,
      name: 'Pulpen Gel Hitam',
      sku: 'SKU-TEST',
      price: 12500,
      stock: stock,
      unit: 'pcs',
      isActive: true,
      category: ProductCategory(id: 1, name: 'Alat Tulis', slug: 'alat-tulis'),
    );

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: SizedBox(width: 180, height: kProductCardHeight, child: child))),
    );

void main() {
  testWidgets('ProductCard menampilkan nama, harga, kategori, dan stok', (tester) async {
    await tester.pumpWidget(_wrap(ProductCard(product: _product())));

    expect(find.text('Pulpen Gel Hitam'), findsOneWidget);
    expect(find.text('Rp12.500'), findsOneWidget);
    expect(find.text('ALAT TULIS'), findsOneWidget);
    expect(find.text('Stok 10 pcs'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProductCard menandai produk yang stoknya habis', (tester) async {
    await tester.pumpWidget(_wrap(ProductCard(product: _product(stock: 0))));

    expect(find.text('Stok Habis'), findsOneWidget);
    expect(find.text('Tidak tersedia'), findsOneWidget);
  });

  testWidgets('StateView memanggil aksi saat tombol ditekan', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: StateView(
          icon: Icons.inbox,
          title: 'Kosong',
          actionLabel: 'Coba Lagi',
          onAction: () => tapped = true,
        ),
      ),
    ));

    await tester.tap(find.text('Coba Lagi'));
    expect(tapped, isTrue);
  });
}
