// src/viewmodels/admin/AdminDashboardViewModel.js
import { useState } from "react";

const useAdminDashboardViewModel = () => {
  const [activeSection, setActiveSection] = useState("overview");

  const menuItems = [
    { id: "overview", label: "Vue d'ensemble" },
    { id: "courses", label: "Cours" },
    { id: "users", label: "Utilisateurs" },
    { id: "payments", label: "Paiements" },
    { id: "promotions", label: "Promotions" },
  ];

  return {
    activeSection,
    setActiveSection,
    menuItems,
  };
};

export default useAdminDashboardViewModel;
