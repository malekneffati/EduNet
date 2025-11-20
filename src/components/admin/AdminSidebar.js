// src/components/admin/AdminSidebar.jsx
import React from "react";
import { FaHome, FaBook, FaUsers, FaDollarSign, FaTags } from "react-icons/fa";

const AdminSidebar = ({ activeSection, onSelect }) => {
  const menuItems = [
    { id: "overview", label: "Vue d'ensemble", icon: <FaHome /> },
    { id: "courses", label: "Cours", icon: <FaBook /> },
    { id: "users", label: "Utilisateurs", icon: <FaUsers /> },
    { id: "payments", label: "Paiements", icon: <FaDollarSign /> },
    { id: "promotions", label: "Promotions", icon: <FaTags /> },
  ];

  return (
    <aside className="w-64 bg-blue-900 text-white p-6">
      <h2 className="text-2xl font-bold mb-8">Admin Panel</h2>
      <nav>
        {menuItems.map((item) => (
          <button
            key={item.id}
            onClick={() => onSelect(item.id)}
            className={`w-full flex items-center space-x-3 px-4 py-3 rounded-lg mb-2 transition-colors ${
              activeSection === item.id
                ? "bg-blue-700 text-white"
                : "hover:bg-blue-800"
            }`}
          >
            {item.icon}
            <span>{item.label}</span>
          </button>
        ))}
      </nav>
    </aside>
  );
};

export default AdminSidebar;
