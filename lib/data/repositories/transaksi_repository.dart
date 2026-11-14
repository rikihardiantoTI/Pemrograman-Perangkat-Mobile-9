import '../../domain/models/transaksi.dart';

class TransaksiRepository {
  final List<Transaksi> _transaksiList = [];

  List<Transaksi> getAll() {
    return List.unmodifiable(_transaksiList);
  }

  void add(Transaksi transaksi) {
    _transaksiList.insert(0, transaksi);
  }

  void restore(Transaksi transaksi) {
    if (_transaksiList.any((item) => item.id == transaksi.id)) return;
    _transaksiList.add(transaksi);
    _transaksiList.sort((a, b) => b.tanggal.compareTo(a.tanggal));
  }

  Transaksi? removeById(String id) {
    final index = _transaksiList.indexWhere((item) => item.id == id);
    if (index == -1) return null;
    return _transaksiList.removeAt(index);
  }

  void deleteById(String id) {
    removeById(id);
  }
}
