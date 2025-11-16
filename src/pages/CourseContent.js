import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import {
  collection,
  addDoc,
  getDocs,
  query,
  orderBy,
  Timestamp,
  doc,
  getDoc,
} from "firebase/firestore";
import { auth,db } from "../firebase";

// Composant étoile
const Star = ({ filled, onClick }) => (
  <span
    onClick={onClick}
    className={`cursor-pointer text-2xl ${
      filled ? "text-yellow-400" : "text-gray-400"
    }`}
  >
    ★
  </span>
);

const CourseContent = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [progress, setProgress] = useState(0);
  const [course, setCourse] = useState(null);
  const [loading, setLoading] = useState(true);
  const [allowed, setAllowed] = useState(false);

  // Avis
  const [reviews, setReviews] = useState([]);
  const [newRating, setNewRating] = useState(0);
  const [newComment, setNewComment] = useState("");
  const [sendingReview, setSendingReview] = useState(false);

  // Vérifier si user possède ce cours
  const checkAccess = async () => {
    if (!auth.currentUser) return false;

    const userId = auth.currentUser.uid;
    const myCourseRef = doc(db, "users", userId, "myCourses", id);
    const snap = await getDoc(myCourseRef);

    return snap.exists();
  };

  // Charger cours
  useEffect(() => {
    const loadCourse = async () => {
      try {
        const ref = doc(db, "courses", id);
        const snap = await getDoc(ref);

        if (!snap.exists()) {
          setCourse("not_found");
          return;
        }

        setCourse({ id: snap.id, ...snap.data() });

        // Vérification accès
        const canView = await checkAccess();
        setAllowed(canView);
      } catch (err) {
        console.error("Erreur cours :", err);
        setCourse("error");
      } finally {
        setLoading(false);
      }
    };

    loadCourse();
  }, [id]);

  // Charger avis
  const fetchReviews = async () => {
    try {
      const q = query(
        collection(db, "courses", id, "reviews"),
        orderBy("createdAt", "desc")
      );
      const snap = await getDocs(q);
      setReviews(snap.docs.map((d) => ({ id: d.id, ...d.data() })));
    } catch (err) {
      console.error("Erreur reviews :", err);
    }
  };

  const fetchProgress = async () => {
    const docRef = doc(db, "users", auth.currentUser.uid, "myCourses", id);
    const docSnap = await getDoc(docRef);
    if (docSnap.exists()) {
      setProgress(docSnap.data().progress || 0);
    }
  };

  useEffect(() => {
    if (allowed) fetchReviews();
  }, [allowed]);

  // Poster un avis
  const submitReview = async () => {
    if (!auth.currentUser) return alert("Veuillez vous connecter pour noter.");

    if (!newRating) return alert("Sélectionnez une note.");
    if (!newComment.trim()) return alert("Écrivez un commentaire.");

    setSendingReview(true);

    try {
      await addDoc(collection(db, "courses", id, "reviews"), {
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

  if (loading) return <p className="p-8 text-center">Chargement...</p>;
  if (course === "not_found") return <p>Cours introuvable.</p>;
  if (course === "error") return <p>Erreur de chargement.</p>;

  // ✅ Si l’étudiant n'a pas rejoint ce cours
  if (!allowed) {
    return (
      <div className="max-w-2xl mx-auto text-center p-12">
        <h2 className="text-2xl font-bold mb-4">Cours non accessible</h2>
        <p className="text-gray-600 mb-6">
          Vous devez rejoindre ce cours pour voir son contenu.
        </p>
        <button
          onClick={() => navigate(`/course/${id}`)}
          className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
        >
          Revenir à la page du cours
        </button>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto p-8">
      <h1 className="text-2xl font-bold mb-4">{course.title}</h1>

      {/* Vidéo */}
      {course.videoUrl && (
        <video
          src={course.videoUrl}
          controls
          className="rounded-lg shadow-lg mb-6 w-full"
        ></video>
      )}

      {/* PDF */}
      {course.pdfUrl && (
        <a
          href={course.pdfUrl}
          target="_blank"
          rel="noopener noreferrer"
          className="text-blue-600 underline block mb-6"
        >
          📄 Télécharger le document PDF
        </a>
      )}

      {/* Description */}
      <div className="bg-white p-6 rounded-lg shadow mb-10">
        <h2 className="text-xl font-semibold mb-4">Contenu du cours</h2>
        <p className="text-gray-700">{course.description}</p>
      </div>

      {/* Formulaire avis */}
      <div className="bg-white p-6 rounded-lg shadow mb-10">
        <h2 className="text-xl font-semibold mb-4">Laisser un avis</h2>

        <div className="flex gap-2 mb-4">
          {[1, 2, 3, 4, 5].map((n) => (
            <Star
              key={n}
              filled={n <= newRating}
              onClick={() => setNewRating(n)}
            />
          ))}
        </div>

        <textarea
          value={newComment}
          onChange={(e) => setNewComment(e.target.value)}
          rows="3"
          placeholder="Votre avis..."
          className="w-full border p-3 rounded-lg mb-4"
        />

        <button
          onClick={submitReview}
          className="bg-blue-600 text-white px-4 py-2 rounded-lg"
          disabled={sendingReview}
        >
          {sendingReview ? "Envoi..." : "Publier l'avis"}
        </button>
      </div>
    </div>
  );
};

export default CourseContent;
