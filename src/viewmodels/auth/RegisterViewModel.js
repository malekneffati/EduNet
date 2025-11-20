import { useState } from "react";
import { handleRegister } from "../../firebaseAuth";

const useRegisterViewModel = () => {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const register = async () => {
    setLoading(true);
    setError(null);
    try {
      const { user, role } = await handleRegister(email, password, name);
      return { user, role };
    } catch (err) {
      setError(err.message);
      return null;
    } finally {
      setLoading(false);
    }
  };

  return {
    name,
    setName,
    email,
    setEmail,
    password,
    setPassword,
    loading,
    error,
    register,
  };
};

export default useRegisterViewModel;
