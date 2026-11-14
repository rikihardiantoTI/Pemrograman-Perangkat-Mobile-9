import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nusa_kas/data/repositories/transaksi_repository.dart';
import 'package:nusa_kas/domain/models/transaksi.dart';
import 'package:nusa_kas/ui/kas/home_screen.dart';
import 'package:nusa_kas/ui/kas/kas_view_model.dart';

void main() {
  late KasViewModel viewModel;

  setUp(() {
    final now = DateTime.now();
    final previousMonth = DateTime(now.year, now.month - 1, 12);
    final repository = TransaksiRepository()
      ..add(
        Transaksi(
          id: 'this-month',
          keterangan: 'Iuran kegiatan',
          nominal: 150000,
          jenis: JenisTransaksi.pemasukan,
          tanggal: now,
        ),
      )
      ..add(
        Transaksi(
          id: 'previous-month',
          keterangan: 'Dana bulan lalu',
          nominal: 50000,
          jenis: JenisTransaksi.pemasukan,
          tanggal: previousMonth,
        ),
      );
    viewModel = KasViewModel(repository: repository);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(home: HomeScreen(viewModel: viewModel));
  }

  testWidgets('filter bulan ini hanya menampilkan transaksi bulan berjalan',
      (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Iuran kegiatan'), findsOneWidget);
    expect(find.text('Dana bulan lalu'), findsOneWidget);
    expect(find.text('ARUS KAS BULAN INI'), findsOneWidget);

    await tester.tap(find.text('Bulan ini'));
    await tester.pumpAndSettle();

    expect(find.text('Iuran kegiatan'), findsOneWidget);
    expect(find.text('Dana bulan lalu'), findsNothing);
  });

  testWidgets('tampilan kosong tetap muat di area layar pendek',
      (tester) async {
    viewModel = KasViewModel();

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Belum ada transaksi'), findsOneWidget);
    expect(find.text('Tambah transaksi pertama untuk mulai.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('transaksi yang dihapus dapat dipulihkan dari notifikasi',
      (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final transactionFinder = find.byKey(const Key('dismiss_this-month'));
    await tester.ensureVisible(transactionFinder);
    await tester.pumpAndSettle();
    await tester.drag(transactionFinder, const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(viewModel.daftarTransaksi.any((item) => item.id == 'this-month'),
        isFalse);
    expect(find.text('URUNGKAN'), findsOneWidget);

    await tester.tap(find.text('URUNGKAN'));
    await tester.pumpAndSettle();

    expect(viewModel.daftarTransaksi.any((item) => item.id == 'this-month'),
        isTrue);
    expect(find.text('Iuran kegiatan'), findsOneWidget);
  });

  testWidgets('laporan CSV menampilkan pratinjau transaksi', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('btn_ekspor_csv')));
    await tester.pumpAndSettle();

    expect(find.text('Ekspor laporan CSV'), findsOneWidget);
    expect(find.textContaining('Tanggal,Keterangan,Jenis,Nominal (Rp)'),
        findsOneWidget);
    expect(find.byKey(const Key('btn_salin_csv')), findsOneWidget);
  });
}
