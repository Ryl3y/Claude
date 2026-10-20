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
          200: "#EBB99A",
          600: "#B4532A",
          700: "#96421F",
          800: "#763418",
          900: "#5A2614",
        },
        or: "#E9A23B",
        ivoire: "#F6EBDD",
      },
    },
  },
  plugins: [],
};
