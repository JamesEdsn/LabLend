import express from "express";
import cors from "cors";
import peminjamanRoutes from "./routes/peminjaman.routes.js";

const app = express();

app.use(cors());
app.use(express.json());

app.get("/", (_req, res) => {
  res.json({
    success: true,
    message: "LabLend API is running",
  });
});

app.use("/api/peminjaman", peminjamanRoutes);

app.use(
  (
    error: unknown,
    _req: express.Request,
    res: express.Response,
    _next: express.NextFunction,
  ) => {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Terjadi kesalahan pada server",
    });
  },
);

export default app;