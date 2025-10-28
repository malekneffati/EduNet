// src/components/auth/PrivateRoute.jsx
import React, { useEffect, useState } from "react";
import { Navigate } from "react-router-dom";
import { auth, db } from "../../utils/firebaseConfig";
import { onAuthStateChanged } from "firebase/auth";
import { doc, getDoc } from "firebase/firestore";

const PrivateRoute = ({ children, requiredRole }) => {
  const [loading, setLoading] = useState(true);
  const [userRole, setUserRole] = useState(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (!user) {
        setIsAuthenticated(false);
        setUserRole(null);
        setLoading(false);
        return;
      }
      setIsAuthenticated(true);
      try {
        const docSnap = await getDoc(doc(db, "users", user.uid));
        setUserRole(
          docSnap.exists() ? docSnap.data().role.toLowerCase() : "student"
        );
      } catch (err) {
        console.error("Erreur récupération rôle :", err);
        setUserRole("student");
      } finally {
        setLoading(false);
      }
    });
    return () => unsubscribe();
  }, []);

  if (loading)
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="w-12 h-12 border-4 border-blue-500 border-t-transparent rounded-full animate-spin"></div>
      </div>
    );

  if (!isAuthenticated) return <Navigate to="/" replace />;

  if (requiredRole && userRole !== requiredRole.toLowerCase()) {
    return (
      <Navigate
        to={userRole === "admin" ? "/admin-dashboard" : "/dashboard"}
        replace
      />
    );
  }

  return children;
};

export default PrivateRoute;
