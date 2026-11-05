import { prisma } from "../database.js";
import type { AlatInput } from "../models/alat.model.js";

export const alatRepository = {
  findAll() {
    return prisma.alat.findMany({
      orderBy: {
        nama: "asc",
      },
    });
  },

  findById(id: string) {
    return prisma.alat.findUnique({
      where: { id },
    });
  },

  create(data: AlatInput) {
    return prisma.alat.create({
      data: {
        nama: data.nama.trim(),
        kategori: data.kategori.trim(),
        deskripsi: data.deskripsi?.trim() || null,
        stokTotal: data.stokTotal,
        stokTersedia: data.stokTersedia,
      },
    });
  },

  async update(id: string, data: AlatInput) {
    const result = await prisma.alat.updateMany({
      where: { id },
      data: {
        nama: data.nama.trim(),
        kategori: data.kategori.trim(),
        deskripsi: data.deskripsi?.trim() || null,
        stokTotal: data.stokTotal,
        stokTersedia: data.stokTersedia,
      },
    });

    if (result.count === 0) {
      return null;
    }

    return prisma.alat.findUnique({
      where: { id },
    });
  },

  delete(id: string) {
    return prisma.alat.deleteMany({
      where: { id },
    });
  },
};