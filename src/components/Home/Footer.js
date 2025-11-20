import React from "react";
import { Link } from "react-router-dom";

const Footer = () => {
  return (
    <footer className="bg-gray-900 text-white py-12">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          {/* Company Info */}
          <div>
            <h3 className="text-2xl font-bold font-poppins mb-4">EduNet</h3>
            <p className="text-gray-400 mb-4">
              Votre plateforme d'apprentissage en ligne pour développer vos
              compétences et atteindre vos objectifs professionnels.
            </p>
            <div className="flex space-x-4">
              <a
                href="https://facebook.com"
                target="_blank"
                rel="noopener noreferrer"
                className="text-gray-400 hover:text-white transition"
              >
                <i className="fab fa-facebook-f text-xl"></i>
              </a>
              <a
                href="https://twitter.com"
                target="_blank"
                rel="noopener noreferrer"
                className="text-gray-400 hover:text-white transition"
              >
                <i className="fab fa-twitter text-xl"></i>
              </a>
              <a
                href="https://linkedin.com"
                target="_blank"
                rel="noopener noreferrer"
                className="text-gray-400 hover:text-white transition"
              >
                <i className="fab fa-linkedin-in text-xl"></i>
              </a>
              <a
                href="https://instagram.com"
                target="_blank"
                rel="noopener noreferrer"
                className="text-gray-400 hover:text-white transition"
              >
                <i className="fab fa-instagram text-xl"></i>
              </a>
            </div>
          </div>

          {/* Quick Links */}
          <div>
            <h4 className="text-lg font-semibold font-poppins mb-4">
              Liens rapides
            </h4>
            <ul className="space-y-2">
              <li>
                <Link
                  to="/"
                  className="text-gray-400 hover:text-white transition"
                >
                  Accueil
                </Link>
              </li>
              <li>
                <Link
                  to="/catalog"
                  className="text-gray-400 hover:text-white transition"
                >
                  Catalogue des cours
                </Link>
              </li>
              <li>
                <Link
                  to="/subscription"
                  className="text-gray-400 hover:text-white transition"
                >
                  Abonnement
                </Link>
              </li>
              <li>
                <Link
                  to="/login"
                  className="text-gray-400 hover:text-white transition"
                >
                  Connexion
                </Link>
              </li>
              <li>
                <Link
                  to="/register"
                  className="text-gray-400 hover:text-white transition"
                >
                  Inscription
                </Link>
              </li>
            </ul>
          </div>

          {/* Contact Info */}
          <div>
            <h4 className="text-lg font-semibold font-poppins mb-4">
              Contactez-nous
            </h4>
            <ul className="space-y-2">
              <li className="flex items-center">
                <i className="fas fa-envelope mr-2 text-blue-500"></i>
                <a
                  href="mailto:support@edunet.com"
                  className="text-gray-400 hover:text-white transition"
                >
                  support@edunet.com
                </a>
              </li>
              <li className="flex items-center">
                <i className="fas fa-phone mr-2 text-blue-500"></i>
                <a
                  href="tel:+21612345678"
                  className="text-gray-400 hover:text-white transition"
                >
                  +216 12 345 678
                </a>
              </li>
              <li className="flex items-start">
                <i className="fas fa-map-marker-alt mr-2 text-blue-500 mt-1"></i>
                <span className="text-gray-400">
                  123 Avenue de l'Éducation, Tunis, Tunisie
                </span>
              </li>
            </ul>
          </div>

          {/* Newsletter Signup */}
          <div>
            <h4 className="text-lg font-semibold font-poppins mb-4">
              Newsletter
            </h4>
            <p className="text-gray-400 mb-4">
              Inscrivez-vous pour recevoir les dernières mises à jour.
            </p>
            <form className="flex">
              <input
                type="email"
                placeholder="Entrez votre email"
                className="flex-1 px-3 py-2 bg-gray-800 border border-gray-700 rounded-l-lg text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <button
                type="submit"
                className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-r-lg font-medium transition"
              >
                S'abonner
              </button>
            </form>
          </div>
        </div>

        {/* Copyright */}
        <div className="border-t border-gray-700 mt-12 pt-6 text-center">
          <p className="text-gray-400 text-sm">
            &copy; 2025 EduNet. Tous droits réservés.
          </p>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
