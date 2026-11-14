import 'package:flutter_test/flutter_test.dart';
import 'package:nusa_kas/domain/kas_calculator.dart';
import 'package:nusa_kas/domain/models/transaksi.dart';

void main() {
  late KasCalculator calculator;

  setUp(() {
    calculator = KasCalculator();
  });

  group('KasCalculator Unit Tests', () {
    test('1. Daftar transaksi kosong menghasilkan saldo, pemasukan, dan pengeluaran 0', () {
      final daftarKosong = <Transaksi>[];

      expect(calculator.totalPemasukan(daftarKosong), 0.0);
      expect(calculator.totalPengeluaran(daftarKosong), 0.0);
      expect(calculator.hitungSaldo(daftarKosong), 0.0);
    });

    test('2. Menghitung total pemasukan dengan benar', () {
      final list = [
        Transaksi(
          id: '1',
          keterangan: 'Iuran Anggota',
          nominal: 50000,
          jenis: JenisTransaksi.pemasukan,
          tanggal: DateTime(2026, 11, 1),
        ),
        Transaksi(
          id: '2',
          keterangan: 'Dana Usaha',
          nominal: 150000,
          jenis: JenisTransaksi.pemasukan,
          tanggal: DateTime(2026, 11, 2),
        ),
      ];

      expect(calculator.totalPemasukan(list), 200000.0);
    });

    test('3. Menghitung total pengeluaran dengan benar', () {
      final list = [
        Transaksi(
          id: '1',
          keterangan: 'Print Proposal',
          nominal: 25000,
          jenis: JenisTransaksi.pengeluaran,
          tanggal: DateTime(2026, 11, 3),
        ),
        Transaksi(
          id: '2',
          keterangan: 'Konsumsi Rapat',
          nominal: 45000,
          jenis: JenisTransaksi.pengeluaran,
          tanggal: DateTime(2026, 11, 4),
        ),
      ];

      expect(calculator.totalPengeluaran(list), 70000.0);
    });

    test('4. Menghitung saldo akhir dari kombinasi pemasukan dan pengeluaran', () {
      final list = [
        Transaksi(
          id: '1',
          keterangan: 'Kas Awal',
          nominal: 300000,
          jenis: JenisTransaksi.pemasukan,
          tanggal: DateTime(2026, 11, 1),
        ),
        Transaksi(
          id: '2',
          keterangan: 'Beli Spanduk',
          nominal: 120000,
          jenis: JenisTransaksi.pengeluaran,
          tanggal: DateTime(2026, 11, 5),
        ),
      ];

      expect(calculator.hitungSaldo(list), 180000.0);
    });

    test('5. Menolak transaksi dengan nominal nol (0)', () {
      final error = calculator.validasiTransaksi(
        nominal: 0,
        jenis: JenisTransaksi.pemasukan,
        saldoSaatIni: 100000,
      );

      expect(error, isNotNull);
      expect(error, contains('lebih dari 0'));
    });

    test('6. Menolak transaksi dengan nominal negatif', () {
      final error = calculator.validasiTransaksi(
        nominal: -50000,
        jenis: JenisTransaksi.pemasukan,
        saldoSaatIni: 100000,
      );

      expect(error, isNotNull);
      expect(error, contains('lebih dari 0'));
    });

    test('7. Menolak pengeluaran yang melebihi saldo saat ini', () {
      final error = calculator.validasiTransaksi(
        nominal: 150000,
        jenis: JenisTransaksi.pengeluaran,
        saldoSaatIni: 100000,
      );

      expect(error, isNotNull);
      expect(error, contains('melebihi saldo'));
    });

    test('8. Nilai batas: menerima pengeluaran yang tepat sama dengan saldo (saldo menjadi 0)', () {
      final error = calculator.validasiTransaksi(
        nominal: 100000,
        jenis: JenisTransaksi.pengeluaran,
        saldoSaatIni: 100000,
      );

      expect(error, isNull);

      final list = [
        Transaksi(
          id: '1',
          keterangan: 'Pemasukan',
          nominal: 100000,
          jenis: JenisTransaksi.pemasukan,
          tanggal: DateTime(2026, 11, 1),
        ),
        Transaksi(
          id: '2',
          keterangan: 'Pengeluaran Habis',
          nominal: 100000,
          jenis: JenisTransaksi.pengeluaran,
          tanggal: DateTime(2026, 11, 2),
        ),
      ];
      expect(calculator.hitungSaldo(list), 0.0);
    });

    test('9. Menerima pemasukan dalam jumlah besar tanpa batas saldo', () {
      final error = calculator.validasiTransaksi(
        nominal: 5000000,
        jenis: JenisTransaksi.pemasukan,
        saldoSaatIni: 0,
      );

      expect(error, isNull);
    });
  });
}