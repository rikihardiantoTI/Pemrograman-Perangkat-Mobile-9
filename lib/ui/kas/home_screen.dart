import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../../domain/models/transaksi.dart';
import 'kas_view_model.dart';
import 'tambah_transaksi_screen.dart';

const _background = Color(0xFF07152F);
const _surface = Color(0xFF102345);
const _muted = Color(0xFF9AAAC4);
const _mint = Color(0xFF5EE7E7);
const _coral = Color(0xFFFF7A85);

class HomeScreen extends StatefulWidget {
  final KasViewModel viewModel;

  const HomeScreen({super.key, required this.viewModel});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _filter = 'Semua';
  String _query = '';

  bool _isCurrentMonth(Transaksi transaction) {
    final now = DateTime.now();
    return transaction.tanggal.year == now.year &&
        transaction.tanggal.month == now.month;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatRupiah(double value) {
    final amount = value.round().toString();
    final formatted = amount.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return 'Rp $formatted';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final allTransactions = widget.viewModel.daftarTransaksi;
        final transactions = allTransactions.where((transaction) {
          final matchesFilter = _filter == 'Semua' ||
              (_filter == 'Pemasukan' &&
                  transaction.jenis == JenisTransaksi.pemasukan) ||
              (_filter == 'Pengeluaran' &&
                  transaction.jenis == JenisTransaksi.pengeluaran) ||
              (_filter == 'Bulan ini' && _isCurrentMonth(transaction));
          final matchesQuery =
              transaction.keterangan.toLowerCase().contains(_query);
          return matchesFilter && matchesQuery;
        }).toList();

        return Scaffold(
          backgroundColor: _background,
          appBar: AppBar(
            titleSpacing: 20,
            title: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _mint.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded,
                      color: _mint, size: 23),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NusaKas',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                    Text(
                      'KEUANGAN HIMPUNAN',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                key: const Key('btn_ekspor_csv'),
                tooltip: 'Salin laporan CSV',
                onPressed: () => _showExportDialog(allTransactions),
                icon: const Icon(Icons.ios_share_rounded),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2, right: 16),
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.phone_android_rounded,
                            color: _mint, size: 14),
                        SizedBox(width: 5),
                        Text(
                          'Lokal',
                          style: TextStyle(
                            color: Color(0xFFD8E5F5),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildSummaryCard(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 2, 20, 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Aktivitas kas',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          '${allTransactions.length} transaksi',
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 46,
                      child: TextField(
                        key: const Key('field_pencarian'),
                        controller: _searchController,
                        onChanged: (value) => setState(
                          () => _query = value.trim().toLowerCase(),
                        ),
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Cari transaksi...',
                          hintStyle:
                              const TextStyle(color: _muted, fontSize: 14),
                          prefixIcon:
                              const Icon(Icons.search_rounded, color: _muted),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Hapus pencarian',
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _query = '');
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                          contentPadding: EdgeInsets.zero,
                          filled: true,
                          fillColor: _surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildFilterChip('Semua'),
                          _buildFilterChip('Bulan ini'),
                          _buildFilterChip('Pemasukan'),
                          _buildFilterChip('Pengeluaran'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: transactions.isEmpty
                    ? _buildEmptyState(allTransactions.isNotEmpty)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          return _buildTransactionTile(transaction, index);
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            key: const Key('btn_tambah_transaksi'),
            backgroundColor: _mint,
            foregroundColor: _background,
            elevation: 8,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) =>
                      TambahTransaksiScreen(viewModel: widget.viewModel),
                ),
              );
            },
            icon: const Icon(Icons.add_rounded, size: 23),
            label: const Text(
              'Transaksi baru',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.94, end: 1),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        padding: const EdgeInsets.all(21),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF183D66), Color(0xFF102345), Color(0xFF102345)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: _mint.withValues(alpha: 0.08),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_graph_rounded, color: _mint, size: 17),
                SizedBox(width: 8),
                Text(
                  'SALDO KAS SAAT INI',
                  style: TextStyle(
                    color: Color(0xFFC1D3E8),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.18),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Text(
                _formatRupiah(widget.viewModel.saldo),
                key: Key('saldo_${widget.viewModel.saldo}'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
            ),
            const SizedBox(height: 19),
            Row(
              children: [
                Expanded(
                  child: _buildTotalCard(
                    title: 'PEMASUKAN',
                    value: widget.viewModel.totalPemasukan,
                    color: _mint,
                    icon: Icons.south_west_rounded,
                    keyValue: const Key('text_total_pemasukan'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTotalCard(
                    title: 'PENGELUARAN',
                    value: widget.viewModel.totalPengeluaran,
                    color: _coral,
                    icon: Icons.north_east_rounded,
                    keyValue: const Key('text_total_pengeluaran'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            _buildMonthlyInsight(widget.viewModel.daftarTransaksi),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyInsight(List<Transaksi> transactions) {
    final thisMonth =
        transactions.where(_isCurrentMonth).toList(growable: false);
    final income = thisMonth
        .where((item) => item.jenis == JenisTransaksi.pemasukan)
        .fold<double>(0, (total, item) => total + item.nominal);
    final expenses = thisMonth
        .where((item) => item.jenis == JenisTransaksi.pengeluaran)
        .fold<double>(0, (total, item) => total + item.nominal);
    final totalFlow = income + expenses;
    final incomeRatio = totalFlow == 0 ? 0.0 : income / totalFlow;
    final net = income - expenses;
    final netColor = net < 0 ? _coral : _mint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_month_rounded, color: _mint, size: 14),
            const SizedBox(width: 6),
            const Expanded(
              child: Text(
                'ARUS KAS BULAN INI',
                style: TextStyle(
                  color: _muted,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Text(
              '${thisMonth.length} transaksi',
              style: const TextStyle(color: _muted, fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            const Text(
              'Bersih',
              style: TextStyle(color: Color(0xFFC1D3E8), fontSize: 11),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: incomeRatio),
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    backgroundColor: totalFlow == 0
                        ? Colors.white.withValues(alpha: 0.12)
                        : _coral.withValues(alpha: 0.55),
                    valueColor: const AlwaysStoppedAnimation<Color>(_mint),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 9),
            Text(
              _formatRupiah(net),
              style: TextStyle(
                color: netColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalCard({
    required String title,
    required double value,
    required Color color,
    required IconData icon,
    required Key keyValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.65,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _formatRupiah(value),
              key: keyValue,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final selected = _filter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        labelStyle: TextStyle(
          color: selected ? _background : const Color(0xFFC1D3E8),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        backgroundColor: _surface,
        selectedColor: _mint,
        side: BorderSide(
          color: selected ? _mint : Colors.white.withValues(alpha: 0.05),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onSelected: (_) => setState(() => _filter = label),
      ),
    );
  }

  Future<void> _showExportDialog(List<Transaksi> transactions) async {
    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belum ada transaksi untuk diekspor.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final csv = StringBuffer('Tanggal,Keterangan,Jenis,Nominal (Rp)\n');
    for (final transaction in transactions) {
      final date = transaction.tanggal;
      final dateLabel =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final kind = transaction.jenis == JenisTransaksi.pemasukan
          ? 'Pemasukan'
          : 'Pengeluaran';
      csv
        ..write('$dateLabel,')
        ..write('"${transaction.keterangan.replaceAll('"', '""')}",')
        ..write('$kind,')
        ..writeln(transaction.nominal.toStringAsFixed(0));
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Ekspor laporan CSV',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${transactions.length} transaksi siap disalin ke spreadsheet.',
                style: const TextStyle(color: _muted, fontSize: 13),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 150),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _background,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    csv.toString(),
                    style: const TextStyle(
                      color: Color(0xFFC1D3E8),
                      fontSize: 11,
                      height: 1.5,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('btn_salin_csv'),
                  onPressed: () async {
                    await Clipboard.setData(
                        ClipboardData(text: csv.toString()));
                    if (!mounted || !context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(
                        content: Text('Laporan CSV berhasil disalin.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _mint,
                    foregroundColor: _background,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text(
                    'Salin CSV',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool hasTransactions) {
    final title =
        hasTransactions ? 'Transaksi tidak ditemukan' : 'Belum ada transaksi';
    final message = hasTransactions
        ? 'Coba kata kunci atau filter yang berbeda.'
        : 'Catat pemasukan atau pengeluaran pertama\nuntuk mulai mengelola kas.';
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 220;
        final iconSize = compact ? 42.0 : 74.0;
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 28,
              vertical: compact ? 4 : 28,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: _mint.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(compact ? 15 : 26),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: _mint,
                    size: compact ? 22 : 34,
                  ),
                ),
                SizedBox(height: compact ? 6 : 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 14 : 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: compact ? 3 : 7),
                Text(
                  compact && !hasTransactions
                      ? 'Tambah transaksi pertama untuk mulai.'
                      : message,
                  maxLines: compact ? 2 : null,
                  overflow: compact ? TextOverflow.ellipsis : null,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _muted,
                    height: compact ? 1.25 : 1.5,
                    fontSize: compact ? 11 : 13,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionTile(Transaksi transaction, int index) {
    final isIncome = transaction.jenis == JenisTransaksi.pemasukan;
    final accent = isIncome ? _mint : _coral;
    final amountSign = isIncome ? '+' : '-';
    final date = transaction.tanggal;
    final dateLabel =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return TweenAnimationBuilder<double>(
      key: ValueKey(transaction.id),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 250 + (index.clamp(0, 5) * 55)),
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) => Opacity(
        opacity: progress,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - progress)),
          child: child,
        ),
      ),
      child: Dismissible(
        key: Key('dismiss_${transaction.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.only(right: 22),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
            color: _coral,
            borderRadius: BorderRadius.circular(19),
          ),
          child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
        ),
        onDismissed: (_) => _hapusTransaksi(transaction),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: Colors.white.withValues(alpha: 0.045)),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
                color: accent,
                size: 21,
              ),
            ),
            title: Text(
              transaction.keterangan,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFF3F7FC),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                '${isIncome ? 'Pemasukan' : 'Pengeluaran'}  ·  $dateLabel',
                style: const TextStyle(color: _muted, fontSize: 11),
              ),
            ),
            trailing: Text(
              '$amountSign ${_formatRupiah(transaction.nominal)}',
              style: TextStyle(
                color: accent,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _hapusTransaksi(Transaksi transaction) {
    final removed = widget.viewModel.hapusTransaksi(transaction.id);
    if (removed == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Transaksi "${transaction.keterangan}" dihapus'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'URUNGKAN',
            textColor: _mint,
            onPressed: () => widget.viewModel.pulihkanTransaksi(removed),
          ),
        ),
      );
  }
}
