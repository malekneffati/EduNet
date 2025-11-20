import { useEffect, useState } from "react";
import { collection, getDocs } from "firebase/firestore";
import { db } from "../../firebase";

export default function usePopularCoursesViewModel() {
  const [courses, setCourses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const loadPopularCourses = async () => {
      try {
        const snap = await getDocs(collection(db, "courses"));

        const courseList = [];

        for (const courseDoc of snap.docs) {
          const courseId = courseDoc.id;
          const courseData = courseDoc.data();

          // Charger reviews du cours
          const reviewsSnap = await getDocs(
            collection(db, "courses", courseId, "reviews")
          );

          const reviews = reviewsSnap.docs.map((d) => d.data());

          // Calcul de la moyenne
          const avgRating =
            reviews.length > 0
              ? reviews.reduce((acc, r) => acc + r.rating, 0) / reviews.length
              : 0;

          courseList.push({
            id: courseId,
            ...courseData,
            rating: avgRating.toFixed(1),
          });
        }

        // Trier et garder les 3 meilleurs
        courseList.sort((a, b) => b.rating - a.rating);
        setCourses(courseList.slice(0, 3));
      } catch (err) {
        console.error("Erreur loading popular courses :", err);
        setError("Impossible de charger les cours populaires");
      } finally {
        setLoading(false);
      }
    };

    loadPopularCourses();
  }, []);

  return {
    courses,
    loading,
    error,
  };
}
