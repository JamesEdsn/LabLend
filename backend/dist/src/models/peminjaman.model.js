export function isValidPeminjaman(data) {
    if (typeof data !== "object" || data === null) {
        return false;
    }
    const item = data;
    return (typeof item.alat === "string" &&
        item.alat.trim().length > 0 &&
        typeof item.jumlah === "number" &&
        Number.isInteger(item.jumlah) &&
        item.jumlah > 0 &&
        typeof item.tanggalKembali === "string" &&
        /^\d{4}-\d{2}-\d{2}$/.test(item.tanggalKembali) &&
        !Number.isNaN(Date.parse(`${item.tanggalKembali}T00:00:00Z`)) &&
        new Date(`${item.tanggalKembali}T00:00:00Z`)
            .toISOString()
            .startsWith(item.tanggalKembali));
}
