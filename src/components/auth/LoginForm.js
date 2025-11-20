import React from "react";
import useLoginViewModel from "../../viewmodels/auth/LoginViewModel";

const LoginForm = ({ navigate, updateRole }) => {
  const vm = useLoginViewModel();

  const onSubmit = async (e) => {
    e.preventDefault();
    const result = await vm.login();
    if (result) {
      localStorage.setItem("role", result.role);
      updateRole(result.role);
      navigate(result.role === "admin" ? "/admin-dashboard" : "/dashboard");
    }
  };

  return (
    <form
      onSubmit={onSubmit}
      className="bg-white p-6 rounded-lg shadow-md max-w-md mx-auto"
    >
      <h2 className="text-2xl font-semibold mb-4 text-center text-blue-600">
        Connexion
      </h2>
      <input
        type="email"
        placeholder="Email"
        value={vm.email}
        onChange={(e) => vm.setEmail(e.target.value)}
        className="w-full mb-4 px-3 py-2 border rounded-lg"
        required
      />
      <input
        type="password"
        placeholder="Mot de passe"
        value={vm.password}
        onChange={(e) => vm.setPassword(e.target.value)}
        className="w-full mb-4 px-3 py-2 border rounded-lg"
        required
      />
      {vm.error && <p className="text-red-500 mb-4 text-center">{vm.error}</p>}
      <button
        type="submit"
        disabled={vm.loading}
        className="w-full bg-blue-600 hover:bg-blue-700 text-white py-2 rounded-lg"
      >
        {vm.loading ? "Connexion..." : "Se connecter"}
      </button>
    </form>
  );
};

export default LoginForm;
