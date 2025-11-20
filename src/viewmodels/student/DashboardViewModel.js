// src/viewmodels/DashboardViewModel.js
import { useState, useEffect } from "react";
import { auth, db } from "../../firebase";
import {
  collection,
  getDocs,
  doc,
  getDoc,
  query,
  orderBy,
} from "firebase/firestore";

export const useDashboardViewModel = () => {
  const [user, setUser] = useState(null);
  const [userData, setUserData] = useState(null);
  const [myCourses, setMyCourses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // 🔹 Surveille l'état de l'auth
  useEffect(() => {
    const unsubscribe = auth.onAuthStateChanged((u) => setUser(u));
    return () => unsubscribe();
  }, []);

  // 🔹 Charger le profil utilisateur
  useEffect(() => {
    const loadUserProfile = async () => {
      if (!user) return;
      try {
        const snap = await getDoc(doc(db, "users", user.uid));
        if (snap.exists()) setUserData(snap.data());
      } catch (err) {
        console.error("Erreur chargement profil:", err);
      }
    };
    loadUserProfile();
  }, [user]);

  // 🔹 Charger les cours de l'utilisateur
  useEffect(() => {
    const loadMyCourses = async () => {
      if (!user) {
        setLoading(false);
        return;
      }
      setLoading(true);
      setError(null);

      try {
        const myCoursesRef = collection(db, "users", user.uid, "myCourses");
        const q = query(myCoursesRef, orderBy("joinedAt", "desc"));
        const snap = await getDocs(q);

        if (snap.empty) {
          setMyCourses([]);
          setLoading(false);
          return;
        }

        const coursePromises = snap.docs.map(async (d) => {
          const courseId = d.id;
          const meta = d.data();
          const courseSnap = await getDoc(doc(db, "courses", courseId));
          const courseData = courseSnap.exists()
            ? { id: courseSnap.id, ...courseSnap.data() }
            : null;
          return { courseId, joinedAt: meta.joinedAt || null, courseData };
        });

        const resolved = await Promise.all(coursePromises);
        setMyCourses(resolved.filter((c) => c.courseData));
      } catch (err) {
        console.error("Erreur loading myCourses:", err);
        setError("Impossible de charger vos cours. Réessayez plus tard.");
      } finally {
        setLoading(false);
      }
    };

    loadMyCourses();
  }, [user]);

  return { user, userData, myCourses, loading, error };
};
