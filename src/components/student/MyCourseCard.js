// src/components/student/MyCourseCard.js
import React from "react";
import { Link } from "react-router-dom";

const MyCourseCard = ({ courseId, joinedAt, courseData }) => (
  <div className="bg-white rounded-lg shadow p-4 flex gap-4">
    <div className="w-28 h-20 bg-gray-200 rounded flex items-center justify-center">
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
        <Link
          to={`/course/${courseId}/content`}
          className="px-3 py-1 bg-blue-600 text-white rounded-md text-sm"
        >
          Continuer
        </Link>
      </div>
    </div>
  </div>
);

export default MyCourseCard;
