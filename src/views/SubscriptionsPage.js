// src/views/SubscriptionsPage.js
import React from "react";
import { useSubscriptionViewModel } from "../viewmodels/admin/SubscriptionViewModel"; // ou un viewmodel dédié public

function SubscriptionsPage() {
  const { plans, loading } = useSubscriptionViewModel();

  if (loading) return <p>Chargement...</p>;

  const monthly = plans.find((p) => p.billingPeriod === "month");
  const yearly = plans.find((p) => p.billingPeriod === "year");

  const handleSubscribe = (planId) => {
    // ici tu rediriges vers ta page de paiement /checkout avec le plan choisi
    // ex: navigate(`/checkout?plan=${planId}`);
    console.log("Subscribe to:", planId);
  };

  return (
    <div className="max-w-6xl mx-auto py-16 px-4">
      <div className="grid md:grid-cols-2 gap-8 mb-12 justify-center ">
        {/* Carte Accès Gratuit */}
        <div className="bg-white rounded-2xl card-shadow p-8">
          <h3 className="text-2xl font-bold font-poppins mb-4">
            Accès Gratuit
          </h3>
          <div className="text-3xl font-bold text-gray-900 mb-6">
            0 TND
            <span className="text-lg font-normal text-gray-500">/mois</span>
          </div>
          <ul className="space-y-3 mb-8">
            <li className="flex items-center">
              <i className="fas fa-check text-green-500 mr-3"></i>
              Cours gratuits uniquement
            </li>
            <li className="flex items-center">
              <i className="fas fa-check text-green-500 mr-3"></i>
              Accès limité aux ressources
            </li>
            <li className="flex items-center">
              <i className="fas fa-times text-red-500 mr-3"></i>
              Pas de certificats
            </li>
            <li className="flex items-center">
              <i className="fas fa-times text-red-500 mr-3"></i>
              Support limité
            </li>
          </ul>
          <button className="w-full border-2 border-gray-300 text-gray-700 py-3 px-4 rounded-lg font-medium">
            Déjà actif
          </button>
        </div>

        {/* Carte Abonnement annuel (Premium) */}
        {yearly && (
          <div className="bg-gradient-to-br from-blue-600 to-blue-700 text-white rounded-2xl card-shadow p-8 relative">
            <div className="absolute top-4 right-4 bg-yellow-400 text-yellow-900 px-3 py-1 rounded-full text-sm font-medium">
              Populaire
            </div>
            <h3 className="text-2xl font-bold font-poppins mb-4">
              Abonnement Premium (Annuel)
            </h3>
            <div className="text-3xl font-bold mb-6">
              {yearly.price} TND
              <span className="text-lg font-normal opacity-80">/an</span>
            </div>
            <ul className="space-y-3 mb-8">
              <li className="flex items-center">
                <i className="fas fa-check mr-3"></i>
                Accès illimité à tous les cours
              </li>
              <li className="flex items-center">
                <i className="fas fa-check mr-3"></i>
                Téléchargement des ressources
              </li>
              <li className="flex items-center">
                <i className="fas fa-check mr-3"></i>
                Certificats de completion
              </li>
              <li className="flex items-center">
                <i className="fas fa-check mr-3"></i>
                Suivi des quiz et progression
              </li>
            </ul>
            <button
              onClick={() => handleSubscribe(yearly.id)}
              className="w-full bg-white text-blue-600 py-3 px-4 rounded-lg font-medium hover:bg-gray-100"
            >
              S'abonner maintenant
            </button>
          </div>
        )}
      </div>
    </div>
  );
}

export default SubscriptionsPage;
