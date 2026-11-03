
import { prisma } from "../database.js";

export const userRepository = {
  findByEmail(email: string) {
    return prisma.user.findUnique({
      where: { email },
    });
  },

  findById(id: string) {
    return prisma.user.findUnique({
      where: { id },
    });
  },

  create(data: {
    nama: string;
    email: string;
    passwordHash: string;
  }) {
    return prisma.user.create({
      data: {
        nama: data.nama,
        email: data.email,
        passwordHash: data.passwordHash,
        // Role otomatis STUDENT sesuai default Prisma.
      },
    });
  },
};
