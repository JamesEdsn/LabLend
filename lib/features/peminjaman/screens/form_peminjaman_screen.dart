import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/peminjaman_notifier.dart';

class FormPeminjamanScreen extends ConsumerStatefulWidget {
  const FormPeminjamanScreen({super.key});

  @override
  ConsumerState<FormPeminjamanScreen> createState() =>
      _FormPeminjamanScreenState();
}

class _FormPeminjamanScreenState extends ConsumerState<FormPeminjamanScreen> {
  final _formKey = GlobalKey<FormState>();

  final _jumlahController = TextEditingController();
  final _tanggalController = TextEditingController();

  String? selectedAlat;

  @override
  void dispose() {
    _jumlahController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(peminjamanProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengajuan Peminjaman')),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(PeminjamanState state) {
    // 1. INITIAL LOADING
    if (state.status == PeminjamanStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. ERROR
    if (state.status == PeminjamanStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60),
            const SizedBox(height: 16),
            Text(state.errorMessage ?? 'Terjadi kesalahan.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(peminjamanProvider.notifier).fetchAlat();
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // 3. EMPTY
    if (state.status == PeminjamanStatus.empty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 60),
            SizedBox(height: 16),
            Text('Stok Alat Sedang Kosong', style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    // 4. LOADED
    return _buildForm(state);
  }

  Widget _buildForm(PeminjamanState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const Text(
              'Form Peminjaman Alat',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text('Silakan isi data peminjaman berikut.'),

            const SizedBox(height: 24),

            // ALAT
            DropdownButtonFormField<String>(
              initialValue: selectedAlat,
              decoration: const InputDecoration(
                labelText: 'Pilih Alat',
                border: OutlineInputBorder(),
              ),
              items: state.alat
                  .map(
                    (alat) => DropdownMenuItem<String>(
                      value: alat,
                      child: Text(alat),
                    ),
                  )
                  .toList(),
              onChanged: state.isSubmitting
                  ? null
                  : (value) {
                      setState(() {
                        selectedAlat = value;
                      });
                    },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Silakan pilih alat';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // JUMLAH
            TextFormField(
              controller: _jumlahController,
              enabled: !state.isSubmitting,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jumlah tidak boleh kosong';
                }

                final jumlah = int.tryParse(value);

                if (jumlah == null || jumlah <= 0) {
                  return 'Jumlah harus lebih dari 0';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // TANGGAL KEMBALI
            TextFormField(
              controller: _tanggalController,
              enabled: !state.isSubmitting,
              decoration: const InputDecoration(
                labelText: 'Tanggal Kembali',
                hintText: 'Contoh: 20 Oktober 2026',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tanggal kembali tidak boleh kosong';
                }

                return null;
              },
            ),

            const SizedBox(height: 24),

            // SUBMIT
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: state.isSubmitting ? null : _submitPeminjaman,
                child: state.isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Submit Peminjaman',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitPeminjaman() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final notifier = ref.read(peminjamanProvider.notifier);

    final success = await notifier.submitPeminjaman(
      alat: selectedAlat!,
      jumlah: int.parse(_jumlahController.text),
      tanggalKembali: _tanggalController.text,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Peminjaman berhasil diajukan!'
              : 'Peminjaman gagal diajukan.',
        ),
      ),
    );

    if (success) {
      _jumlahController.clear();
      _tanggalController.clear();

      setState(() {
        selectedAlat = null;
      });
    }
  }
}
