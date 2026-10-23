import "dotenv/config";
import app from "./app.js";
import { prisma } from "./database.js";

const PORT = Number(process.env.PORT || 3000);

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