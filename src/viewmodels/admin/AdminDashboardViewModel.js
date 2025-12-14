// src/viewmodels/admin/AdminDashboardViewModel.js
import { useState } from "react";
import { db } from "../../firebaseConfig";
import { collection, getCountFromServer, getDocs } from "firebase/firestore";

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

// Fonction pour récupérer les statistiques du dashboard
export const getStats = async () => {
  try {
    // Nombre total d'utilisateurs
    const usersSnap = await getCountFromServer(collection(db, "users"));

    // Nombre total de cours
    const coursesSnap = await getCountFromServer(collection(db, "courses"));

    // Paiements pour calculer revenus et ventes totales
    const paiementsSnap = await getDocs(collection(db, "paiements"));

    let totalRevenue = 0;
    let totalSales = 0;
    paiementsSnap.forEach((doc) => {
      const data = doc.data();
      totalRevenue += data.montant || 0; // somme des montants
      totalSales += 1; // chaque document = une vente
    });

    return {
      totalUsers: usersSnap.data().count,
      totalCourses: coursesSnap.data().count,
      totalRevenue,
      totalSales,
    };
  } catch (error) {
    console.error("Erreur dashboard :", error);
    return {
      totalUsers: 0,
      totalCourses: 0,
      totalRevenue: 0,
      totalSales: 0,
    };
  }
};

export default useAdminDashboardViewModel;
