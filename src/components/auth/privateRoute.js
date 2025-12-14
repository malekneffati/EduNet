//src/components/auth/PrivateRoute.js
import React from "react";
import { Navigate } from "react-router-dom";
import useAuthViewModel from "../../viewmodels/auth/AuthViewModel";

const PrivateRoute = ({ children, requiredRole }) => {
  const { loading, isAuthenticated, userRole } = useAuthViewModel();

  // 🔒 Blocage TOTAL tant que le rôle n’est pas résolu
  if (loading || userRole === undefined) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="w-12 h-12 border-4 border-blue-500 border-t-transparent rounded-full animate-spin"></div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return <Navigate to="/" replace />;
  }

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
