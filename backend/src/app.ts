import express from "express";
import cors from "cors";

import authRouter from "./routes/auth.routes.js";

import {
  createPeminjamanRouter,
  type PeminjamanRepositoryPort,
} from "./routes/peminjaman.routes.js";

import {
  createAlatRouter,
  type AlatRepositoryPort,
} from "./routes/alat.routes.js";

/** Membuat aplikasi Express dengan repository yang bisa diganti saat testing. */
export function createApp(
  repository: PeminjamanRepositoryPort,
  alatRepository?: AlatRepositoryPort,
) {
  const app = express();

  app.use(cors());
  app.use(express.json());

  app.get("/", (_req, res) => {
    res.json({
      success: true,
      message: "LabLend API is running",
    });
  });

  // Authentication
  app.use("/api/auth", authRouter);

  // Peminjaman API
  app.use("/api/peminjaman", createPeminjamanRouter(repository));

  // Inventory API
  // Dipasang jika repository inventaris tersedia.
  if (alatRepository) {
    app.use("/api/alat", createAlatRouter(alatRepository));
  }

  // JSON rusak adalah kesalahan input dari klien (400), bukan server error (500).
  app.use(
    (
      error: unknown,
      _req: express.Request,
      res: express.Response,
      _next: express.NextFunction,
    ) => {
      if (
        typeof error === "object" &&
        error !== null &&
        "type" in error &&
        error.type === "entity.parse.failed"
      ) {
        res.status(400).json({
          success: false,
          message: "Format JSON tidak valid",
        });
        return;
      }

      console.error(error);
      res.status(500).json({
        success: false,
        message: "Terjadi kesalahan pada server",
      });
    },
  );

  return app;
}