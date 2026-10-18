/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,jsx}"],
  theme: {
    extend: {
      // Couleurs de la marque TONTINE+ (voir tontineplus/marque/).
      colors: {
        marque: {
          50: "#EEF6F1",
          100: "#D6EBDF",
          200: "#A8D2BB",
          600: "#0E5A3C",
          700: "#0B4A31",
          800: "#0A3D29",
          900: "#0A2E22",
        },
        or: "#E8A93B",
        ivoire: "#FBF6EC",
      },
    },
  },
  plugins: [],
};
