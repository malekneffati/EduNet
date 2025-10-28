import React, { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { collection, getDocs } from "firebase/firestore";
import { db } from "../../firebase";

const PopularCourses = () => {
  const [courses, setCourses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchPopularCourses = async () => {
      try {
        const querySnapshot = await getDocs(collection(db, "courses"));
        setCourses(
          querySnapshot.docs
            .map((doc) => ({ id: doc.id, ...doc.data() }))
            .slice(0, 3)
        );
      } catch (err) {
        console.error("Error fetching courses:", err);
        setCourses([
          {
            id: "1",
            title: "Développement Web",
            description: "Apprenez HTML, CSS, JS",
            price: "89",
            rating: "4.8",
            image: "",
          },
          {
            id: "2",
            title: "Design UI/UX",
            description: "Maîtrisez Figma et design",
            price: "75",
            rating: "4.9",
            image: "",
          },
          {
            id: "3",
            title: "Marketing Digital",
            description: "SEO et réseaux sociaux",
            price: "0",
            rating: "4.7",
            image: "",
          },
        ]);
      } finally {
        setLoading(false);
      }
    };
    fetchPopularCourses();
  }, []);

  return (
    <section className="py-16 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-12">
          <h2 className="text-3xl font-bold font-poppins text-gray-900 mb-4">
            Cours populaires
          </h2>
          <p className="text-gray-600 max-w-2xl mx-auto">
            Découvrez les cours les plus appréciés par notre communauté
            d'apprenants
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
                      {course.price} TND
                    </span>
                    <span className="text-yellow-500">
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
