import React, { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { collection, getDocs, doc, getDoc } from "firebase/firestore";
import { db } from "../../firebase";

const PopularCourses = () => {
  const [courses, setCourses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Charger tous les cours + calculer la moyenne
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

        // Trier du plus haut au plus bas
        courseList.sort((a, b) => b.rating - a.rating);

        // Garder seulement 3 cours
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

  return (
    <section className="py-16 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-12">
          <h2 className="text-3xl font-bold font-poppins text-gray-900 mb-4">
            Cours populaires
          </h2>
          <p className="text-gray-600 max-w-2xl mx-auto">
            Découvrez les cours les mieux notés par nos apprenants
          </p>
        </div>

        {loading ? (
          <div className="text-center">Chargement des cours...</div>
        ) : error ? (
          <div className="text-center text-red-500">{error}</div>
        ) : (
          <div className="grid md:grid-cols-3 gap-8">
            {courses.map((course) => (
              <Link
                key={course.id}
                to={`/course/${course.id}`}
                className="card-shadow rounded-2xl overflow-hidden hover:scale-105 transition-transform duration-300 cursor-pointer"
              >
                <div className="bg-gradient-to-r from-blue-500 to-purple-600 h-48 flex items-center justify-center">
                  <i className="fas fa-code text-white text-4xl"></i>
                </div>
                <div className="p-6">
                  <h3 className="font-semibold text-lg mb-2">{course.title}</h3>

                  <p className="text-gray-600 mb-4 line-clamp-2">
                    {course.description}
                  </p>

                  <div className="flex justify-between items-center">
                    <span className="text-blue-600 font-bold">
                      {course.price === 0 ? "Gratuit" : `${course.price} TND`}
                    </span>

                    <span className="text-yellow-500 font-medium">
                      <i className="fas fa-star"></i> {course.rating}
                    </span>
                  </div>
                </div>
              </Link>
            ))}
          </div>
        )}
      </div>
    </section>
  );
};

export default PopularCourses;
