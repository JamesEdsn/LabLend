
import assert from "node:assert/strict";
import { once } from "node:events";
import type { AddressInfo } from "node:net";
import test from "node:test";
import type { Express } from "express";
import jwt from "jsonwebtoken";

import { createApp } from "../src/app.js";
import type { PeminjamanInput } from "../src/models/peminjaman.model.js";
import type {
  PeminjamanRecord,
  PeminjamanRepositoryPort,
} from "../src/routes/peminjaman.routes.js";

process.env.JWT_SECRET ??= "test_secret_for_lablend_api_tests";

const JWT_SECRET = process.env.JWT_SECRET;

const userA = "user-test-a";
const userB = "user-test-b";

function makeToken(userId: string) {
  return jwt.sign({ userId, role: "STUDENT" }, JWT_SECRET, {
    expiresIn: "1h",
  });
}

const tokenA = makeToken(userA);
const tokenB = makeToken(userB);

const authHeaders = (token = tokenA) => ({
  Authorization: `Bearer ${token}`,
});

const validInput: PeminjamanInput = {
  alat: "Laptop",
  jumlah: 2,
  tanggalKembali: "2026-11-15",
};

function makeRepository(initial: PeminjamanRecord[] = []) {
  let records = [...initial];
  let nextId = initial.length + 1;

  const repository: PeminjamanRepositoryPort = {
    findAll: async (userId) =>
      records.filter((record) => record.userId === userId),

    findById: async (id, userId) =>
      records.find(
        (record) => record.id === id && record.userId === userId
      ) ?? null,

    create: async (input, userId) => {
      const record: PeminjamanRecord = {
        id: `test-${nextId++}`,
        ...input,
        userId,
      };
      records = [record, ...records];
      return record;
    },

    update: async (id, input, userId) => {
      const index = records.findIndex(
        (record) => record.id === id && record.userId === userId
      );

      if (index < 0) return null;

      const updated: PeminjamanRecord = {
        ...records[index],
        ...input,
      };

      records[index] = updated;
      return updated;
    },

    delete: async (id, userId) => {
      const before = records.length;
      records = records.filter(
        (record) => !(record.id === id && record.userId === userId)
      );

      return { count: before - records.length };
    },
  };

  return { repository, getRecords: () => [...records] };
}

async function withServer<T>(
  app: Express,
  run: (baseUrl: string) => Promise<T>
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

test("GET mengembalikan data peminjaman milik user", async () => {
  const { repository } = makeRepository([
    { id: "p-1", ...validInput, userId: userA },
    { id: "p-2", ...validInput, userId: userB },
  ]);

  await withServer(createApp(repository), async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/peminjaman`, {
      headers: authHeaders(tokenA),
    });

    const body = await response.json() as {
      success: boolean;
      data: PeminjamanRecord[];
    };

    assert.equal(response.status, 200);
    assert.equal(body.success, true);
    assert.equal(body.data.length, 1);
    assert.equal(body.data[0].id, "p-1");
  });
});

test("GET mengembalikan array kosong ketika user belum punya data", async () => {
  const { repository } = makeRepository();

  await withServer(createApp(repository), async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/peminjaman`, {
      headers: authHeaders(tokenA),
    });

    const body = await response.json() as {
      success: boolean;
      data: unknown[];
    };

    assert.equal(response.status, 200);
    assert.equal(body.success, true);
    assert.deepEqual(body.data, []);
  });
});

test("POST, PUT, dan DELETE berhasil untuk pemilik data", async () => {
  const { repository, getRecords } = makeRepository();

  await withServer(createApp(repository), async (baseUrl) => {
    const createdResponse = await fetch(`${baseUrl}/api/peminjaman`, {
      method: "POST",
      headers: {
        ...authHeaders(tokenA),
        "Content-Type": "application/json",
      },
      body: JSON.stringify(validInput),
    });

    const createdBody = await createdResponse.json() as {
      data: PeminjamanRecord;
    };

    assert.equal(createdResponse.status, 201);
    assert.equal(createdBody.data.alat, "Laptop");
    assert.equal(createdBody.data.userId, userA);

    const id = createdBody.data.id;

    const updatedResponse = await fetch(
      `${baseUrl}/api/peminjaman/${id}`,
      {
        method: "PUT",
        headers: {
          ...authHeaders(tokenA),
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ ...validInput, jumlah: 3 }),
      }
    );

    assert.equal(updatedResponse.status, 200);
    assert.equal(getRecords()[0].jumlah, 3);

    const deleteResponse = await fetch(
      `${baseUrl}/api/peminjaman/${id}`,
      {
        method: "DELETE",
        headers: authHeaders(tokenA),
      }
    );

    assert.equal(deleteResponse.status, 200);
    assert.equal(getRecords().length, 0);
  });
});

test("POST menolak input peminjaman yang invalid", async () => {
  const { repository } = makeRepository();

  await withServer(createApp(repository), async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/peminjaman`, {
      method: "POST",
      headers: {
        ...authHeaders(tokenA),
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ ...validInput, jumlah: 0 }),
    });

    const body = await response.json() as { success: boolean };

    assert.equal(response.status, 400);
    assert.equal(body.success, false);
  });
});

test("API mengembalikan 400 untuk JSON yang rusak", async () => {
  const { repository } = makeRepository();

  await withServer(createApp(repository), async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/peminjaman`, {
      method: "POST",
      headers: {
        ...authHeaders(tokenA),
        "Content-Type": "application/json",
      },
      body: '{"alat":',
    });

    const body = await response.json() as {
      success: boolean;
      message: string;
    };

    assert.equal(response.status, 400);
    assert.equal(body.success, false);
    assert.equal(body.message, "Format JSON tidak valid");
  });
});

test("GET mengembalikan 404 untuk ID yang tidak ditemukan", async () => {
  const { repository } = makeRepository();

  await withServer(createApp(repository), async (baseUrl) => {
    const response = await fetch(
      `${baseUrl}/api/peminjaman/missing-id`,
      { headers: authHeaders(tokenA) }
    );

    assert.equal(response.status, 404);
  });
});

test("API memberi 500 saat repository gagal", async () => {
  const inMemory = makeRepository().repository;

  const brokenRepository: PeminjamanRepositoryPort = {
    ...inMemory,
    findAll: async () => {
      throw new Error("Simulated database outage");
    },
  };

  await withServer(createApp(brokenRepository), async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/peminjaman`, {
      headers: authHeaders(tokenA),
    });

    const body = await response.json() as {
      success: boolean;
      message: string;
    };

    assert.equal(response.status, 500);
    assert.equal(body.success, false);
    assert.equal(body.message, "Terjadi kesalahan pada server");
  });
});

test("API menolak request tanpa token", async () => {
  const { repository } = makeRepository();

  await withServer(createApp(repository), async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/peminjaman`);

    assert.equal(response.status, 401);
  });
});

test("User B tidak bisa melihat data milik User A", async () => {
  const { repository } = makeRepository([
    { id: "private-a", ...validInput, userId: userA },
  ]);

  await withServer(createApp(repository), async (baseUrl) => {
    const response = await fetch(
      `${baseUrl}/api/peminjaman/private-a`,
      { headers: authHeaders(tokenB) }
    );

    assert.equal(response.status, 404);
  });
});

test("User B tidak bisa mengubah data milik User A", async () => {
  const { repository, getRecords } = makeRepository([
    { id: "private-a", ...validInput, userId: userA },
  ]);

  await withServer(createApp(repository), async (baseUrl) => {
    const response = await fetch(
      `${baseUrl}/api/peminjaman/private-a`,
      {
        method: "PUT",
        headers: {
          ...authHeaders(tokenB),
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ ...validInput, jumlah: 99 }),
      }
    );

    assert.equal(response.status, 404);
    assert.equal(getRecords()[0].jumlah, 2);
  });
});

test("User B tidak bisa menghapus data milik User A", async () => {
  const { repository, getRecords } = makeRepository([
    { id: "private-a", ...validInput, userId: userA },
  ]);

  await withServer(createApp(repository), async (baseUrl) => {
    const response = await fetch(
      `${baseUrl}/api/peminjaman/private-a`,
      {
        method: "DELETE",
        headers: authHeaders(tokenB),
      }
    );

    assert.equal(response.status, 404);
    assert.equal(getRecords().length, 1);
  });
});
