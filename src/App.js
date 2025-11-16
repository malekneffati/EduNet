import React from "react";
import { Routes, Route } from "react-router-dom";
import Navbar from "./components/Navbar";
import Footer from "./components/Footer";
import Home from "./pages/Home";
import Catalog from "./pages/Catalog";
import Login from "./pages/Login";
import Dashboard from "./pages/Dashboard";
import AdminDashboard from "./pages/AdminDashboard";
import CourseDetails from "./pages/CourseDetails";
import CourseContent from "./pages/CourseContent";
import PrivateRoute from "./components/auth/privateRoute";

function App() {
  const [role, setRole] = React.useState(localStorage.getItem("role") || null);
  const updateRole = (newRole) => {
    localStorage.setItem("role", newRole);
    setRole(newRole);
  };

  return (
    <div className="font-opensans bg-gray-50">
      <Navbar role={role} setRole={setRole} />

      <main id="main-content">
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/login" element={<Login updateRole={updateRole} />} />
          <Route path="/catalog" element={<Catalog />} />
          <Route
            path="/dashboard"
            element={
              <PrivateRoute requiredRole="student">
                <Dashboard />
              </PrivateRoute>
            }
          />
          <Route
            path="/admin-dashboard"
            element={
              <PrivateRoute requiredRole="admin">
                <AdminDashboard />
              </PrivateRoute>
            }
          />
          <Route path="/course/:id/details" element={<CourseDetails />} />
          <Route path="/course/:id/content" element={<CourseContent />} />
        </Routes>
      </main>
      <Footer />
    </div>
  );
}

export default App;
