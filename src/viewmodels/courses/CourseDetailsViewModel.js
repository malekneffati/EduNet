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

export default function useCourseDetailsViewModel(courseId) {
  const navigate = useNavigate();
  const [course, setCourse] = useState(null);
  const [loading, setLoading] = useState(true);
  const [reviews, setReviews] = useState([]);

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

  // Calcul moyenne
  const averageRating =
    reviews.length > 0
      ? (reviews.reduce((a, b) => a + b.rating, 0) / reviews.length).toFixed(1)
      : 0;

  // Rejoindre cours
  const joinCourse = async () => {
    if (!auth.currentUser){
      alert("Veuillez vous connecter pour rejoindre ce cours.");
      navigate("/login");
      return;
    } 
    try {
      const userId = auth.currentUser.uid;
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
    if (!auth.currentUser) return alert("Veuillez vous connecter.");
    // ici tu peux ajouter ton code de paiement
  };

  return {
    course,
    loading,
    reviews,
    averageRating,
    joinCourse,
    handlePayment,
  };
}
