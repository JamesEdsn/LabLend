export class InventoryNotFoundError extends Error {
  constructor(message = "Barang tidak ditemukan di inventaris") {
    super(message);
    this.name = "InventoryNotFoundError";
  }
}

export class InsufficientStockError extends Error {
  constructor(
    public readonly available: number,
    public readonly requested: number,
  ) {
    super(
      `Stok tidak mencukupi. Stok tersedia: ${available}, jumlah diminta: ${requested}`,
    );
    this.name = "InsufficientStockError";
  }
}