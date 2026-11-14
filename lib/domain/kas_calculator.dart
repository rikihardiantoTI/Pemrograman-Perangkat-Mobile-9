import 'models/transaksi.dart';

class KasCalculator {
  double totalPemasukan(List<Transaksi> transaksi) {
    return transaksi
        .where((item) => item.jenis == JenisTransaksi.pemasukan)
        .fold(0, (total, item) => total + item.nominal);
  }

  double totalPengeluaran(List<Transaksi> transaksi) {
    return transaksi
        .where((item) => item.jenis == JenisTransaksi.pengeluaran)
        .fold(0, (total, item) => total + item.nominal);
  }

  double hitungSaldo(List<Transaksi> transaksi) {
    return totalPemasukan(transaksi) - totalPengeluaran(transaksi);
  }

  String? validasiTransaksi({
    required double nominal,
    required JenisTransaksi jenis,
    required double saldoSaatIni,
  }) {
    if (!nominal.isFinite || nominal <= 0) {
      return 'Nominal harus lebih dari 0';
    }

    if (jenis == JenisTransaksi.pengeluaran && nominal > saldoSaatIni) {
      return 'Pengeluaran melebihi saldo saat ini';
    }

    return null;
  }
}
