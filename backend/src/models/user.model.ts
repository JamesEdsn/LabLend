export interface RegisterInput {
  nama: string;
  email: string;
  password: string;
}

export interface LoginInput {
  email: string;
  password: string;
}

export function isValidRegisterInput(
  data: unknown,
): data is RegisterInput {
  if (typeof data !== "object" || data === null) {
    return false;
  }

  const item = data as Record<string, unknown>;

  return (
    typeof item.nama === "string" &&
    item.nama.trim().length >= 2 &&
    typeof item.email === "string" &&
    /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(item.email.trim()) &&
    typeof item.password === "string" &&
    item.password.length >= 8
  );
}

export function isValidLoginInput(
  data: unknown,
): data is LoginInput {
  if (typeof data !== "object" || data === null) {
    return false;
  }

  const item = data as Record<string, unknown>;

  return (
    typeof item.email === "string" &&
    /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(item.email.trim()) &&
    typeof item.password === "string" &&
    item.password.length > 0
  );
}