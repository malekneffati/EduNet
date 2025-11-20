import React from "react";
import { Link } from "react-router-dom";
import usePopularCoursesViewModel from "../../viewmodels/home/PopularCoursesViewModel";

const PopularCourses = () => {
  const { courses, loading, error } = usePopularCoursesViewModel();

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
