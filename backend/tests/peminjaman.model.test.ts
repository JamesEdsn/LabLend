import assert from "node:assert/strict";
import test from "node:test";
import { isValidPeminjaman } from "../src/models/peminjaman.model.js";

const validInput = {
  alat: "Laptop",
  jumlah: 2,
  tanggalKembali: "2026-11-15",
};

test("validasi menerima data peminjaman yang benar", () => {
  assert.equal(isValidPeminjaman(validInput), true);
});

test("validasi menolak nama alat kosong", () => {
  assert.equal(isValidPeminjaman({ ...validInput, alat: "  " }), false);
});

test("validasi menolak jumlah nol, negatif, atau pecahan", () => {
  assert.equal(isValidPeminjaman({ ...validInput, jumlah: 0 }), false);
  assert.equal(isValidPeminjaman({ ...validInput, jumlah: -1 }), false);
  assert.equal(isValidPeminjaman({ ...validInput, jumlah: 1.5 }), false);
});

test("validasi menolak format tanggal dan tanggal kalender yang invalid", () => {
  assert.equal(isValidPeminjaman({ ...validInput, tanggalKembali: "15-11-2026" }), false);
  assert.equal(isValidPeminjaman({ ...validInput, tanggalKembali: "2026-02-30" }), false);
});

test("validasi menolak payload yang bukan object", () => {
  assert.equal(isValidPeminjaman(null), false);
  assert.equal(isValidPeminjaman("payload"), false);
  assert.equal(isValidPeminjaman([]), false);
});
