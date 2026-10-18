import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// En développement, /api est relayé vers le backend Django : pas besoin de CORS.
const proxy = { "/api": process.env.VITE_BACKEND ?? "http://127.0.0.1:8000" };

export default defineConfig({
  plugins: [react()],
  server: { proxy },
  preview: { proxy },
});
