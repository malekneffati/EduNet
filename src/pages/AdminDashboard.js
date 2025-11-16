// src/pages/AdminDashboard.jsx
import React, { useState } from "react";
import AdminSidebar from "../components/admin/AdminSidebar";
import AdminHeader from "../components/admin/AdminHeader";
import StatCard from "../components/admin/StatCard";
import UserManagement from "../components/admin/UserManagement";
import CourseManagement from "../components/admin/CourseManagement";
import { FaUsers, FaBook, FaDollarSign, FaCrown } from "react-icons/fa";

const AdminDashboard = () => {
  const [activeSection, setActiveSection] = useState("overview");

  const renderSection = () => {
    switch (activeSection) {
      case "overview":
        return (
          <>
            <AdminHeader title="Dashboard Administrateur" />

            {/* Statistiques */}
            <div className="grid md:grid-cols-4 gap-6 mb-8">
              <StatCard
                icon={<FaUsers />}
                value="1,234"
                label="Utilisateurs totaux"
                color="blue"
              />
              <StatCard
                icon={<FaBook />}
                value="45"
                label="Cours disponibles"
                color="green"
              />
              <StatCard
                icon={<FaDollarSign />}
                value="12,450"
                label="Revenus (TND)"
                color="purple"
              />
              <StatCard
                icon={<FaCrown />}
                value="567"
                label="Abonnements actifs"
                color="orange"
              />
            </div>

            {/* Graphiques placeholders */}
            <div className="grid md:grid-cols-2 gap-8">
              <div className="bg-white rounded-lg shadow-md p-6">
                <h3 className="text-lg font-semibold mb-4">
                  Ventes mensuelles
                </h3>
                <div className="h-64 bg-gray-100 rounded-lg flex items-center justify-center text-gray-500">
                  Graphique des ventes
                </div>
              </div>
              <div className="bg-white rounded-lg shadow-md p-6">
                <h3 className="text-lg font-semibold mb-4">
                  Activité des utilisateurs
                </h3>
                <div className="h-64 bg-gray-100 rounded-lg flex items-center justify-center text-gray-500">
                  Graphique d'activité
                </div>
              </div>
            </div>
          </>
        );

      case "courses":
        return (
          <>
            <AdminHeader title="Gestion des cours" />
            <CourseManagement />
          </>
        );

      case "users":
        return (
          <>
            <AdminHeader title="Gestion des utilisateurs" />
            <UserManagement />
          </>
        );

      case "payments":
        return <AdminHeader title="Gestion des paiements" />;

      case "promotions":
        return <AdminHeader title="Promotions" />;

      default:
        return null;
    }
  };

  return (
    <div className="flex h-screen bg-gray-50">
      {/* Sidebar */}
      <AdminSidebar activeSection={activeSection} onSelect={setActiveSection} />

      {/* Main content */}
      <div className="flex-1 overflow-auto p-8">{renderSection()}</div>
    </div>
  );
};

export default AdminDashboard;
