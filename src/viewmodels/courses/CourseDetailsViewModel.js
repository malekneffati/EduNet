// src/viewmodels/courses/CourseDetailsViewModel.js
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
import {
  setPersistence,
  browserLocalPersistence,
  onAuthStateChanged,
} from "firebase/auth";

export default function useCourseDetailsViewModel(courseId) {
  const navigate = useNavigate();
  const [course, setCourse] = useState(null);
  const [loading, setLoading] = useState(true);
  const [reviews, setReviews] = useState([]);
  const [user, setUser] = useState(null);
  const [canAccessCourse, setCanAccessCourse] = useState(false);

  // 1️⃣ Auth persistante + user state
  useEffect(() => {
    const initAuth = async () => {
      await setPersistence(auth, browserLocalPersistence);

      const unsubscribe = onAuthStateChanged(auth, (u) => {
        setUser(u || null);
      });

      return () => unsubscribe();
    };

    initAuth();
  }, []);

  const userId = user?.uid || null;

  // 2️⃣ Charger le cours
  useEffect(() => {
    const fetchCourse = async () => {
      setLoading(true);
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

  // 3️⃣ Charger reviews
  useEffect(() => {
    if (!course || course === "not_found") return;

    const fetchReviews = async () => {
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

  // 4️⃣ Vérification accès
  useEffect(() => {
    const checkAccess = async () => {
      if (!user || !course) {
        setCanAccessCourse(false);
        return;
      }

      if (course.isFree) {
        setCanAccessCourse(true);
        return;
      }

      try {
        const accessSnap = await getDoc(
          doc(db, "users", user.uid, "myCourses", courseId)
        );
        setCanAccessCourse(accessSnap.exists());
      } catch (err) {
        console.error("Erreur checkAccess:", err);
        setCanAccessCourse(false);
      }
    };

    checkAccess();
  }, [user, course, courseId]);

  const averageRating =
    reviews.length > 0
      ? (
          reviews.reduce((a, b) => a + (b.rating || 0), 0) / reviews.length
        ).toFixed(1)
      : 0;

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

  const handlePayment = async () => {
    if (!user) {
      alert("Vous devez être connecté.");
      return;
    }

    try {
      const body = {
        amount: course.price,
        note: `Achat du cours : ${course.title}`,
        firstName: user.displayName || "User",
        lastName: user.lastName || "Unknown",
        email: user.email,
        phone: user.phone || "+21600000000",
        returnUrl: `https://edunet-1574d.web.app/course/${course.id}/content`,
        cancelUrl: `https://edunet-1574d.web.app/courses`,
        orderId: `${userId}_${course.id}`,
      };

      const response = await fetch(
        "https://edunet-1bqg.onrender.com/createPayment",
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(body),
        }
      );

      const data = await response.json();

      if (!data.payment_url) {
        alert("Erreur lors de la création du paiement.");
        return;
      }

      window.location.href = data.payment_url;
    } catch (err) {
      console.error("Erreur lors du paiement :", err);
      alert("Erreur lors du paiement. Veuillez réessayer plus tard.");
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
    user,
  };
}
