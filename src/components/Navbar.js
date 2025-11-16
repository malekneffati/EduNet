import React from "react";
import { Link, useNavigate } from "react-router-dom";
import { signOut } from "firebase/auth";
import { auth } from "../utils/firebaseConfig"; // ton config Firebase

const Navbar = ({ role, setRole }) => {
  const navigate = useNavigate();

  // 🔹 Liens communs à tous les utilisateurs
  const commonLinks = [
    { name: "Accueil", to: "/" },
    { name: "Catalogue des cours", to: "/catalog" },
    { name: "Abonnement", to: "/subscription" },
  ];

  // 🔹 Liens spécifiques à l'étudiant
  const studentLinks = [{ name: "mon espace", to: "/Dashboard" }];

  // 🔹 Déterminer quels liens afficher selon le rôle
  let roleLinks = [];
  if (role?.trim().toLowerCase() === "student") {
    roleLinks = studentLinks;
  }

  // 🔹 Fonction de déconnexion
  const handleLogout = async () => {
    try {
      await signOut(auth); // ferme la session Firebase
      setRole(null); // met à jour Navbar
      localStorage.removeItem("role");
      navigate("/");
    } catch (err) {
      console.error("Erreur déconnexion :", err);
    }
  };

  return (
    <nav className="bg-white shadow-md sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          {/* Logo */}
          <div className="flex-shrink-0">
            <h1 className="text-2xl font-bold font-poppins text-blue-900">
              EduNet
            </h1>
          </div>

          {/* Liens du menu */}
          <div className="flex items-center space-x-8">
            {commonLinks.map((link) => (
              <Link
                key={link.to}
                to={link.to}
                className="text-gray-700 hover:text-blue-600 px-3 py-2 rounded-md text-sm font-medium"
              >
                {link.name}
              </Link>
            ))}

            {roleLinks.map((link) => (
              <Link
                key={link.to}
                to={link.to}
                className="text-gray-700 hover:text-blue-600 px-3 py-2 rounded-md text-sm font-medium"
              >
                {link.name}
              </Link>
            ))}
          </div>

          {/* Bouton Déconnexion pour l'étudiant */}
          {role ? (
            <button
              onClick={handleLogout}
              className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg text-sm font-medium"
            >
              Déconnexion
            </button>
          ) : (
            <Link
              to="/login"
              className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg text-sm font-medium"
            >
              Se Connecter
            </Link>
          )}
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
