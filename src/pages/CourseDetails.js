// ----- IMPORTS -----
import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
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
import { auth, db } from "../firebase";

const CourseDetails = () => {
  const { id: courseId } = useParams();
  const navigate = useNavigate();
  const user = auth.currentUser;
  const [course, setCourse] = useState(null);
  const [loading, setLoading] = useState(true);

  // Reviews affichage ONLY
  const [reviews, setReviews] = useState([]);

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

  // Charger le cours
  useEffect(() => {
    const fetchCourse = async () => {
      try {
        const snap = await getDoc(doc(db, "courses", courseId));

        if (snap.exists()) {
          setCourse({ id: snap.id, ...snap.data() });
        } else {
          setCourse("not_found");
        }
      } catch (err) {
        console.error(err);
        setCourse("error");
      } finally {
        setLoading(false);
      }
    };

    fetchCourse();
  }, [courseId]);

  useEffect(() => {
    if (course) fetchReviews();
  }, [course]);

  // Calcul de la note moyenne
  const averageRating =
    reviews.length > 0
      ? (reviews.reduce((a, b) => a + b.rating, 0) / reviews.length).toFixed(1)
      : 0;

  const joinCourse = async () => {
    if (!auth.currentUser) return alert("Veuillez vous connecter.");

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

  if (loading) return <p className="p-8 text-center">Chargement...</p>;

  const handlePayment = async () => {
    if (!auth.currentUser) return alert("Veuillez vous connecter.");

    try {
      const response = await fetch(
        "https://ton-backend.onrender.com/createPayment",
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            amount: course.price,
            note: `Achat du cours ${courseId}`,
            first_name: user?.firstName || "",
            last_name: user?.lastName || "",
            email: user?.email || "",
            phone: "+21611223344",
            courseId: courseId,
          }),
        }
      );

      const data = await response.json();

      if (data?.data?.payment_url) {
        window.location.href = data.data.payment_url; // REDIRECTION
      } else {
        alert("Erreur: Impossible de créer le paiement.");
      }
    } catch (err) {
      console.error(err);
      alert("Erreur lors du paiement.");
    }
  };

  return (
    <div className="max-w-5xl mx-auto py-12 px-4">
      <h1 className="text-3xl font-bold mb-2">{course.title}</h1>

      {/* Note moyenne */}
      <div className="flex items-center gap-1 mb-6">
        {[1, 2, 3, 4, 5].map((n) => (
          <span
            key={n}
            className={`text-2xl ${
              n <= Math.round(averageRating)
                ? "text-yellow-400"
                : "text-gray-300"
            }`}
          >
            ★
          </span>
        ))}
        <span className="ml-2 text-gray-700">{averageRating}/5</span>
        <span className="text-gray-500 ml-2">({reviews.length} avis)</span>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
        {/* COLONNE GAUCHE */}
        <div className="md:col-span-2 space-y-6">
          <div className="bg-gray-200 h-64 flex justify-center items-center rounded-lg">
            <span className="text-gray-600">Aperçu du cours</span>
          </div>

          <div className="bg-white p-6 rounded-lg shadow">
            <h2 className="text-xl font-semibold mb-3">Description</h2>
            <p>{course.description}</p>
          </div>

          {/* Liste des avis (AFFICHAGE SEULEMENT) */}
          <div className="bg-white p-6 rounded-lg shadow">
            <h2 className="text-xl font-semibold mb-4">Avis des étudiants</h2>

            {reviews.length === 0 ? (
              <p className="text-gray-600">Aucun avis pour le moment.</p>
            ) : (
              reviews.map((rev) => (
                <div key={rev.id} className="bg-gray-100 p-4 rounded-lg mb-4">
                  <div className="flex gap-1">
                    {[1, 2, 3, 4, 5].map((n) => (
                      <span
                        key={n}
                        className={`${
                          n <= rev.rating ? "text-yellow-400" : "text-gray-300"
                        }`}
                      >
                        ★
                      </span>
                    ))}
                  </div>
                  <p className="mt-2">{rev.comment}</p>
                  <p className="text-xs text-gray-500">
                    {rev.createdAt?.toDate().toLocaleDateString()}
                  </p>
                </div>
              ))
            )}
          </div>
        </div>

        {/* COLONNE DROITE */}
        <div className="w-full md:w-80">
          <div className="bg-white p-6 rounded-lg shadow space-y-3">
            <p>
              <strong>Catégorie :</strong> {course.category}
            </p>
            <p>
              <strong>Durée :</strong> {course.duration}
            </p>
            <p>
              <strong>Instructeur :</strong> {course.instructor}
            </p>
            <hr />

            {course.isFree ? (
              <button
                onClick={joinCourse}
                className="w-full py-2 bg-green-600 text-white rounded-lg"
              >
                Commencer gratuitement
              </button>
            ) : (
              <button
                onClick={handlePayment}
                className="w-full py-2 bg-blue-600 text-white rounded-lg"
              >
                Payer maintenant — {course.price} TND
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default CourseDetails;
