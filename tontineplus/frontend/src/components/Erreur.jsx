export default function Erreur({ message }) {
  if (!message) return null;
  return (
    <p role="alert" className="mb-4 rounded border border-red-200 bg-red-50 p-3 text-sm text-red-800">
      {message}
    </p>
  );
}
