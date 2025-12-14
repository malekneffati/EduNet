// src/pages/AdminDashboard.jsx
import React, { useEffect, useState } from "react";
import AdminSidebar from "../components/admin/AdminSidebar";
import AdminHeader from "../components/admin/AdminHeader";
import StatCard from "../components/admin/StatCard";
import UserManagement from "../components/admin/UserManagement";
import CourseManagement from "../components/admin/CourseManagement";
import PaymentList from "../components/admin/PaymentList";
import AdminSubscriptions from "../components/admin/Subscription";
import MonthlySalesDualChart from "../components/admin/MonthlySalesDualChart";
import { FaUsers, FaBook, FaDollarSign, FaCrown } from "react-icons/fa";
import useAdminDashboardViewModel, {
  getStats,
} from "../viewmodels/admin/AdminDashboardViewModel";
import { onAuthStateChanged } from "firebase/auth";
import { auth } from "../firebaseConfig";

const AdminDashboard = () => {
  const { activeSection, setActiveSection } = useAdminDashboardViewModel();
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalCourses: 0,
    totalRevenue: 0,
    totalSales: 0,
  });

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (user) {
        const result = await getStats();
        setStats(result);
      } else {
        // reset important pour éviter les données fantômes
        setStats({
          totalUsers: 0,
          totalCourses: 0,
          totalRevenue: 0,
          totalSales: 0,
        });
      }
    });

    return () => unsubscribe();
  }, []);


  const renderSection = () => {
    switch (activeSection) {
      case "overview":
        return (
          <>
            <AdminHeader title="Dashboard Administrateur" />
            <div className="grid md:grid-cols-4 gap-6 mb-8">
              <StatCard
                icon={<FaUsers />}
                value={stats.totalUsers}
                label="Utilisateurs totaux"
                color="blue"
              />
              <StatCard
                icon={<FaBook />}
                value={stats.totalCourses}
                label="Cours disponibles"
                color="green"
              />
              <StatCard
                icon={<FaDollarSign />}
                value={stats.totalRevenue.toLocaleString()}
                label="Revenus (TND)"
                color="purple"
              />
              <StatCard
                icon={<FaCrown />}
                value={stats.totalSales}
                label="Ventes totales"
                color="orange"
              />
            </div>
            <div className="grid md:grid-cols-1 gap-8">
              <div className="bg-white rounded-lg shadow-md p-6">
                <h3 className="text-lg font-semibold mb-4 text-center">
                  Ventes mensuelles
                </h3>
                <MonthlySalesDualChart />
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
        return (
          <>
            <AdminHeader title="Gestion des paiements" />
            <PaymentList />
          </>
        );
      case "promotions":
        return (
          <>
            <AdminHeader title="Gestion des paiements" />
            <AdminSubscriptions />
          </>
        );

      default:
        return null;
    }
  };

  return (
    <div className="flex h-screen bg-gray-50">
      <AdminSidebar activeSection={activeSection} onSelect={setActiveSection} />
      <div className="flex-1 overflow-auto p-8">{renderSection()}</div>
    </div>
  );
};

export default AdminDashboard;
