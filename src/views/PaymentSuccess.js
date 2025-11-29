// src/views/PaymentSuccess.js
import { useEffect } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import PaymentViewModel from "../viewmodels/courses/PaymentViewModel";
import { auth } from "../firebase";

const PaymentSuccess = () => {
  const navigate = useNavigate();
  const location = useLocation();

  useEffect(() => {
    const addCourse = async () => {
      const params = new URLSearchParams(location.search);
      const courseId = params.get("courseId");
      const user = auth.currentUser;

      if (!courseId || !user) {
        navigate("/courses"); // si quelque chose manque, retourner à la liste
        return;
      }

      try {
        await PaymentViewModel.addCourseToStudent(user.uid, courseId);
        navigate(`/course/${courseId}/content`);
      } catch (err) {
        console.error("Erreur ajout cours après paiement :", err);
        alert(
          "Erreur lors de l'ajout du cours. Veuillez contacter le support."
        );
        navigate("/courses");
      }
    };

    addCourse();
  }, [location, navigate]);

  return <p className="p-8 text-center">Paiement réussi, redirection...</p>;
};

export default PaymentSuccess;
