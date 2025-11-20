// src/components/catalog/CourseCard.js
import { Link } from "react-router-dom";

const CourseCard = ({ course }) => (
  <Link
    to={`/course/${course.id}/details`}
    className="card-shadow rounded-2xl overflow-hidden hover:scale-105 transition-transform"
  >
    <div className="bg-gradient-to-r from-blue-500 to-purple-600 h-48 flex items-center justify-center">
      <i className="fas fa-code text-white text-4xl"></i>
    </div>
    <div className="p-6">
      <h3 className="font-semibold text-lg mb-2">{course.title}</h3>
      <p className="text-gray-600 mb-2 line-clamp-2">
        {course.description || "Pas de description"}
      </p>
      <p className="text-gray-500 text-sm mb-2">Durée: {course.duration}</p>
      <p className="text-gray-500 text-sm mb-2">
        Instructeur: {course.instructor}
      </p>
      <div className="flex justify-between items-center">
        <span className="text-blue-600 font-bold">
          {course.isFree ? "Gratuit" : `${course.price} TND`}
        </span>
        <span className="text-yellow-500">
          <i className="fas fa-star"></i> {course.averageRating}
        </span>
      </div>
    </div>
  </Link>
);

export default CourseCard;
