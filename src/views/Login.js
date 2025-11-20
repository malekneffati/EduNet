import React, { useState, useEffect } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import LoginForm from "../components/auth/LoginForm";
import RegisterForm from "../components/auth/RegisterForm";
import useLoginViewModel from "../viewmodels/auth/LoginViewModel";

const Login = ({ updateRole }) => {
  const [isLoginTab, setIsLoginTab] = useState(true);
  const navigate = useNavigate();
  const location = useLocation();
  const vm = useLoginViewModel();

  useEffect(() => {
    if (location.state?.showRegister) setIsLoginTab(false);
  }, [location.state]);

  const handleGoogleLogin = async () => {
    const result = await vm.loginWithGoogle();
    if (result) {
      localStorage.setItem("role", result.role);
      updateRole(result.role);
      navigate(result.role === "admin" ? "/admin-dashboard" : "/dashboard");
    } else {
      alert(vm.error);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="max-w-md w-full bg-white rounded-2xl shadow-lg p-8">
        <Header />
        <TabSelector isLoginTab={isLoginTab} setIsLoginTab={setIsLoginTab} />
        {isLoginTab ? (
          <LoginForm navigate={navigate} updateRole={updateRole} />
        ) : (
          <RegisterForm navigate={navigate} updateRole={updateRole} />
        )}
        <button
          onClick={handleGoogleLogin}
          className="w-full bg-red-500 hover:bg-red-600 text-white py-2 rounded-lg mt-6 transition-colors"
        >
          Se connecter / S'inscrire avec Google
        </button>
      </div>
    </div>
  );
};

const Header = () => (
  <div className="text-center mb-8">
    <h2 className="text-3xl font-bold text-gray-900">Bienvenue sur EduNet</h2>
    <p className="text-gray-600 mt-2">
      Connectez-vous ou créez un compte pour commencer
    </p>
  </div>
);

const TabSelector = ({ isLoginTab, setIsLoginTab }) => (
  <div className="flex mb-6 border-b border-gray-200">
    <button
      onClick={() => setIsLoginTab(true)}
      className={`flex-1 py-2 px-4 text-center font-medium text-sm transition-colors ${
        isLoginTab
          ? "border-b-2 border-blue-600 text-blue-600"
          : "text-gray-500 hover:text-blue-500"
      }`}
    >
      Connexion
    </button>
    <button
      onClick={() => setIsLoginTab(false)}
      className={`flex-1 py-2 px-4 text-center font-medium text-sm transition-colors ${
        !isLoginTab
          ? "border-b-2 border-blue-600 text-blue-600"
          : "text-gray-500 hover:text-blue-500"
      }`}
    >
      Inscription
    </button>
  </div>
);

export default Login;
