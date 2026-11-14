import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/models/transaksi.dart';
import 'kas_view_model.dart';

const _background = Color(0xFF07152F);
const _surface = Color(0xFF102345);
const _muted = Color(0xFF9AAAC4);
const _mint = Color(0xFF5EE7E7);
const _coral = Color(0xFFFF7A85);

class TambahTransaksiScreen extends StatefulWidget {
  final KasViewModel viewModel;

  const TambahTransaksiScreen({super.key, required this.viewModel});

  @override
  State<TambahTransaksiScreen> createState() => _TambahTransaksiScreenState();
}

class _TambahTransaksiScreenState extends State<TambahTransaksiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _keteranganController = TextEditingController();
  final _nominalController = TextEditingController();
  JenisTransaksi _jenisTerpilih = JenisTransaksi.pemasukan;
  bool _sudahMencobaSimpan = false;

  bool get _isIncome => _jenisTerpilih == JenisTransaksi.pemasukan;
  Color get _accent => _isIncome ? _mint : _coral;

  double? _parseNominal(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final normalized = value.trim().replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  String _formatRupiah(double value) {
    final amount = value.round().toString();
    return 'Rp ${amount.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )}';
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    _nominalController.dispose();
    super.dispose();
  }

  void _simpanTransaksi() {
    _sudahMencobaSimpan = true;
    if (!_formKey.currentState!.validate()) return;

    final nominal = _parseNominal(_nominalController.text);
    if (nominal == null) return;

    final error = widget.viewModel.tambahTransaksi(
      keterangan: _keteranganController.text,
      nominal: nominal,
      jenis: _jenisTerpilih,
    );

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: const Color(0xFFD84E5B),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final nominal = _parseNominal(_nominalController.text) ?? 0;
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text(
          'Tambah transaksi',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    _buildIntroCard(),
                    const SizedBox(height: 25),
                    const Text(
                      'JENIS TRANSAKSI',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<JenisTransaksi>(
                      key: const Key('dropdown_jenis'),
                      initialValue: _jenisTerpilih,
                      dropdownColor: _surface,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Pilih kategori',
                        prefixIcon: Icon(
                          _isIncome
                              ? Icons.south_west_rounded
                              : Icons.north_east_rounded,
                          color: _accent,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: JenisTransaksi.pemasukan,
                          child: Text('Pemasukan'),
                        ),
                        DropdownMenuItem(
                          value: JenisTransaksi.pengeluaran,
                          child: Text('Pengeluaran'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _jenisTerpilih = value);
                        if (_sudahMencobaSimpan) {
                          _formKey.currentState?.validate();
                        }
                      },
                    ),
                    const SizedBox(height: 19),
                    const Text(
                      'DETAIL TRANSAKSI',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      key: const Key('field_keterangan'),
                      controller: _keteranganController,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      maxLength: 60,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Keterangan',
                        hintText: 'Contoh: Iuran bulanan anggota',
                        prefixIcon: Icon(Icons.notes_rounded, color: _muted),
                        counterStyle: TextStyle(color: _muted),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Keterangan wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      key: const Key('field_nominal'),
                      controller: _nominalController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Nominal',
                        hintText: '0',
                        prefixText: 'Rp ',
                        prefixIcon: Icon(Icons.payments_rounded, color: _muted),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nominal wajib diisi';
                        }
                        final parsed = _parseNominal(value);
                        if (parsed == null || !parsed.isFinite) {
                          return 'Nominal harus berupa angka valid';
                        }
                        if (parsed <= 0) {
                          return 'Nominal harus lebih dari 0';
                        }
                        if (_jenisTerpilih == JenisTransaksi.pengeluaran &&
                            parsed > widget.viewModel.saldo) {
                          return 'Pengeluaran melebihi saldo saat ini';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: _accent.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: _accent, size: 19),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              _isIncome
                                  ? 'Dana akan menambah saldo kas.'
                                  : 'Saldo tersedia ${_formatRupiah(widget.viewModel.saldo)}.',
                              style: const TextStyle(
                                color: Color(0xFFD0DDEE),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                decoration: BoxDecoration(
                  color: _background,
                  border: Border(
                    top:
                        BorderSide(color: Colors.white.withValues(alpha: 0.07)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'TOTAL TRANSAKSI',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: Text(
                              _formatRupiah(nominal),
                              key: ValueKey(nominal),
                              style: TextStyle(
                                color: _accent,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    FilledButton.icon(
                      key: const Key('btn_simpan'),
                      onPressed: _simpanTransaksi,
                      style: FilledButton.styleFrom(
                        backgroundColor: _mint,
                        foregroundColor: _background,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      icon: const Icon(Icons.check_rounded, size: 19),
                      label: const Text(
                        'Simpan',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF183D66), Color(0xFF102345)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              _isIncome ? Icons.add_chart_rounded : Icons.shopping_bag_outlined,
              color: _accent,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Catat dengan rapi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isIncome
                      ? 'Tambahkan dana masuk ke kas himpunan.'
                      : 'Catat pengeluaran agar saldo tetap terpantau.',
                  style: const TextStyle(
                    color: Color(0xFFC1D3E8),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
