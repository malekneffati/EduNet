// src/components/student/MyCourseCard.js
import React, { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import { auth } from "../../firebase";
import QuizModel from "../../models/QuizModel";

const MyCourseCard = ({ courseId, joinedAt, courseData }) => {
  const [progress, setProgress] = useState(null);
  const [loading, setLoading] = useState(true);
  const user = auth.currentUser;

  useEffect(() => {
    const loadProgress = async () => {
      if (!user) {
        setLoading(false);
        return;
      }

      try {
        const userProgress = await QuizModel.getUserProgress(user.uid, courseId);
        setProgress(userProgress);
      } catch (error) {
        console.error("Erreur chargement progression:", error);
      } finally {
        setLoading(false);
      }
    };

    loadProgress();
  }, [user, courseId]);

  // Calculer les statistiques
  const totalChapters = courseData.chapters?.length || 0;
  const completedChapters = progress?.chaptersCompleted
    ? Object.keys(progress.chaptersCompleted).length
    : 0;
  const progressPercentage =
    totalChapters > 0 ? Math.round((completedChapters / totalChapters) * 100) : 0;

  return (
    <div className="bg-white rounded-lg shadow p-4 flex gap-4">
      <div className="w-28 h-20 bg-gray-200 rounded flex items-center justify-center">
        <span className="text-xs text-gray-600">Aperçu</span>
      </div>
      <div className="flex-1">
        <h3 className="font-semibold text-lg">{courseData.title}</h3>
        <p className="text-sm text-gray-500 mb-2 line-clamp-2">
          {courseData.description}
        </p>

        {/* Barre de progression */}
        {!loading && totalChapters > 0 && (
          <div className="mb-2">
            <div className="flex justify-between items-center text-xs text-gray-600 mb-1">
              <span>Progression</span>
              <span className="font-medium">
                {completedChapters}/{totalChapters} chapitres
              </span>
            </div>
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div
                className="bg-blue-600 h-2 rounded-full transition-all duration-300"
                style={{ width: `${progressPercentage}%` }}
              />
            </div>
          </div>
        )}

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
            className="px-3 py-1 bg-blue-600 text-white rounded-md text-sm hover:bg-blue-700 transition"
          >
            Continuer
          </Link>
        </div>
      </div>
    </div>
  );
};

export default MyCourseCard;