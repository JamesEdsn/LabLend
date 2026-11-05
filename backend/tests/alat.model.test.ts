import assert from "node:assert/strict";
import test from "node:test";

import {
  isValidAlat,
  type AlatInput,
} from "../src/models/alat.model.js";

const validAlat: AlatInput = {
  nama: "ESP32",
  kategori: "Mikrokontroler",
  deskripsi: "Development board ESP32",
  stokTotal: 10,
  stokTersedia: 8,
};

test("validasi menerima data alat yang benar", () => {
  assert.equal(isValidAlat(validAlat), true);
});

test("validasi menerima deskripsi kosong atau null", () => {
  assert.equal(
    isValidAlat({ ...validAlat, deskripsi: "" }),
    true,
  );

  assert.equal(
    isValidAlat({ ...validAlat, deskripsi: null }),
    true,
  );

  const { deskripsi: _deskripsi, ...withoutDescription } = validAlat;
  assert.equal(isValidAlat(withoutDescription), true);
});

test("validasi menolak nama atau kategori kosong", () => {
  assert.equal(isValidAlat({ ...validAlat, nama: "" }), false);
  assert.equal(isValidAlat({ ...validAlat, nama: "   " }), false);
  assert.equal(isValidAlat({ ...validAlat, kategori: "" }), false);
});

test("validasi menolak stok negatif atau pecahan", () => {
  assert.equal(isValidAlat({ ...validAlat, stokTotal: -1 }), false);
  assert.equal(isValidAlat({ ...validAlat, stokTersedia: -1 }), false);
  assert.equal(isValidAlat({ ...validAlat, stokTotal: 1.5 }), false);
  assert.equal(isValidAlat({ ...validAlat, stokTersedia: 2.5 }), false);
});

test("validasi menolak stok tersedia melebihi stok total", () => {
  assert.equal(
    isValidAlat({
      ...validAlat,
      stokTotal: 5,
      stokTersedia: 6,
    }),
    false,
  );
});

test("validasi menerima stok total dan tersedia bernilai nol", () => {
  assert.equal(
    isValidAlat({
      ...validAlat,
      stokTotal: 0,
      stokTersedia: 0,
    }),
    true,
  );
});

test("validasi menolak payload yang bukan object", () => {
  assert.equal(isValidAlat(null), false);
  assert.equal(isValidAlat(undefined), false);
  assert.equal(isValidAlat("ESP32"), false);
  assert.equal(isValidAlat(123), false);
});