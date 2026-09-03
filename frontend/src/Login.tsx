/**
 * Formulario de login (demo).
 *
 * Versión base segura. Las ramas de feature introducirán variantes con
 * problemas intencionales para demostrar el gate de Copilot code review.
 */
import React, { useState } from "react";

export function Login() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    try {
      const res = await fetch("/api/login", {
        method: "POST",
        body: JSON.stringify({ email, password }),
      });
      if (!res.ok) {
        setError("No se pudo iniciar sesión");
      }
    } catch {
      setError("Error de red");
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input type="text" value={email} onChange={(e) => setEmail(e.target.value)} placeholder="Email" />
      <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} placeholder="Password" />
      <button type="submit">Entrar</button>
      {error && <p role="alert">{error}</p>}
    </form>
  );
}
