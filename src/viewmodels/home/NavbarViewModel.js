import { useNavigate } from "react-router-dom";
import { signOut, onAuthStateChanged } from "firebase/auth";
import { auth } from "../../firebaseConfig";
import { useState, useEffect } from "react";

export default function useNavbarViewModel() {
  const navigate = useNavigate();
  const [user, setUser] = useState(null); // utilisateur connecté
  const [role, setRole] = useState(null); // rôle si nécessaire

  // Surveille l'état de l'utilisateur
  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (currentUser) => {
      if (currentUser) {
        setUser(currentUser);
        setRole("student"); // par défaut "student", ou récupère depuis DB
      } else {
        setUser(null);
        setRole(null);
      }
    });
    return () => unsubscribe();
  }, []);

  const handleLogout = async () => {
    try {
      await signOut(auth);
      setUser(null);
      setRole(null);
      navigate("/");
    } catch (err) {
      console.error("Erreur déconnexion :", err);
    }
  };

  const commonLinks = [
    { name: "Accueil", to: "/" },
    { name: "Catalogue des cours", to: "/catalog" },
    { name: "Abonnement", to: "/subscription" },
  ];

  const studentLinks =
    role === "student" ? [{ name: "Mon espace", to: "/dashboard" }] : [];

  return {
    user,
    commonLinks,
    roleLinks: studentLinks,
    handleLogout,
  };
}
