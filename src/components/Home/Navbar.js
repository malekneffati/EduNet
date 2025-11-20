import React from "react";
import { Link } from "react-router-dom";
import useNavbarViewModel from "../../viewmodels/home/NavbarViewModel";

const Navbar = () => {
  const { user, handleLogout, commonLinks, roleLinks } = useNavbarViewModel();

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

          {/* Liens */}
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

          {/* Bouton connexion / déconnexion */}
          <div>
            {user ? (
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
      </div>
    </nav>
  );
};

export default Navbar;
