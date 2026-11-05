import { Router } from "express";
import type { AlatInput } from "../models/alat.model.js";
import { isValidAlat } from "../models/alat.model.js";
import { requireAuth } from "../middleware/auth.middleware.js";

export interface AlatRecord extends AlatInput {
  id: string;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface AlatRepositoryPort {
  findAll(): Promise<AlatRecord[]>;
  findById(id: string): Promise<AlatRecord | null>;
  create(data: AlatInput): Promise<AlatRecord>;
  update(id: string, data: AlatInput): Promise<AlatRecord | null>;
  delete(id: string): Promise<{ count: number }>;
}

export function createAlatRouter(repository: AlatRepositoryPort): Router {
  const router = Router();

  // Semua endpoint inventaris wajib menggunakan JWT.
  router.use(requireAuth);

  // Hanya ASLAB yang boleh mengelola inventaris.
  function requireAslab(
    req: import("express").Request,
    res: import("express").Response,
    next: import("express").NextFunction,
  ) {
    if (req.auth?.role !== "ASLAB") {
      res.status(403).json({
        success: false,
        message: "Akses hanya tersedia untuk asisten laboratorium",
      });
      return;
    }

    next();
  }

  // GET: mengambil seluruh data inventaris.
  router.get("/", async (_req, res, next) => {
    try {
      const data = await repository.findAll();
      res.json({ success: true, data });
    } catch (error) {
      next(error);
    }
  });

  // GET: mengambil detail satu alat.
  router.get("/:id", async (req, res, next) => {
    try {
      const id = String(req.params.id);
      const data = await repository.findById(id);

      if (!data) {
        res.status(404).json({
          success: false,
          message: "Data alat tidak ditemukan",
        });
        return;
      }

      res.json({ success: true, data });
    } catch (error) {
      next(error);
    }
  });

  // POST: menambahkan alat baru. Khusus ASLAB.
  router.post("/", requireAslab, async (req, res, next) => {
    try {
      if (!isValidAlat(req.body)) {
        res.status(400).json({
          success: false,
          message: "Data alat tidak valid",
        });
        return;
      }

      const data = await repository.create(req.body);

      res.status(201).json({
        success: true,
        message: "Alat berhasil ditambahkan",
        data,
      });
    } catch (error) {
      next(error);
    }
  });

  // PUT: memperbarui data alat. Khusus ASLAB.
  router.put("/:id", requireAslab, async (req, res, next) => {
    try {
      if (!isValidAlat(req.body)) {
        res.status(400).json({
          success: false,
          message: "Data alat tidak valid",
        });
        return;
      }

      const id = String(req.params.id);
      const data = await repository.update(id, req.body);

      if (!data) {
        res.status(404).json({
          success: false,
          message: "Data alat tidak ditemukan",
        });
        return;
      }

      res.json({
        success: true,
        message: "Data alat berhasil diperbarui",
        data,
      });
    } catch (error) {
      next(error);
    }
  });

  // DELETE: menghapus alat. Khusus ASLAB.
  router.delete("/:id", requireAslab, async (req, res, next) => {
    try {
      const id = String(req.params.id);
      const result = await repository.delete(id);

      if (result.count === 0) {
        res.status(404).json({
          success: false,
          message: "Data alat tidak ditemukan",
        });
        return;
      }

      res.json({
        success: true,
        message: "Alat berhasil dihapus",
      });
    } catch (error) {
      next(error);
    }
  });

  return router;
}