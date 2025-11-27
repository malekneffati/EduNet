import { useState, useEffect } from "react";
import {
  collection,
  getDocs,
  query,
  orderBy,
  doc,
  getDoc,
  setDoc,
  Timestamp,
} from "firebase/firestore";
import { auth, db } from "../../firebase";
import { useNavigate } from "react-router-dom";
import PaymentModel from "../../models/PaymentModel";
import CourseAccessViewModel from "./CourseAccessViewModel";

export default function useCourseDetailsViewModel(courseId) {
  const navigate = useNavigate();
  const [course, setCourse] = useState(null);
  const [loading, setLoading] = useState(true);
  const [reviews, setReviews] = useState([]);
  const [canAccessCourse, setCanAccessCourse] = useState(false);

  const user = auth.currentUser;
  const userId = user ? user.uid : null;

  // Vérifier l'accès au cours
  useEffect(() => {
    const fetchUserAccess = async () => {
      if (!userId) return;
      const hasAccess = await CourseAccessViewModel.userHasAccess(
        userId,
        courseId
      );
      setCanAccessCourse(hasAccess);
    };
    fetchUserAccess();
  }, [userId, courseId]);

  // Charger le cours
  useEffect(() => {
    const fetchCourse = async () => {
      try {
        const snap = await getDoc(doc(db, "courses", courseId));
        if (snap.exists()) setCourse({ id: snap.id, ...snap.data() });
        else setCourse("not_found");
      } catch (err) {
        console.error(err);
        setCourse("error");
      } finally {
        setLoading(false);
      }
    };
    fetchCourse();
  }, [courseId]);

  // Charger les reviews
  useEffect(() => {
    const fetchReviews = async () => {
      if (!course) return;
      try {
        const q = query(
          collection(db, "courses", courseId, "reviews"),
          orderBy("createdAt", "desc")
        );
        const snap = await getDocs(q);
        setReviews(snap.docs.map((d) => ({ id: d.id, ...d.data() })));
      } catch (err) {
        console.error("Erreur reviews:", err);
      }
    };
    fetchReviews();
  }, [course, courseId]);

  const averageRating =
    reviews.length > 0
      ? (reviews.reduce((a, b) => a + b.rating, 0) / reviews.length).toFixed(1)
      : 0;

  // Rejoindre cours gratuit
  const joinCourse = async () => {
    if (!userId) {
      alert("Veuillez vous connecter pour rejoindre ce cours.");
      navigate("/login");
      return;
    }

    try {
      await setDoc(doc(db, "users", userId, "myCourses", course.id), {
        joinedAt: Timestamp.now(),
        progress: 0,
      });
      navigate(`/course/${course.id}/content`);
    } catch (err) {
      console.error(err);
      alert("Erreur, impossible de rejoindre le cours.");
    }
  };

  // Paiement Paymee
  const handlePayment = async () => {
    if (!auth.currentUser) {
      alert("Vous devez être connecté.");
      return;
    }

    try {
      const response = await fetch(
        "https://sandbox.paymee.tn/api/v2/payments/create",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Token ${process.env.REACT_APP_PAYMEE_API_KEY}`,
          },
          body: JSON.stringify({
            amount: course.price,
            note: `Achat du cours : ${course.title}`,
            first_name: auth.currentUser.displayName || "User",
            last_name: "",
            email: auth.currentUser.email,
            return_url: `${window.location.origin}/payment-success?courseId=${courseId}`,          }),
        }
      );

      const data = await response.json();

      if (!data.data || !data.data.payment_url) {
        alert("Erreur Paymee");
        return;
      }

      // Redirect Paymee payment page
      window.location.href = data.data.payment_url;
    } catch (err) {
      console.error(err);
      alert("Erreur lors du paiement.");
    }
  };

  return {
    course,
    loading,
    reviews,
    averageRating,
    joinCourse,
    handlePayment,
    canAccessCourse,
  };
}
