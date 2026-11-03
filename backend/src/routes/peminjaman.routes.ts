
import { Router } from "express";
import type { PeminjamanInput } from "../models/peminjaman.model.js";
import { isValidPeminjaman } from "../models/peminjaman.model.js";
import { requireAuth } from "../middleware/auth.middleware.js";

export interface PeminjamanRecord extends PeminjamanInput {
  id: string;
  userId: string | null;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface PeminjamanRepositoryPort {
  findAll(userId: string): Promise<PeminjamanRecord[]>;
  findById(id: string, userId: string): Promise<PeminjamanRecord | null>;
  create(data: PeminjamanInput, userId: string): Promise<PeminjamanRecord>;
  update(
    id: string,
    data: PeminjamanInput,
    userId: string
  ): Promise<PeminjamanRecord | null>;
  delete(id: string, userId: string): Promise<{ count: number }>;
}

export function createPeminjamanRouter(
  repository: PeminjamanRepositoryPort
): Router {
  const router = Router();

  // Semua endpoint peminjaman wajib menggunakan token JWT.
  router.use(requireAuth);

  // GET: mengambil data milik user yang sedang login.
  router.get("/", async (req, res, next) => {
    try {
      const data = await repository.findAll(req.auth!.userId);
      res.json({ success: true, data });
    } catch (error) {
      next(error);
    }
  });

  // GET: mengambil satu data milik user yang sedang login.
  router.get("/:id", async (req, res, next) => {
    try {
      const id = String(req.params.id);
      const data = await repository.findById(id, req.auth!.userId);

      if (!data) {
        res.status(404).json({
          success: false,
          message: "Data peminjaman tidak ditemukan",
        });
        return;
      }

      res.json({ success: true, data });
    } catch (error) {
      next(error);
    }
  });

  // POST: membuat data baru untuk user yang sedang login.
  router.post("/", async (req, res, next) => {
    try {
      if (!isValidPeminjaman(req.body)) {
        res.status(400).json({
          success: false,
          message: "Data peminjaman tidak valid",
        });
        return;
      }

      const data = await repository.create(req.body, req.auth!.userId);

      res.status(201).json({
        success: true,
        message: "Peminjaman berhasil ditambahkan",
        data,
      });
    } catch (error) {
      next(error);
    }
  });

  // PUT: hanya dapat mengubah data milik user yang sedang login.
  router.put("/:id", async (req, res, next) => {
    try {
      if (!isValidPeminjaman(req.body)) {
        res.status(400).json({
          success: false,
          message: "Data peminjaman tidak valid",
        });
        return;
      }

      const id = String(req.params.id);
      const data = await repository.update(
        id,
        req.body,
        req.auth!.userId
      );

      if (!data) {
        res.status(404).json({
          success: false,
          message: "Data peminjaman tidak ditemukan",
        });
        return;
      }

      res.json({
        success: true,
        message: "Peminjaman berhasil diperbarui",
        data,
      });
    } catch (error) {
      next(error);
    }
  });

  // DELETE: hanya dapat menghapus data milik user yang sedang login.
  router.delete("/:id", async (req, res, next) => {
    try {
      const id = String(req.params.id);
      const result = await repository.delete(id, req.auth!.userId);

      if (result.count === 0) {
        res.status(404).json({
          success: false,
          message: "Data peminjaman tidak ditemukan",
        });
        return;
      }

      res.json({
        success: true,
        message: "Peminjaman berhasil dihapus",
      });
    } catch (error) {
      next(error);
    }
  });

  return router;
}
