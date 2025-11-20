import React, { useState, useEffect } from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Navbar from "./components/home/Navbar";
import Footer from "./components/home/Footer";
import PrivateRoute from "./components/auth/PrivateRoute";
import Home from "./views/Home";
import Login from "./views/Login";
import Dashboard from "./views/Dashboard";
import AdminDashboard from "./views/AdminDashboard";
import Catalog from "./views/Catalog";
import CourseDetails from "./views/CourseDetails";
import CourseContent from "./views/CourseContent";

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
