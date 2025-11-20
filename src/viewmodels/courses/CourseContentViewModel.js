// src/viewmodels/courses/CourseContentViewModel.js
import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import {
  collection,
  getDocs,
  query,
  orderBy,
  doc,
  getDoc,
  addDoc,
  Timestamp,
} from "firebase/firestore";
import { auth, db } from "../../firebase";

export default function useCourseContentViewModel(courseId) {
  const navigate = useNavigate();
  const [course, setCourse] = useState(null);
  const [loading, setLoading] = useState(true);
  const [allowed, setAllowed] = useState(false);
  const [progress, setProgress] = useState(0);

  // Avis
  const [reviews, setReviews] = useState([]);
  const [newRating, setNewRating] = useState(0);
  const [newComment, setNewComment] = useState("");
  const [sendingReview, setSendingReview] = useState(false);

  // Vérifier si l’utilisateur a accès
  const checkAccess = async () => {
    if (!auth.currentUser) return false;
    const snap = await getDoc(
      doc(db, "users", auth.currentUser.uid, "myCourses", courseId)
    );
    return snap.exists();
  };

  // Charger cours et vérifier accès
  useEffect(() => {
    const loadCourse = async () => {
      try {
        const snap = await getDoc(doc(db, "courses", courseId));
        if (!snap.exists()) {
          setCourse("not_found");
          return;
        }
        setCourse({ id: snap.id, ...snap.data() });

        const canView = await checkAccess();
        setAllowed(canView);

        if (canView) fetchReviews();
      } catch (err) {
        console.error("Erreur cours :", err);
        setCourse("error");
      } finally {
        setLoading(false);
      }
    };
    loadCourse();
  }, [courseId]);

  // Charger les reviews
  const fetchReviews = async () => {
    try {
      const q = query(
        collection(db, "courses", courseId, "reviews"),
        orderBy("createdAt", "desc")
      );
      const snap = await getDocs(q);
      setReviews(snap.docs.map((d) => ({ id: d.id, ...d.data() })));
    } catch (err) {
      console.error("Erreur reviews :", err);
    }
  };

  // Charger progress
  const fetchProgress = async () => {
    if (!auth.currentUser) return;
    const snap = await getDoc(
      doc(db, "users", auth.currentUser.uid, "myCourses", courseId)
    );
    if (snap.exists()) setProgress(snap.data().progress || 0);
  };

  // Poster un avis
  const submitReview = async () => {
    if (!auth.currentUser) return alert("Veuillez vous connecter pour noter.");
    if (!newRating) return alert("Sélectionnez une note.");
    if (!newComment.trim()) return alert("Écrivez un commentaire.");

    setSendingReview(true);
    try {
      await addDoc(collection(db, "courses", courseId, "reviews"), {
        rating: newRating,
        comment: newComment.trim(),
        userId: auth.currentUser.uid,
        createdAt: Timestamp.now(),
      });
      setNewRating(0);
      setNewComment("");
      fetchReviews();
    } catch (err) {
      console.error("Erreur avis :", err);
    } finally {
      setSendingReview(false);
    }
  };

  // Calcul moyenne
  const averageRating =
    reviews.length > 0
      ? (reviews.reduce((a, b) => a + b.rating, 0) / reviews.length).toFixed(1)
      : 0;

  return {
    course,
    loading,
    allowed,
    progress,
    reviews,
    newRating,
    setNewRating,
    newComment,
    setNewComment,
    sendingReview,
    submitReview,
    averageRating,
    fetchProgress,
  };
}
