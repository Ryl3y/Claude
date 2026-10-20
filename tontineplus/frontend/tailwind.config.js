/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,jsx}"],
  theme: {
    extend: {
      // Couleurs de la marque TONTINE+ (voir tontineplus/marque/).
      colors: {
        marque: {
          50: "#FBF1EA",
          100: "#F5DCCB",
          200: "#E3AE90",
          600: "#9A4322",
          700: "#82381C",
          800: "#6E2F18",
          900: "#5A2614",
        },
        or: "#E9A23B",
        ivoire: "#F6EBDD",
      },
    },
  },
  plugins: [],
};
