
import { Router } from "express";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";

import {
  isValidLoginInput,
  isValidRegisterInput,
} from "../models/user.model.js";

import { userRepository } from "../repositories/user.repository.js";

const router = Router();

// POST /api/auth/register
router.post("/register", async (req, res, next) => {
  try {
    if (!isValidRegisterInput(req.body)) {
      res.status(400).json({
        success: false,
        message: "Data registrasi tidak valid. Pastikan nama, email, dan password sudah benar. Password minimal 8 karakter.",
      });
      return;
    }

    const nama = req.body.nama.trim();
    const email = req.body.email.trim().toLowerCase();

    const existingUser = await userRepository.findByEmail(email);

    if (existingUser) {
      res.status(409).json({
        success: false,
        message: "Email sudah terdaftar",
      });
      return;
    }

    const passwordHash = await bcrypt.hash(req.body.password, 12);

    const user = await userRepository.create({
      nama,
      email,
      passwordHash,
    });

    res.status(201).json({
      success: true,
      message: "Registrasi berhasil",
      data: {
        id: user.id,
        nama: user.nama,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    next(error);
  }
});

// POST /api/auth/login
router.post("/login", async (req, res, next) => {
  try {
    if (!isValidLoginInput(req.body)) {
      res.status(400).json({
        success: false,
        message: "Email atau password tidak valid",
      });
      return;
    }

    const email = req.body.email.trim().toLowerCase();

    const user = await userRepository.findByEmail(email);

    if (!user) {
      res.status(401).json({
        success: false,
        message: "Email atau password salah",
      });
      return;
    }

    const passwordMatch = await bcrypt.compare(
      req.body.password,
      user.passwordHash,
    );

    if (!passwordMatch) {
      res.status(401).json({
        success: false,
        message: "Email atau password salah",
      });
      return;
    }

    const jwtSecret = process.env.JWT_SECRET;

if (!jwtSecret) {
  res.status(500).json({
    success: false,
    message: "Konfigurasi autentikasi server belum tersedia",
  });
  return;
}
    
    const token = jwt.sign(
      {
        userId: user.id,
        role: user.role,
      },
      jwtSecret,
      { expiresIn: "1d" },
    );

    res.json({
      success: true,
      message: "Login berhasil",
      data: {
        token,
        user: {
          id: user.id,
          nama: user.nama,
          email: user.email,
          role: user.role,
        },
      },
    });
  } catch (error) {
    next(error);
  }
});

export default router;
