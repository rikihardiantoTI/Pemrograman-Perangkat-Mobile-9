import 'package:flutter/foundation.dart';

import '../../data/repositories/transaksi_repository.dart';
import '../../domain/kas_calculator.dart';
import '../../domain/models/transaksi.dart';

class KasViewModel extends ChangeNotifier {
  final TransaksiRepository _repository;
  final KasCalculator _calculator;

  KasViewModel({
    TransaksiRepository? repository,
    KasCalculator? calculator,
  })  : _repository = repository ?? TransaksiRepository(),
        _calculator = calculator ?? KasCalculator();

  List<Transaksi> get daftarTransaksi => _repository.getAll();

  double get totalPemasukan => _calculator.totalPemasukan(daftarTransaksi);

  double get totalPengeluaran => _calculator.totalPengeluaran(daftarTransaksi);

  double get saldo => _calculator.hitungSaldo(daftarTransaksi);

  String? validasiInput({
    required double nominal,
    required JenisTransaksi jenis,
  }) {
    return _calculator.validasiTransaksi(
      nominal: nominal,
      jenis: jenis,
      saldoSaatIni: saldo,
    );
  }

  String? tambahTransaksi({
    required String keterangan,
    required double nominal,
    required JenisTransaksi jenis,
  }) {
    final normalizedKeterangan = keterangan.trim();
    if (normalizedKeterangan.isEmpty) {
      return 'Keterangan wajib diisi';
    }

    final error = validasiInput(nominal: nominal, jenis: jenis);
    if (error != null) return error;

    final waktuSekarang = DateTime.now();
    _repository.add(
      Transaksi(
        id: waktuSekarang.microsecondsSinceEpoch.toString(),
        keterangan: normalizedKeterangan,
        nominal: nominal,
        jenis: jenis,
        tanggal: waktuSekarang,
      ),
    );
    notifyListeners();
    return null;
  }

  Transaksi? hapusTransaksi(String id) {
    final deleted = _repository.removeById(id);
    if (deleted == null) return null;
    notifyListeners();
    return deleted;
  }

  void pulihkanTransaksi(Transaksi transaksi) {
    _repository.restore(transaksi);
    notifyListeners();
  }
}
