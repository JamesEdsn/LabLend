import { prisma } from "../database.js";
export const peminjamanRepository = {
    findAll() {
        return prisma.peminjaman.findMany({
            orderBy: {
                createdAt: "desc",
            },
        });
    },
    findById(id) {
        return prisma.peminjaman.findUnique({
            where: { id },
        });
    },
    create(data) {
        return prisma.peminjaman.create({
            data,
        });
    },
    update(id, data) {
        return prisma.peminjaman.update({
            where: { id },
            data,
        });
    },
    delete(id) {
        return prisma.peminjaman.delete({
            where: { id },
        });
    },
};
