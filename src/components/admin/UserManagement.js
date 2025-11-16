import React, { useEffect, useState } from "react";
import { db } from "../../utils/firebaseConfig";
import {
  collection,
  getDocs,
  deleteDoc,
  doc,
  updateDoc,
} from "firebase/firestore";

const UserManagement = () => {
  const [users, setUsers] = useState([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [roleFilter, setRoleFilter] = useState("all");
  const [loading, setLoading] = useState(true);

  // 🔹 Charger les utilisateurs Firestore
  const fetchUsers = async () => {
    setLoading(true);
    try {
      const querySnapshot = await getDocs(collection(db, "users"));
      const userList = querySnapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));
      setUsers(userList);
    } catch (error) {
      console.error("Erreur lors du chargement des utilisateurs :", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  // 🔹 Supprimer un utilisateur
  const handleDelete = async (id) => {
    if (window.confirm("Supprimer cet utilisateur ?")) {
      try {
        await deleteDoc(doc(db, "users", id));
        fetchUsers();
      } catch (error) {
        console.error("Erreur lors de la suppression :", error);
      }
    }
  };

  // 🔹 Modifier le rôle
  const handleRoleChange = async (id, role) => {
    try {
      const userRef = doc(db, "users", id);
      await updateDoc(userRef, { role });
      fetchUsers();
    } catch (error) {
      console.error("Erreur lors du changement de rôle :", error);
    }
  };

  // 🔹 Filtrer les utilisateurs par recherche et rôle
  const filteredUsers = users.filter((u) => {
    const matchSearch =
      u.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      u.email?.toLowerCase().includes(searchTerm.toLowerCase());
    const matchRole = roleFilter === "all" ? true : u.role === roleFilter;
    return matchSearch && matchRole;
  });

  if (loading) return <p className="text-center mt-10">Chargement...</p>;

  return (
    <div>
      {/* Barre de recherche + filtre */}
      <div className="flex flex-wrap justify-between items-center mb-6 gap-3">
        <input
          type="text"
          placeholder="Rechercher un utilisateur..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="border p-2 rounded flex-1 min-w-[250px]"
        />

        <select
          value={roleFilter}
          onChange={(e) => setRoleFilter(e.target.value)}
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
            {filteredUsers.map((user) => {
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
                        handleRoleChange(user.id, e.target.value)
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
                      onClick={() => handleDelete(user.id)}
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

        {filteredUsers.length === 0 && (
          <p className="text-center py-6 text-gray-500">
            Aucun utilisateur trouvé.
          </p>
        )}
      </div>
    </div>
  );
};

export default UserManagement;
