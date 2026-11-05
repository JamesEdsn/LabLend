-- AlterTable
ALTER TABLE `peminjaman` ADD COLUMN `alatId` VARCHAR(191) NULL;

-- CreateTable
CREATE TABLE `alat` (
    `id` VARCHAR(191) NOT NULL,
    `nama` VARCHAR(191) NOT NULL,
    `kategori` VARCHAR(191) NOT NULL,
    `deskripsi` TEXT NULL,
    `stokTotal` INTEGER NOT NULL DEFAULT 0,
    `stokTersedia` INTEGER NOT NULL DEFAULT 0,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    UNIQUE INDEX `alat_nama_key`(`nama`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateIndex
CREATE INDEX `peminjaman_alatId_idx` ON `peminjaman`(`alatId`);

-- AddForeignKey
ALTER TABLE `peminjaman` ADD CONSTRAINT `peminjaman_alatId_fkey` FOREIGN KEY (`alatId`) REFERENCES `alat`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;
