import "dotenv/config";
import { createApp } from "./app.js";
import { prisma } from "./database.js";
import { peminjamanRepository } from "./repositories/peminjaman.repository.js";

const PORT = Number(process.env.PORT || 3000);
const app = createApp(peminjamanRepository);

const server = app.listen(PORT, () => {
  console.log(`LabLend API berjalan di http://localhost:${PORT}`);
});

async function shutdown() {
  console.log("Menutup LabLend API...");

  server.close(async () => {
    await prisma.$disconnect();
    process.exit(0);
  });
}

process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);