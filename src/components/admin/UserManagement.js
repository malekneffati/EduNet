import React from "react";
import useUserManagementViewModel from "../../viewmodels/admin/UserManagementViewModel";

const UserManagement = () => {
  const vm = useUserManagementViewModel();

  if (vm.loading) return <p className="text-center mt-10">Chargement...</p>;

  return (
    <div>
      {/* Barre de recherche + filtre */}
      <div className="flex flex-wrap justify-between items-center mb-6 gap-3">
        <input
          type="text"
          placeholder="Rechercher un utilisateur..."
          value={vm.searchTerm}
          onChange={(e) => vm.setSearchTerm(e.target.value)}
          className="border p-2 rounded flex-1 min-w-[250px]"
        />

        <select
          value={vm.roleFilter}
          onChange={(e) => vm.setRoleFilter(e.target.value)}
          className="border p-2 rounded"
        >
          <option value="all">Tous les rôles</option>
          <option value="student">Étudiants</option>
          <option value="admin">Admins</option>
        </select>
      </div>

      {/* Liste des utilisateurs */}
      <div className="overflow-x-auto bg-white shadow rounded-lg">
        <table className="w-full">
          <thead>
            <tr className="bg-gray-100 text-left">
              <th className="p-3">Nom</th>
              <th className="p-3">Email</th>
              <th className="p-3">Date d'inscription</th>
              <th className="p-3">Rôle</th>
              <th className="p-3">Abonnement</th>
              <th className="p-3 text-center">Actions</th>
            </tr>
          </thead>
          <tbody>
            {vm.filteredUsers.map((user) => {
              const sub = user.subscription || {};
              let abonnement = "Gratuit";
              let color = "bg-gray-100 text-gray-600";

              if (sub.type === "mensuel" && sub.active) {
                abonnement = "Mensuel";
                color = "bg-blue-100 text-blue-700";
              } else if (sub.type === "annuel" && sub.active) {
                abonnement = "Annuel";
                color = "bg-green-100 text-green-700";
              } else if (sub.type && !sub.active) {
                abonnement = "Expiré";
                color = "bg-red-100 text-red-600";
              }

              return (
                <tr key={user.id} className="border-t hover:bg-gray-50">
                  <td className="p-3">{user.name}</td>
                  <td className="p-3">{user.email}</td>
                  <td className="p-3">
                    {user.createdAt
                      ? new Date(user.createdAt).toLocaleDateString()
                      : "—"}
                  </td>
                  <td className="p-3">
                    <select
                      value={user.role}
                      onChange={(e) =>
                        vm.handleRoleChange(user.id, e.target.value)
                      }
                      className="border p-1 rounded"
                    >
                      <option value="student">Étudiant</option>
                      <option value="admin">Admin</option>
                    </select>
                  </td>
                  <td className="p-3">
                    {user.role === "student" ? (
                      <span
                        className={`px-3 py-1 rounded-full text-sm font-medium ${color}`}
                      >
                        {abonnement}
                      </span>
                    ) : (
                      "-"
                    )}
                  </td>
                  <td className="p-3 text-center">
                    <button
                      onClick={() => vm.handleDelete(user.id)}
                      className="text-red-500 hover:text-red-700 transition"
                    >
                      Supprimer
                    </button>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>

        {vm.filteredUsers.length === 0 && (
          <p className="text-center py-6 text-gray-500">
            Aucun utilisateur trouvé.
          </p>
        )}
      </div>
    </div>
  );
};

export default UserManagement;
