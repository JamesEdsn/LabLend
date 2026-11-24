
import { prisma } from "../database.js";
import type { PeminjamanInput } from "../models/peminjaman.model.js";
import {
  InsufficientStockError,
  InventoryNotFoundError,
} from "../models/stock-error.model.js";

export const peminjamanRepository = {
  findAll(userId: string) {
    return prisma.peminjaman.findMany({
      where: { userId },
      orderBy: { createdAt: "desc" },
    });
  },

  findById(id: string, userId: string) {
    return prisma.peminjaman.findFirst({
      where: { id, userId },
    });
  },

  // CREATE: cek dan kurangi stok dalam satu transaksi.
  create(data: PeminjamanInput, userId: string) {
    return prisma.$transaction(async (tx) => {
      const alat = await tx.alat.findUnique({
        where: { nama: data.alat.trim() },
      });

      if (!alat) {
        throw new InventoryNotFoundError();
      }

      const stockUpdate = await tx.alat.updateMany({
        where: {
          id: alat.id,
          stokTersedia: { gte: data.jumlah },
        },
        data: {
          stokTersedia: { decrement: data.jumlah },
        },
      });

      if (stockUpdate.count === 0) {
        const latestAlat = await tx.alat.findUnique({
          where: { id: alat.id },
        });

        throw new InsufficientStockError(
          latestAlat?.stokTersedia ?? 0,
          data.jumlah,
        );
      }

      return tx.peminjaman.create({
        data: {
          ...data,
          alat: alat.nama,
          alatId: alat.id,
          userId,
        },
      });
    });
  },

  // UPDATE: sesuaikan stok jika jumlah atau alat berubah.
  update(id: string, data: PeminjamanInput, userId: string) {
    return prisma.$transaction(async (tx) => {
      const current = await tx.peminjaman.findFirst({
        where: { id, userId },
      });

      if (!current) {
        return null;
      }

      const newAlat = await tx.alat.findUnique({
        where: { nama: data.alat.trim() },
      });

      if (!newAlat) {
        throw new InventoryNotFoundError();
      }

      if (current.alatId === newAlat.id) {
        const difference = data.jumlah - current.jumlah;

        console.log("=== DEBUG UPDATE PEMINJAMAN ===");
        console.log("Jumlah lama:", current.jumlah);
        console.log("Jumlah baru:", data.jumlah);
        console.log("Selisih:", difference);
        console.log("Alat ID lama:", current.alatId);
        console.log("Alat ID baru:", newAlat.id);

        if (difference > 0) {
          const stockUpdate = await tx.alat.updateMany({
            where: {
              id: newAlat.id,
              stokTersedia: { gte: difference },
            },
            data: {
              stokTersedia: { decrement: difference },
            },
          });

          if (stockUpdate.count === 0) {
            const latestAlat = await tx.alat.findUnique({
              where: { id: newAlat.id },
            });

            throw new InsufficientStockError(
              latestAlat?.stokTersedia ?? 0,
              difference,
            );
          }
        } else if (difference < 0) {
          await tx.alat.update({
            where: { id: newAlat.id },
            data: {
              stokTersedia: { increment: Math.abs(difference) },
            },
          });
        }
      } else {
        // Kembalikan stok alat sebelumnya jika relasinya tersedia.
        if (current.alatId) {
          await tx.alat.update({
            where: { id: current.alatId },
            data: {
              stokTersedia: { increment: current.jumlah },
            },
          });
        }

        // Kurangi stok alat yang baru dipilih.
        const stockUpdate = await tx.alat.updateMany({
          where: {
            id: newAlat.id,
            stokTersedia: { gte: data.jumlah },
          },
          data: {
            stokTersedia: { decrement: data.jumlah },
          },
        });

        if (stockUpdate.count === 0) {
          const latestAlat = await tx.alat.findUnique({
            where: { id: newAlat.id },
          });

          throw new InsufficientStockError(
            latestAlat?.stokTersedia ?? 0,
            data.jumlah,
          );
        }
      }

      await tx.peminjaman.update({
        where: { id },
        data: {
          ...data,
          alat: newAlat.nama,
          alatId: newAlat.id,
        },
      });

      return tx.peminjaman.findFirst({
        where: { id, userId },
      });
    });
  },

  // DELETE: hapus data dan kembalikan stok.
  delete(id: string, userId: string) {
    return prisma.$transaction(async (tx) => {
      const current = await tx.peminjaman.findFirst({
        where: { id, userId },
      });

      if (!current) {
        return { count: 0 };
      }

      const result = await tx.peminjaman.deleteMany({
        where: { id, userId },
      });

      if (result.count > 0 && current.alatId) {
        await tx.alat.update({
          where: { id: current.alatId },
          data: {
            stokTersedia: { increment: current.jumlah },
          },
        });
      }

      return result;
    });
  },
};
