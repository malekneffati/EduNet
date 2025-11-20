import { useState, useEffect } from "react";
import { db } from "../../firebaseConfig";
import {
  collection,
  getDocs,
  deleteDoc,
  doc,
  updateDoc,
} from "firebase/firestore";

const useUserManagementViewModel = () => {
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
    if (!window.confirm("Supprimer cet utilisateur ?")) return;
    try {
      await deleteDoc(doc(db, "users", id));
      fetchUsers();
    } catch (error) {
      console.error("Erreur lors de la suppression :", error);
    }
  };

  // 🔹 Modifier le rôle
  const handleRoleChange = async (id, role) => {
    try {
      await updateDoc(doc(db, "users", id), { role });
      fetchUsers();
    } catch (error) {
      console.error("Erreur lors du changement de rôle :", error);
    }
  };

  // 🔹 Utilisateurs filtrés par recherche et rôle
  const filteredUsers = users.filter((u) => {
    const matchSearch =
      u.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      u.email?.toLowerCase().includes(searchTerm.toLowerCase());
    const matchRole = roleFilter === "all" ? true : u.role === roleFilter;
    return matchSearch && matchRole;
  });

  return {
    users,
    searchTerm,
    setSearchTerm,
    roleFilter,
    setRoleFilter,
    loading,
    filteredUsers,
    handleDelete,
    handleRoleChange,
  };
};

export default useUserManagementViewModel;
