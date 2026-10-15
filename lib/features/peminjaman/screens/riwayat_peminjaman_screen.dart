import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/peminjaman_model.dart';
import '../providers/riwayat_peminjaman_notifier.dart';
import 'edit_peminjaman_dialog.dart';

class RiwayatPeminjamanScreen extends ConsumerWidget {
  const RiwayatPeminjamanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riwayat = ref.watch(riwayatPeminjamanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Peminjaman'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(riwayatPeminjamanProvider.notifier).refreshRiwayat();
            },
          ),
        ],
      ),
      body: riwayat.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Gagal memuat riwayat peminjaman.'),
              ElevatedButton(
                onPressed: () {
                  ref.read(riwayatPeminjamanProvider.notifier).refreshRiwayat();
                },
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (records) {
          if (records.isEmpty) {
            return const Center(child: Text('Belum ada riwayat peminjaman.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];

              return Card(
                child: ListTile(
                  title: Text(record.alat),
                  subtitle: Text(
                    'Jumlah: ${record.jumlah}\n'
                    'Tanggal kembali: ${record.tanggalKembali}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) async {
                      if (action == 'edit') {
                        final updated = await _showEditDialog(context, record);

                        if (updated != null && context.mounted) {
                          try {
                            await ref
                                .read(riwayatPeminjamanProvider.notifier)
                                .updatePeminjaman(updated);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Peminjaman diperbarui.'),
                                ),
                              );
                            }
                          } catch (error) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Gagal memperbarui data.'),
                                ),
                              );
                            }
                          }
                        }
                      } else if (action == 'delete') {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Hapus peminjaman?'),
                            content: Text('Hapus catatan ${record.alat}?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, false),
                                child: const Text('Batal'),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, true),
                                child: const Text('Hapus'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true && context.mounted) {
                          try {
                            await ref
                                .read(riwayatPeminjamanProvider.notifier)
                                .hapusPeminjaman(record.id);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Peminjaman dihapus.'),
                                ),
                              );
                            }
                          } catch (error) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Gagal menghapus data.'),
                                ),
                              );
                            }
                          }
                        }
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Hapus')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<Peminjaman?> _showEditDialog(BuildContext context, Peminjaman record) {
    return showDialog<Peminjaman>(
      context: context,
      builder: (dialogContext) {
        return EditPeminjamanDialog(record: record);
      },
    );
  }
}
