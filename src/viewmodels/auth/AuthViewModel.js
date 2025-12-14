//src/viewmodels/auth/AuthViewModel.js
import { useState, useEffect } from "react";
import { auth, db } from "../../firebaseConfig";
import { onAuthStateChanged } from "firebase/auth";
import { doc, getDoc } from "firebase/firestore";

const useAuthViewModel = () => {
  const [loading, setLoading] = useState(true);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [userRole, setUserRole] = useState(undefined);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      setLoading(true);

      if (!user) {
        setIsAuthenticated(false);
        setUserRole(undefined);
        setLoading(false);
        return;
      }

      try {
        const docSnap = await getDoc(doc(db, "users", user.uid));
        setIsAuthenticated(true);
        setUserRole(
          docSnap.exists() ? docSnap.data().role?.toLowerCase() : "student"
        );
      } catch (err) {
        console.error("Erreur récupération rôle :", err);
        setIsAuthenticated(true);
        setUserRole("student");
      } finally {
        setLoading(false);
      }
    });

    return () => unsubscribe();
  }, []);

  return {
    loading,
    isAuthenticated,
    userRole,
  };
};

export default useAuthViewModel;
