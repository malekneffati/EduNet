//src/viewmodels/courses/CourseContentViewModel.js
import { useEffect, useState } from "react";
import {
  doc,
  getDoc,
  collection,
  getDocs,
  addDoc,
  Timestamp,
} from "firebase/firestore";
import { db, auth } from "../../firebase";

const useCourseContentViewModel = (courseId) => {
  const [course, setCourse] = useState(null);
  const [chapters, setChapters] = useState([]);
  const [allowed, setAllowed] = useState(null); // null = pas encore vérifié
  const [loading, setLoading] = useState(true);
  // Reviews
  const [reviews, setReviews] = useState([]);
  const [averageRating, setAverageRating] = useState(0);
  const [newRating, setNewRating] = useState(0);
  const [newComment, setNewComment] = useState("");
  const [sendingReview, setSendingReview] = useState(false);

  const user = auth.currentUser;

  // ------------------------------
  // 1️⃣ FETCH COURSE DATA
  // ------------------------------
  const loadCourse = async () => {
    try {
      const ref = doc(db, "courses", courseId);
      const snap = await getDoc(ref);

      if (!snap.exists()) {
        setCourse("not_found");
        return;
      }

      const data = { id: snap.id, ...snap.data() };
      setCourse(data);

      if (data.chapters && Array.isArray(data.chapters)) {
        const sortedChapters = data.chapters
          .map((c) => ({ ...c }))
          .sort((a, b) => (a.order || 0) - (b.order || 0));
        setChapters(sortedChapters);
      } else {
        setChapters([]);
      }
    } catch (err) {
      console.error("Erreur loadCourse:", err);
      setCourse("error");
    }
  };

  // ------------------------------
  // 2️⃣ CHECK ACCESS (FREE OR PURCHASED)
  // ------------------------------
  const checkAccess = async () => {
    if (!user) {
      setAllowed(false);
      return;
    }

    if (course?.isFree) {
      console.log("Course is free, access granted");
      setAllowed(true);
      return;
    }
  };

  // ------------------------------
  // 3️⃣ FETCH REVIEWS
  // ------------------------------
  const loadReviews = async () => {
    try {
      const ref = collection(db, "courses", courseId, "reviews");
      const snap = await getDocs(ref);

      const data = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
      setReviews(data);

      if (data.length > 0) {
        const avg =
          data.reduce((sum, r) => sum + (r.rating || 0), 0) / data.length;
        setAverageRating(avg.toFixed(1));
      } else {
        setAverageRating(0);
      }
    } catch (err) {
      console.error("Erreur loadReviews:", err);
      setReviews([]);
      setAverageRating(0);
    }
  };

  // ------------------------------
  // 4️⃣ SUBMIT REVIEW
  // ------------------------------
  const submitReview = async () => {
    if (!user) {
      alert("Vous devez être connecté pour laisser un avis.");
      return;
    }
    if (newRating === 0) {
      alert("Veuillez sélectionner une note.");
      return;
    }

    setSendingReview(true);

    try {
      await addDoc(collection(db, "courses", courseId, "reviews"), {
        userId: user.uid,
        rating: newRating,
        comment: newComment,
        createdAt: Timestamp.now(),
      });

      setNewRating(0);
      setNewComment("");
      await loadReviews();
    } catch (err) {
      console.error("Erreur submitReview:", err);
      alert("Erreur lors de l'envoi de votre avis.");
    } finally {
      setSendingReview(false);
    }
  };

  // ------------------------------
  // INITIAL LOAD
  // ------------------------------
  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      await loadCourse();
    };
    fetchData();
  }, [courseId]);

  // Load reviews and access after course loads
  useEffect(() => {
    if (!course || course === "not_found") {
      setLoading(false);
      return;
    }

    const fetchRelatedData = async () => {
      await Promise.all([loadReviews(), checkAccess()]);
      setLoading(false);
    };

    fetchRelatedData();
  }, [course]);

  return {
    course,
    chapters,
    allowed,
    loading,
    reviews,
    averageRating,
    newRating,
    setNewRating,
    newComment,
    setNewComment,
    sendingReview,
    submitReview,
  };
};

export default useCourseContentViewModel;
