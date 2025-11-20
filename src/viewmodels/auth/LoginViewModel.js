import { useState } from "react";
import { handleLogin, handleGoogleAuth } from "../../firebaseAuth";

const useLoginViewModel = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const login = async () => {
    setLoading(true);
    setError(null);
    try {
      const { user, role } = await handleLogin(email, password);
      return { user, role };
    } catch (err) {
      setError("Email ou mot de passe incorrect.");
      return null;
    } finally {
      setLoading(false);
    }
  };

  const loginWithGoogle = async () => {
    setLoading(true);
    setError(null);
    try {
      const { user, role } = await handleGoogleAuth();
      return { user, role };
    } catch (err) {
      setError("Échec de la connexion Google. Veuillez réessayer.");
      return null;
    } finally {
      setLoading(false);
    }
  };

  return {
    email,
    setEmail,
    password,
    setPassword,
    loading,
    error,
    login,
    loginWithGoogle,
  };
};

export default useLoginViewModel;
