import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nusa_kas/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'Alur E2E: Menambah pemasukan dan pengeluaran lalu memeriksa saldo akhir',
      (tester) async {
    await tester.pumpWidget(NusaKasApp());
    await tester.pumpAndSettle();

    // Verifikasi saldo awal Rp 0
    expect(find.text('Rp 0'), findsWidgets);

    // 1. Tambah Transaksi Pemasukan: Rp 200.000
    await tester.tap(find.byKey(const Key('btn_tambah_transaksi')));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('field_keterangan')), 'Dana Hibah Kampus');
    await tester.enterText(find.byKey(const Key('field_nominal')), '200000');
    await tester.tap(find.byKey(const Key('btn_simpan')));
    await tester.pumpAndSettle();

    // Pastikan kembali ke HomeScreen dan saldo menjadi Rp 200.000
    expect(find.text('Dana Hibah Kampus'), findsOneWidget);
    expect(find.text('Rp 200.000'), findsWidgets);

    // 2. Tambah Transaksi Pengeluaran: Rp 75.000
    await tester.tap(find.byKey(const Key('btn_tambah_transaksi')));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('field_keterangan')), 'Konsumsi Seminar');
    await tester.enterText(find.byKey(const Key('field_nominal')), '75000');

    // Pilih jenis Pengeluaran
    await tester.tap(find.byKey(const Key('dropdown_jenis')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pengeluaran').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('btn_simpan')));
    await tester.pumpAndSettle();

    // 3. Verifikasi saldo akhir = 200.000 - 75.000 = Rp 125.000
    expect(find.text('Konsumsi Seminar'), findsOneWidget);
    expect(find.text('Rp 125.000'), findsOneWidget);
    expect(find.text('Rp 75.000'), findsOneWidget);
  });
}