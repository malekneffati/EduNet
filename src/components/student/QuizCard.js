// src/components/student/QuizCard.js
import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { auth } from "../../firebase";
import QuizModel from "../../models/QuizModel";

const QuizCard = ({ courseId, chapter }) => {
  const navigate = useNavigate();
  const [progress, setProgress] = useState(null);
  const [loading, setLoading] = useState(true);
  const user = auth.currentUser;

  useEffect(() => {
    const loadProgress = async () => {
      if (!user || !chapter.quiz) {
        setLoading(false);
        return;
      }

      try {
        const userProgress = await QuizModel.getUserProgress(user.uid, courseId);
        const chapterProgress = userProgress.chaptersCompleted?.[chapter.id];
        setProgress(chapterProgress || null);
      } catch (error) {
        console.error("Erreur chargement progression:", error);
      } finally {
        setLoading(false);
      }
    };

    loadProgress();
  }, [user, courseId, chapter]);

  // Si pas de quiz pour ce chapitre
  if (!chapter.quiz || !chapter.quiz.questions || chapter.quiz.questions.length === 0) {
    return null;
  }

  const handleStartQuiz = () => {
    navigate(`/course/${courseId}/chapter/${chapter.id}/quiz`);
  };

  if (loading) {
    return (
      <div className="bg-gray-100 rounded-lg p-4 animate-pulse">
        <div className="h-6 bg-gray-300 rounded w-1/2 mb-2"></div>
        <div className="h-4 bg-gray-300 rounded w-3/4"></div>
      </div>
    );
  }

  return (
    <div className="bg-gradient-to-r from-blue-50 to-indigo-50 border-2 border-blue-200 rounded-lg p-5 mt-4">
      <div className="flex items-start justify-between gap-4">
        <div className="flex-1">
          <div className="flex items-center gap-2 mb-2">
            <svg
              className="w-6 h-6 text-blue-600"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
              />
            </svg>
            <h4 className="font-semibold text-gray-800">Quiz du chapitre</h4>
          </div>

          <p className="text-sm text-gray-600 mb-3">
            Testez vos connaissances avec {chapter.quiz.questions.length} questions
          </p>

          {progress && (
            <div className="mb-3">
              {progress.passed ? (
                <div className="flex items-center gap-2 text-green-700">
                  <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      fillRule="evenodd"
                      d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                      clipRule="evenodd"
                    />
                  </svg>
                  <span className="text-sm font-medium">
                    Quiz réussi - Score : {progress.quizPercentage}%
                  </span>
                </div>
              ) : (
                <div className="flex items-center gap-2 text-orange-600">
                  <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      fillRule="evenodd"
                      d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"
                      clipRule="evenodd"
                    />
                  </svg>
                  <span className="text-sm font-medium">
                    Dernier score : {progress.quizPercentage}%
                  </span>
                </div>
              )}
            </div>
          )}
        </div>

        <button
          onClick={handleStartQuiz}
          className="px-5 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium transition-colors shadow-md whitespace-nowrap"
        >
          {progress ? "Refaire le quiz" : "Passer le quiz"}
        </button>
      </div>
    </div>
  );
};

export default QuizCard;