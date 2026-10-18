import { BrowserRouter as Router, Navigate, Route, Routes } from "react-router-dom";
import { AuthProvider, RouteProtegee } from "./auth";
import Navbar from "./components/Navbar";
import AcceptInvitation from "./pages/AcceptInvitation";
import CreateGroup, { EditGroup } from "./pages/CreateGroup";
import Dashboard from "./pages/Dashboard";
import GroupDetails from "./pages/GroupDetails";
import Login from "./pages/Login";
import Register from "./pages/Register";

function App() {
  return (
    <AuthProvider>
      <Router>
        <div className="min-h-screen bg-gray-100">
          <Navbar />
          <main className="mx-auto max-w-4xl px-4 py-6">
            <Routes>
              <Route path="/" element={<RouteProtegee><Dashboard /></RouteProtegee>} />
              <Route path="/login" element={<Login />} />
              <Route path="/register" element={<Register />} />
              <Route path="/create-group" element={<RouteProtegee><CreateGroup /></RouteProtegee>} />
              <Route path="/group/:id" element={<RouteProtegee><GroupDetails /></RouteProtegee>} />
              <Route path="/group/:id/modifier" element={<RouteProtegee><EditGroup /></RouteProtegee>} />
              <Route path="/invitation/:code" element={<RouteProtegee><AcceptInvitation /></RouteProtegee>} />
              <Route path="*" element={<Navigate to="/" replace />} />
            </Routes>
          </main>
        </div>
      </Router>
    </AuthProvider>
  );
}

export default App;
