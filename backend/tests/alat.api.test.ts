import assert from "node:assert/strict";
import { once } from "node:events";
import type { AddressInfo } from "node:net";
import test from "node:test";
import type { Express } from "express";
import jwt from "jsonwebtoken";

import { createApp } from "../src/app.js";

import type { PeminjamanRepositoryPort } from "../src/routes/peminjaman.routes.js";

import type {
  AlatRecord,
  AlatRepositoryPort,
} from "../src/routes/alat.routes.js";

import type { AlatInput } from "../src/models/alat.model.js";

process.env.JWT_SECRET ??= "test_secret_for_lablend_api_tests";

const JWT_SECRET = process.env.JWT_SECRET;

const studentId = "student-test";
const aslabId = "aslab-test";

function makeToken(userId: string, role: "STUDENT" | "ASLAB") {
  return jwt.sign({ userId, role }, JWT_SECRET, {
    expiresIn: "1h",
  });
}

const studentToken = makeToken(studentId, "STUDENT");
const aslabToken = makeToken(aslabId, "ASLAB");

const authHeaders = (token: string) => ({
  Authorization: `Bearer ${token}`,
});

const validInput: AlatInput = {
  nama: "ESP32",
  kategori: "Mikrokontroler",
  deskripsi: "Development board ESP32",
  stokTotal: 10,
  stokTersedia: 8,
};

// Repository peminjaman kosong untuk kebutuhan createApp().
const peminjamanRepository: PeminjamanRepositoryPort = {
  findAll: async () => [],
  findById: async () => null,
  create: async () => {
    throw new Error("Tidak digunakan dalam test inventaris");
  },
  update: async () => null,
  delete: async () => ({ count: 0 }),
};

function makeRepository(initial: AlatRecord[] = []) {
  let records = [...initial];
  let nextId = initial.length + 1;

  const repository: AlatRepositoryPort = {
    findAll: async () => [...records],

    findById: async (id) =>
      records.find((record) => record.id === id) ?? null,

    create: async (input) => {
      const record: AlatRecord = {
        id: `alat-${nextId++}`,
        ...input,
      };

      records = [...records, record];
      return record;
    },

    update: async (id, input) => {
      const index = records.findIndex((record) => record.id === id);

      if (index < 0) return null;

      const updated: AlatRecord = {
        ...records[index],
        ...input,
      };

      records[index] = updated;
      return updated;
    },

    delete: async (id) => {
      const before = records.length;
      records = records.filter((record) => record.id !== id);

      return { count: before - records.length };
    },
  };

  return { repository, getRecords: () => [...records] };
}

async function withServer<T>(
  app: Express,
  run: (baseUrl: string) => Promise<T>,
) {
  const server = app.listen(0, "127.0.0.1");
  await once(server, "listening");
  const address = server.address() as AddressInfo;

  try {
    return await run(`http://127.0.0.1:${address.port}`);
  } finally {
    await new Promise<void>((resolve, reject) => {
      server.close((error) => (error ? reject(error) : resolve()));
    });
  }
}

function makeApp(repository: AlatRepositoryPort) {
  return createApp(peminjamanRepository, repository);
}

test("GET mengembalikan seluruh data inventaris untuk STUDENT", async () => {
  const { repository } = makeRepository([
    { id: "alat-1", ...validInput },
  ]);

  await withServer(makeApp(repository), async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/alat`, {
      headers: authHeaders(studentToken),
    });

    const body = await response.json() as {
      success: boolean;
      data: AlatRecord[];
    };

    assert.equal(response.status, 200);
    assert.equal(body.success, true);
    assert.equal(body.data.length, 1);
    assert.equal(body.data[0].nama, "ESP32");
  });
});

test("GET mengembalikan array kosong jika inventaris belum tersedia", async () => {
  const { repository } = makeRepository();

  await withServer(makeApp(repository), async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/alat`, {
      headers: authHeaders(studentToken),
    });

    const body = await response.json() as {
      success: boolean;
      data: unknown[];
    };

    assert.equal(response.status, 200);
    assert.deepEqual(body.data, []);
  });
});

test("GET detail alat berhasil", async () => {
  const { repository } = makeRepository([
    { id: "alat-1", ...validInput },
  ]);

  await withServer(makeApp(repository), async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/alat/alat-1`, {
      headers: authHeaders(studentToken),
    });

    const body = await response.json() as {
      success: boolean;
      data: AlatRecord;
    };

    assert.equal(response.status, 200);
    assert.equal(body.data.id, "alat-1");
  });
});

test("GET detail mengembalikan 404 jika alat tidak ditemukan", async () => {
  const { repository } = makeRepository();

  await withServer(makeApp(repository), async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/alat/missing-id`, {
      headers: authHeaders(studentToken),
    });

    assert.equal(response.status, 404);
  });
});

test("ASLAB berhasil menambahkan alat", async () => {
  const { repository, getRecords } = makeRepository();

  await withServer(makeApp(repository), async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/alat`, {
      method: "POST",
      headers: {
        ...authHeaders(aslabToken),
        "Content-Type": "application/json",
      },
      body: JSON.stringify(validInput),
    });

    const body = await response.json() as {
      success: boolean;
      data: AlatRecord;
    };

    assert.equal(response.status, 201);
    assert.equal(body.success, true);
    assert.equal(body.data.nama, "ESP32");
    assert.equal(getRecords().length, 1);
  });
});

test("POST menolak data alat dengan stok tidak valid", async () => {
  const { repository } = makeRepository();

  await withServer(makeApp(repository), async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/alat`, {
      method: "POST",
      headers: {
        ...authHeaders(aslabToken),
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        ...validInput,
        stokTersedia: 20,
      }),
    });

    assert.equal(response.status, 400);
  });
});

test("STUDENT tidak boleh menambahkan alat", async () => {
  const { repository, getRecords } = makeRepository();

  await withServer(makeApp(repository), async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/alat`, {
      method: "POST",
      headers: {
        ...authHeaders(studentToken),
        "Content-Type": "application/json",
      },
      body: JSON.stringify(validInput),
    });

    assert.equal(response.status, 403);
    assert.equal(getRecords().length, 0);
  });
});

test("ASLAB berhasil memperbarui data alat", async () => {
  const { repository, getRecords } = makeRepository([
    { id: "alat-1", ...validInput },
  ]);

  await withServer(makeApp(repository), async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/alat/alat-1`, {
      method: "PUT",
      headers: {
        ...authHeaders(aslabToken),
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        ...validInput,
        stokTotal: 15,
        stokTersedia: 12,
      }),
    });

    assert.equal(response.status, 200);
    assert.equal(getRecords()[0].stokTotal, 15);
    assert.equal(getRecords()[0].stokTersedia, 12);
  });
});

test("PUT mengembalikan 404 jika alat tidak ditemukan", async () => {
  const { repository } = makeRepository();

  await withServer(makeApp(repository), async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/alat/missing-id`, {
      method: "PUT",
      headers: {
        ...authHeaders(aslabToken),
        "Content-Type": "application/json",
      },
      body: JSON.stringify(validInput),
    });

    assert.equal(response.status, 404);
  });
});

test("STUDENT tidak boleh memperbarui data alat", async () => {
  const { repository, getRecords } = makeRepository([
    { id: "alat-1", ...validInput },
  ]);

  await withServer(makeApp(repository), async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/alat/alat-1`, {
      method: "PUT",
      headers: {
        ...authHeaders(studentToken),
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        ...validInput,
        stokTotal: 99,
      }),
    });

    assert.equal(response.status, 403);
    assert.equal(getRecords()[0].stokTotal, 10);
  });
});

test("ASLAB berhasil menghapus alat", async () => {
  const { repository, getRecords } = makeRepository([
    { id: "alat-1", ...validInput },
  ]);

  await withServer(makeApp(repository), async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/alat/alat-1`, {
      method: "DELETE",
      headers: authHeaders(aslabToken),
    });

    assert.equal(response.status, 200);
    assert.equal(getRecords().length, 0);
  });
});

test("STUDENT tidak boleh menghapus alat", async () => {
  const { repository, getRecords } = makeRepository([
    { id: "alat-1", ...validInput },
  ]);

  await withServer(makeApp(repository), async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/alat/alat-1`, {
      method: "DELETE",
      headers: authHeaders(studentToken),
    });

    assert.equal(response.status, 403);
    assert.equal(getRecords().length, 1);
  });
});

test("API inventaris menolak request tanpa token", async () => {
  const { repository } = makeRepository();

  await withServer(makeApp(repository), async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/alat`);

    assert.equal(response.status, 401);
  });
});

test("DELETE mengembalikan 404 jika alat tidak ditemukan", async () => {
  const { repository } = makeRepository();

  await withServer(makeApp(repository), async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/alat/missing-id`, {
      method: "DELETE",
      headers: authHeaders(aslabToken),
    });

    assert.equal(response.status, 404);
  });
});