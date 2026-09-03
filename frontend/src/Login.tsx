/**
 * Formulario de login (demo).
 *
 * NOTA: Este archivo contiene problemas intencionales para que Copilot code
 * review los detecte durante la demo. No usar como referencia de buenas
 * prácticas.
 */
import React, { useState } from "react";

interface LoginProps {
  welcomeHtml: string;
}

export function Login({ welcomeHtml }: LoginProps) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState<any>("");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    // Problema 1: se loguea la contraseña en texto plano.
    console.log("Intentando login con", email, password);

    // Problema 2: fetch sin manejo de error (sin catch, sin chequeo de status).
    fetch("/api/login", {
      method: "POST",
      body: JSON.stringify({ email, password }),
    }).then((res) => res.json());

    // Problema 3: se guarda la contraseña en localStorage.
    window.localStorage.setItem("last_password_used", password);
  };

  return (
    <div>
      {/* Problema 4: dangerouslySetInnerHTML sin sanitizar contenido que
          podría venir del servidor o de otro usuario. */}
      <div dangerouslySetInnerHTML={{ __html: welcomeHtml }} />

      <form onSubmit={handleSubmit}>
        <input
          type="text"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="Email"
        />
        {/* Problema 5: campo de contraseña sin type="password". */}
        <input
          type="text"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="Password"
        />
        <button type="submit">Entrar</button>
      </form>
    </div>
  );
}
