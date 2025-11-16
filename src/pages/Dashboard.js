// src/pages/Dashboard.js
import React, { useEffect, useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { auth, db } from "../firebase"; // ton fichier firebase.js
import {
  collection,
  getDocs,
  doc,
  getDoc,
  query,
  orderBy,
} from "firebase/firestore";

const Dashboard = () => {
  const navigate = useNavigate();

  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [myCourses, setMyCourses] = useState([]); // tableau d'objets { courseId, joinedAt, courseData }
  const [error, setError] = useState(null);
  const [userData, setUserData] = useState(null);

  useEffect(() => {
    const loadUserProfile = async () => {
      if (!user) return;

      try {
        const userRef = doc(db, "users", user.uid);
        const snap = await getDoc(userRef);

        if (snap.exists()) {
          setUserData(snap.data());
        }
      } catch (err) {
        console.error("Erreur chargement profil:", err);
      }
    };

    loadUserProfile();
  }, [user]);

  useEffect(() => {
    // Surveille l'auth (si l'utilisateur change)
    const unsubscribe = auth.onAuthStateChanged((u) => {
      setUser(u);
    });
    return () => unsubscribe();
  }, []);

  useEffect(() => {
    const loadMyCourses = async () => {
      setLoading(true);
      setError(null);
      setMyCourses([]);

      if (!user) {
        setLoading(false);
        return;
      }

      try {
        // 1) Récupère les docs dans users/{uid}/myCourses
        const myCoursesRef = collection(db, "users", user.uid, "myCourses");
        // si tu veux ordonner par joinedAt :
        const q = query(myCoursesRef, orderBy("joinedAt", "desc"));
        const snap = await getDocs(q);

        if (snap.empty) {
          setMyCourses([]); // pas de cours
          setLoading(false);
          return;
        }

        // 2) Pour chaque doc, récupère les données du cours dans /courses/{courseId}
        const coursePromises = snap.docs.map(async (d) => {
          const courseId = d.id;
          const meta = d.data();
          const courseSnap = await getDoc(doc(db, "courses", courseId));
          const courseData = courseSnap.exists()
            ? { id: courseSnap.id, ...courseSnap.data() }
            : null;
          return {
            courseId,
            joinedAt: meta.joinedAt || null,
            courseData,
            purchaseId: meta.purchaseId || null,
          };
        });

        const resolved = await Promise.all(coursePromises);
        setMyCourses(resolved.filter((c) => c.courseData)); // filtre les cours supprimés
      } catch (err) {
        console.error("Erreur loading myCourses:", err);
        setError("Impossible de charger vos cours. Réessayez plus tard.");
      } finally {
        setLoading(false);
      }
    };

    loadMyCourses();
  }, [user]);

  // UI helpers
  if (!user) {
    return (
      <div className="p-8 max-w-4xl mx-auto text-center">
        <h1 className="text-3xl font-bold text-green-600 mb-4">
          Dashboard Étudiant
        </h1>
        <p className="mb-6">Vous n'êtes pas connecté(e).</p>
        <div className="flex justify-center gap-4">
          <button
            onClick={() => navigate("/login")}
            className="px-6 py-2 bg-blue-600 text-white rounded-lg"
          >
            Se connecter
          </button>
          <Link to="/catalog" className="px-6 py-2 border rounded-lg">
            Parcourir le catalogue
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="p-8 max-w-5xl mx-auto">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-3xl font-bold text-blue-600">
            Bienvenue, {userData?.name || user.displayName || user.email} !
          </h1>
        </div>
      </div>

      {loading ? (
        <div className="p-6 bg-white rounded-lg shadow text-center">
          Chargement de vos cours...
        </div>
      ) : error ? (
        <div className="p-6 bg-red-100 rounded-lg text-red-700">{error}</div>
      ) : myCourses.length === 0 ? (
        // CAS : utilisateur connecté mais n'a pas de cours
        <div className="p-8 bg-white rounded-lg shadow text-center">
          <h2 className="text-2xl font-semibold mb-4">
            Vous n'avez aucun cours pour le moment
          </h2>
          <p className="text-gray-600 mb-6">
            Découvrez nos cours populaires et commencez votre apprentissage dès
            aujourd'hui.
          </p>
          <div className="flex justify-center gap-4">
            <Link
              to="/catalog"
              className="px-6 py-2 bg-blue-600 text-white rounded-lg"
            >
              Découvrir nos cours
            </Link>
          </div>
        </div>
      ) : (
        // CAS : afficher les cours de l'utilisateur
        <div className="space-y-6">
          <h2 className="text-xl font-semibold">
            Mes cours ({myCourses.length})
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {myCourses.map(({ courseId, joinedAt, courseData }) => (
              <div
                key={courseId}
                className="bg-white rounded-lg shadow p-4 flex gap-4"
              >
                <div className="w-28 h-20 bg-gray-200 rounded flex items-center justify-center">
                  {/* tu peux remplacer par une image si tu as courseData.thumbnail */}
                  <span className="text-xs text-gray-600">Aperçu</span>
                </div>

                <div className="flex-1">
                  <h3 className="font-semibold text-lg">{courseData.title}</h3>
                  <p className="text-sm text-gray-500 mb-2 line-clamp-2">
                    {courseData.description}
                  </p>
                  <div className="flex items-center justify-between mt-2">
                    <div className="text-xs text-gray-500">
                      {joinedAt
                        ? `Rejoint le ${new Date(
                            joinedAt.toDate ? joinedAt.toDate() : joinedAt
                          ).toLocaleDateString()}`
                        : ""}
                    </div>
                    <div className="flex gap-2">
                      <Link
                        to={`/course/${courseId}/content`}
                        className="px-3 py-1 bg-blue-600 text-white rounded-md text-sm"
                      >
                        Continuer
                      </Link>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default Dashboard;
