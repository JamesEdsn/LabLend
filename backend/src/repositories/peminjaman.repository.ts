import { prisma } from "../database.js";
import type { PeminjamanInput } from "../models/peminjaman.model.js";

export const peminjamanRepository = {
  findAll() {
    return prisma.peminjaman.findMany({
      orderBy: {
        createdAt: "desc",
      },
    });
  },

  findById(id: string) {
    return prisma.peminjaman.findUnique({
      where: { id },
    });
  },

  create(data: PeminjamanInput) {
    return prisma.peminjaman.create({
      data,
    });
  },

  update(id: string, data: PeminjamanInput) {
    return prisma.peminjaman.update({
      where: { id },
      data,
    });
  },

  delete(id: string) {
    return prisma.peminjaman.delete({
      where: { id },
    });
  },
};