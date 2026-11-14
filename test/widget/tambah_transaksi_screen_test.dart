import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nusa_kas/domain/models/transaksi.dart';
import 'package:nusa_kas/ui/kas/kas_view_model.dart';
import 'package:nusa_kas/ui/kas/tambah_transaksi_screen.dart';

void main() {
  late KasViewModel viewModel;

  setUp(() {
    viewModel = KasViewModel();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: TambahTransaksiScreen(viewModel: viewModel),
    );
  }

  group('TambahTransaksiScreen Widget Tests', () {
    testWidgets('1. Menampilkan pesan error validasi ketika form kosong disubmit',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byKey(const Key('btn_simpan')));
      await tester.pumpAndSettle();

      expect(find.text('Keterangan wajib diisi'), findsOneWidget);
      expect(find.text('Nominal wajib diisi'), findsOneWidget);
      expect(viewModel.daftarTransaksi, isEmpty);
    });

    testWidgets('2. Menolak pengeluaran yang melebihi saldo saat ini di form',
        (tester) async {
      // Saldo awal 50.000
      viewModel.tambahTransaksi(
        keterangan: 'Kas Awal',
        nominal: 50000,
        jenis: JenisTransaksi.pemasukan,
      );

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
          find.byKey(const Key('field_keterangan')), 'Beli Proyektor');
      await tester.enterText(
          find.byKey(const Key('field_nominal')), '100000');

      // Ubah dropdown ke Pengeluaran
      await tester.tap(find.byKey(const Key('dropdown_jenis')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pengeluaran').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn_simpan')));
      await tester.pumpAndSettle();

      expect(find.text('Pengeluaran melebihi saldo saat ini'), findsOneWidget);
      expect(viewModel.saldo, 50000.0);
    });

    testWidgets('3. Berhasil menyimpan transaksi pemasukan yang valid',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
          find.byKey(const Key('field_keterangan')), 'Iuran Bulanan');
      await tester.enterText(find.byKey(const Key('field_nominal')), '75000');

      await tester.tap(find.byKey(const Key('btn_simpan')));
      await tester.pumpAndSettle();

      expect(viewModel.daftarTransaksi.length, 1);
      expect(viewModel.daftarTransaksi.first.keterangan, 'Iuran Bulanan');
      expect(viewModel.saldo, 75000.0);
    });
  });
}