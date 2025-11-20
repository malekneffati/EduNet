import React from "react";
import useRegisterViewModel from "../../viewmodels/auth/RegisterViewModel";

const RegisterForm = ({ navigate, updateRole }) => {
  const vm = useRegisterViewModel();

  const onSubmit = async (e) => {
    e.preventDefault();
    const result = await vm.register();
    if (result) {
      localStorage.setItem("role", result.role);
      updateRole(result.role);
      navigate(result.role === "admin" ? "/admin-dashboard" : "/dashboard");
    }
  };

  return (
    <form
      onSubmit={onSubmit}
      className="max-w-md mx-auto bg-white p-6 rounded-lg shadow-md"
    >
      <h2 className="text-2xl font-semibold mb-4 text-center text-blue-600">
        Créer un compte
      </h2>
      <input
        type="text"
        placeholder="Nom complet"
        value={vm.name}
        onChange={(e) => vm.setName(e.target.value)}
        className="w-full mb-4 px-3 py-2 border rounded-lg"
        required
      />
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
        {vm.loading ? "Inscription..." : "S'inscrire"}
      </button>
    </form>
  );
};

export default RegisterForm;
