import 'package:flutter/material.dart';

import '../models/peminjaman_model.dart';

class EditPeminjamanDialog extends StatefulWidget {
  final Peminjaman record;

  const EditPeminjamanDialog({super.key, required this.record});

  @override
  State<EditPeminjamanDialog> createState() => _EditPeminjamanDialogState();
}

class _EditPeminjamanDialogState extends State<EditPeminjamanDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _alatController;
  late final TextEditingController _jumlahController;
  late final TextEditingController _tanggalController;

  @override
  void initState() {
    super.initState();

    _alatController = TextEditingController(text: widget.record.alat);
    _jumlahController = TextEditingController(
      text: widget.record.jumlah.toString(),
    );
    _tanggalController = TextEditingController(
      text: widget.record.tanggalKembali,
    );
  }

  @override
  void dispose() {
    _alatController.dispose();
    _jumlahController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Peminjaman'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _alatController,
                decoration: const InputDecoration(labelText: 'Nama alat'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama alat wajib diisi';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Jumlah'),
                validator: (value) {
                  final jumlah = int.tryParse(value ?? '');
                  if (jumlah == null || jumlah <= 0) {
                    return 'Jumlah harus lebih dari 0';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _tanggalController,
                decoration: const InputDecoration(labelText: 'Tanggal kembali'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tanggal kembali wajib diisi';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Simpan')),
      ],
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedRecord = widget.record.copyWith(
      alat: _alatController.text.trim(),
      jumlah: int.parse(_jumlahController.text),
      tanggalKembali: _tanggalController.text.trim(),
    );

    Navigator.pop(context, updatedRecord);
  }
}
