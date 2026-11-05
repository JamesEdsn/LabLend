export interface AlatInput {
  nama: string;
  kategori: string;
  deskripsi?: string | null;
  stokTotal: number;
  stokTersedia: number;
}

export function isValidAlat(data: unknown): data is AlatInput {
  if (typeof data !== "object" || data === null) {
    return false;
  }

  const item = data as Record<string, unknown>;

  const deskripsiValid =
    item.deskripsi === undefined ||
    item.deskripsi === null ||
    typeof item.deskripsi === "string";

  return (
    typeof item.nama === "string" &&
    item.nama.trim().length > 0 &&
    typeof item.kategori === "string" &&
    item.kategori.trim().length > 0 &&
    deskripsiValid &&
    typeof item.stokTotal === "number" &&
    Number.isInteger(item.stokTotal) &&
    item.stokTotal >= 0 &&
    typeof item.stokTersedia === "number" &&
    Number.isInteger(item.stokTersedia) &&
    item.stokTersedia >= 0 &&
    item.stokTersedia <= item.stokTotal
  );
}