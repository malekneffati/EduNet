// src/components/admin/Subscriptions.js
import React, { useState } from "react";
import { useSubscriptionViewModel } from "../../viewmodels/admin/SubscriptionViewModel";

function AdminSubscriptions() {
  const { plans, loading, changePrice } = useSubscriptionViewModel();
  const [editingId, setEditingId] = useState(null);
  const [newPrice, setNewPrice] = useState("");

  if (loading) return <p>Chargement...</p>;

  const monthly = plans.find((p) => p.billingPeriod === "month");
  const yearly = plans.find((p) => p.billingPeriod === "year");

  const handleSave = async (planId) => {
    await changePrice(planId, Number(newPrice));
    setEditingId(null);
    setNewPrice("");
  };

  return (
    <div id="admin-promotions-section" className="admin-section">
      <div className="flex justify-between items-center mb-8">

        <button className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-medium">
          <i className="fas fa-plus mr-2"></i>Nouvelle promotion
        </button>
      </div>

      <div className="grid md:grid-cols-2 gap-8">
        {/* Colonne gauche : promotions (pour l'instant statique) */}
        <div className="bg-white rounded-lg card-shadow p-6">
          <h3 className="text-lg font-semibold mb-4">Promotions actives</h3>
          <div className="space-y-4">
            <div className="border border-gray-200 rounded-lg p-4">
              <div className="flex justify-between items-center mb-2">
                <h4 className="font-medium">Réduction Nouvel An</h4>
                <span className="bg-green-100 text-green-800 px-2 py-1 rounded-full text-xs">
                  Active
                </span>
              </div>
              <p className="text-sm text-gray-600 mb-2">
                25% de réduction sur tous les cours
              </p>
              <p className="text-xs text-gray-500">Expire le 31/01/2024</p>
            </div>
          </div>
        </div>

        {/* Colonne droite : options d'abonnement dynamiques */}
        <div className="bg-white rounded-lg card-shadow p-6">
          <h3 className="text-lg font-semibold mb-4">Options d'abonnement</h3>
          <div className="space-y-4">

            {/* Abonnement annuel */}
            {yearly && (
              <div className="border border-gray-200 rounded-lg p-4">
                <h4 className="font-medium mb-2">Abonnement annuel (Premium)</h4>
                <p className="text-2xl font-bold text-blue-600 mb-2">
                  {yearly.price} TND/an
                </p>

                {editingId === yearly.id ? (
                  <div className="flex items-center gap-2">
                    <input
                      type="number"
                      className="border rounded px-2 py-1 text-sm"
                      value={newPrice}
                      onChange={(e) => setNewPrice(e.target.value)}
                      placeholder="Nouveau prix"
                    />
                    <button
                      className="text-green-600 text-sm"
                      onClick={() => handleSave(yearly.id)}
                    >
                      Enregistrer
                    </button>
                    <button
                      className="text-gray-500 text-sm"
                      onClick={() => {
                        setEditingId(null);
                        setNewPrice("");
                      }}
                    >
                      Annuler
                    </button>
                  </div>
                ) : (
                  <button
                    className="text-blue-600 hover:text-blue-700 text-sm"
                    onClick={() => setEditingId(yearly.id)}
                  >
                    Modifier le prix
                  </button>
                )}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

export default AdminSubscriptions;
