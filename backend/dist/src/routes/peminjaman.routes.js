import { Router } from "express";
import { peminjamanRepository } from "../repositories/peminjaman.repository.js";
import { isValidPeminjaman } from "../models/peminjaman.model.js";
const router = Router();
// GET /api/peminjaman
router.get("/", async (_req, res, next) => {
    try {
        const data = await peminjamanRepository.findAll();
        res.json({
            success: true,
            data,
        });
    }
    catch (error) {
        next(error);
    }
});
// GET /api/peminjaman/:id
router.get("/:id", async (req, res, next) => {
    try {
        const data = await peminjamanRepository.findById(String(req.params.id));
        if (!data) {
            res.status(404).json({
                success: false,
                message: "Data peminjaman tidak ditemukan",
            });
            return;
        }
        res.json({
            success: true,
            data,
        });
    }
    catch (error) {
        next(error);
    }
});
// POST /api/peminjaman
router.post("/", async (req, res, next) => {
    try {
        if (!isValidPeminjaman(req.body)) {
            res.status(400).json({
                success: false,
                message: "Data peminjaman tidak valid",
            });
            return;
        }
        const data = await peminjamanRepository.create(req.body);
        res.status(201).json({
            success: true,
            data,
        });
    }
    catch (error) {
        next(error);
    }
});
// PUT /api/peminjaman/:id
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
        const existing = await peminjamanRepository.findById(id);
        if (!existing) {
            res.status(404).json({
                success: false,
                message: "Data peminjaman tidak ditemukan",
            });
            return;
        }
        const data = await peminjamanRepository.update(id, req.body);
        res.json({
            success: true,
            data,
        });
    }
    catch (error) {
        next(error);
    }
});
// DELETE /api/peminjaman/:id
router.delete("/:id", async (req, res, next) => {
    try {
        const id = String(req.params.id);
        const existing = await peminjamanRepository.findById(id);
        if (!existing) {
            res.status(404).json({
                success: false,
                message: "Data peminjaman tidak ditemukan",
            });
            return;
        }
        await peminjamanRepository.delete(id);
        res.json({
            success: true,
            message: "Data peminjaman berhasil dihapus",
        });
    }
    catch (error) {
        next(error);
    }
});
export default router;
