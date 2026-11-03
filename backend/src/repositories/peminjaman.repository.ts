import { prisma } from "../database.js";
import type { PeminjamanInput } from "../models/peminjaman.model.js";

export const peminjamanRepository = {
  findAll(userId: string) {
    return prisma.peminjaman.findMany({
      where: { userId },
      orderBy: {
        createdAt: "desc",
      },
    });
  },

  findById(id: string, userId: string) {
    return prisma.peminjaman.findFirst({
      where: {
        id,
        userId,
      },
    });
  },

  create(data: PeminjamanInput, userId: string) {
    return prisma.peminjaman.create({
      data: {
        ...data,
        userId,
      },
    });
  },

  async update(
    id: string,
    data: PeminjamanInput,
    userId: string,
  ) {
    const result = await prisma.peminjaman.updateMany({
      where: {
        id,
        userId,
      },
      data,
    });

    if (result.count === 0) {
      return null;
    }

    return prisma.peminjaman.findFirst({
      where: {
        id,
        userId,
      },
    });
  },

  delete(id: string, userId: string) {
    return prisma.peminjaman.deleteMany({
      where: {
        id,
        userId,
      },
    });
  },
};