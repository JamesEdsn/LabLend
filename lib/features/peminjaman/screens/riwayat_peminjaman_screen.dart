import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/peminjaman_model.dart';
import '../providers/riwayat_peminjaman_notifier.dart';
import 'edit_peminjaman_dialog.dart';

const Color _navy = Color(0xFF172B4D);
const Color _blue = Color(0xFF356AE6);
const Color _background = Color(0xFFF5F7FB);
const Color _muted = Color(0xFF718096);
const Color _border = Color(0xFFE8EDF4);

class RiwayatPeminjamanScreen extends ConsumerWidget {
  const RiwayatPeminjamanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riwayat = ref.watch(riwayatPeminjamanProvider);

    return Container(
      color: _background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth > 900 ? 36.0 : 18.0;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 28,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, ref),
                    const SizedBox(height: 26),

                    riwayat.when(
                      loading: () => _buildLoading(),
                      error: (error, stackTrace) => _buildError(context, ref),
                      data: (records) => _buildContent(context, ref, records),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // HEADER
  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Riwayat Peminjaman',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: _navy,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Kelola dan pantau seluruh catatan peminjaman alat laboratorium.',
                style: TextStyle(fontSize: 14, color: _muted, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () {
            ref.read(riwayatPeminjamanProvider.notifier).refreshRiwayat();
          },
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Refresh'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _navy,
            side: const BorderSide(color: _border),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
          ),
        ),
      ],
    );
  }

  // CONTENT
  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<Peminjaman> records,
  ) {
    if (records.isEmpty) {
      return _buildEmpty();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummary(records.length),
        const SizedBox(height: 28),

        Row(
          children: [
            const Expanded(
              child: Text(
                'Daftar Peminjaman',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _navy,
                ),
              ),
            ),
            Text(
              '${records.length} data',
              style: const TextStyle(
                fontSize: 13,
                color: _muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        ...records.map(
          (record) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildRecordCard(context, ref, record),
          ),
        ),
      ],
    );
  }

  // SUMMARY CARD
  Widget _buildSummary(int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: _blue,
              size: 26,
            ),
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Peminjaman',
                  style: TextStyle(
                    fontSize: 13,
                    color: _muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$total',
                  style: const TextStyle(
                    fontSize: 27,
                    color: _navy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'Data tercatat',
            style: TextStyle(fontSize: 12, color: _muted),
          ),
        ],
      ),
    );
  }

  // RECORD CARD
  Widget _buildRecordCard(
    BuildContext context,
    WidgetRef ref,
    Peminjaman record,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: _blue,
              size: 23,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.alat,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _navy,
                  ),
                ),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 18,
                  runSpacing: 8,
                  children: [
                    _buildDetail(
                      Icons.numbers_rounded,
                      'Jumlah: ${record.jumlah} unit',
                    ),
                    _buildDetail(
                      Icons.calendar_today_outlined,
                      'Kembali: ${record.tanggalKembali}',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          PopupMenuButton<String>(
            tooltip: 'Pilihan',
            icon: const Icon(Icons.more_vert, color: _muted),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (action) async {
              if (action == 'edit') {
                await _editRecord(context, ref, record);
              } else if (action == 'delete') {
                await _deleteRecord(context, ref, record);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Hapus', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: _muted),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12, color: _muted)),
      ],
    );
  }

  // EDIT
  Future<void> _editRecord(
    BuildContext context,
    WidgetRef ref,
    Peminjaman record,
  ) async {
    final updated = await showDialog<Peminjaman>(
      context: context,
      builder: (dialogContext) {
        return EditPeminjamanDialog(record: record);
      },
    );

    if (updated == null || !context.mounted) return;

    try {
      await ref
          .read(riwayatPeminjamanProvider.notifier)
          .updatePeminjaman(updated);

      if (context.mounted) {
        _showMessage(context, 'Peminjaman berhasil diperbarui.');
      }
    } catch (error) {
      if (context.mounted) {
        _showMessage(context, 'Gagal memperbarui data.');
      }
    }
  }

  // DELETE
  Future<void> _deleteRecord(
    BuildContext context,
    WidgetRef ref,
    Peminjaman record,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus peminjaman?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Apakah kamu yakin ingin menghapus catatan ${record.alat}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(riwayatPeminjamanProvider.notifier)
          .hapusPeminjaman(record.id);

      if (context.mounted) {
        _showMessage(context, 'Peminjaman berhasil dihapus.');
      }
    } catch (error) {
      if (context.mounted) {
        _showMessage(context, 'Gagal menghapus data.');
      }
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // LOADING
  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 100),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  // ERROR
  Widget _buildError(BuildContext context, WidgetRef ref) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_outlined, size: 42, color: _muted),
            const SizedBox(height: 14),
            const Text(
              'Gagal memuat riwayat peminjaman.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _navy, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(riwayatPeminjamanProvider.notifier).refreshRiwayat();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  // EMPTY

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 65),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: const Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 52, color: Color(0xFF9AA8BC)),
          SizedBox(height: 16),
          Text(
            'Belum ada riwayat peminjaman.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _navy,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Catatan peminjaman yang kamu ajukan akan muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: _muted, height: 1.5),
          ),
        ],
      ),
    );
  }
}
