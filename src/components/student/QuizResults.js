// src/components/student/QuizResults.js
import React, { useState } from "react";

const QuizResults = ({
  score,
  totalQuestions,
  percentage,
  passed,
  passingScore,
  onRetry,
  onBackToCourse,
  questions,
  selectedAnswers,
}) => {
  const [showDetails, setShowDetails] = useState(false);

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-2xl p-8 max-w-2xl w-full">
        {/* Icône de résultat */}
        <div className="text-center mb-6">
          <div
            className={`inline-block p-6 rounded-full mb-4 ${
              passed ? "bg-green-100" : "bg-orange-100"
            }`}
          >
            {passed ? (
              <svg
                className="w-16 h-16 text-green-600"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
            ) : (
              <svg
                className="w-16 h-16 text-orange-600"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
            )}
          </div>

          <h1
            className={`text-3xl font-bold mb-2 ${
              passed ? "text-green-600" : "text-orange-600"
            }`}
          >
            {passed ? "🎉 Félicitations !" : "Continuez vos efforts !"}
          </h1>
          <p className="text-gray-600">
            {passed
              ? "Vous avez réussi le quiz avec succès !"
              : "Vous n'avez pas atteint le score de passage"}
          </p>
        </div>

        {/* Score */}
        <div className="bg-gradient-to-r from-blue-50 to-indigo-50 rounded-xl p-8 mb-6">
          <div className="text-center">
            <div className="text-6xl font-bold text-blue-600 mb-2">
              {percentage}%
            </div>
            <p className="text-gray-700 text-lg">
              {score} sur {totalQuestions} bonnes réponses
            </p>
            <p className="text-sm text-gray-500 mt-2">
              Score minimum requis : {passingScore}%
            </p>
          </div>

          {/* Barre de progression circulaire */}
          <div className="relative w-32 h-32 mx-auto mt-6">
            <svg className="transform -rotate-90 w-32 h-32">
              <circle
                cx="64"
                cy="64"
                r="56"
                stroke="currentColor"
                strokeWidth="8"
                fill="transparent"
                className="text-gray-200"
              />
              <circle
                cx="64"
                cy="64"
                r="56"
                stroke="currentColor"
                strokeWidth="8"
                fill="transparent"
                strokeDasharray={2 * Math.PI * 56}
                strokeDashoffset={2 * Math.PI * 56 * (1 - percentage / 100)}
                className={passed ? "text-green-500" : "text-orange-500"}
                strokeLinecap="round"
              />
            </svg>
          </div>
        </div>

        {/* Bouton pour afficher les détails */}
        <button
          onClick={() => setShowDetails(!showDetails)}
          className="w-full mb-4 px-4 py-3 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition font-medium"
        >
          {showDetails ? "Masquer les détails" : "Voir les réponses détaillées"} 
          {showDetails ? " ▲" : " ▼"}
        </button>

        {/* Détails des réponses */}
        {showDetails && (
          <div className="mb-6 max-h-96 overflow-y-auto bg-gray-50 rounded-lg p-4">
            <h3 className="font-semibold text-gray-800 mb-4">
              Résumé de vos réponses :
            </h3>
            <div className="space-y-4">
              {questions.map((question, index) => {
                const userAnswer = selectedAnswers[question.id];
                const isCorrect = userAnswer === question.correctAnswer;
                const optionLabel = (i) => String.fromCharCode(65 + i);

                return (
                  <div
                    key={question.id}
                    className={`p-4 rounded-lg border-2 ${
                      isCorrect
                        ? "bg-green-50 border-green-200"
                        : "bg-red-50 border-red-200"
                    }`}
                  >
                    <div className="flex items-start gap-2 mb-2">
                      <span
                        className={`font-semibold ${
                          isCorrect ? "text-green-700" : "text-red-700"
                        }`}
                      >
                        {isCorrect ? "✓" : "✗"}
                      </span>
                      <div className="flex-1">
                        <p className="font-medium text-gray-800 mb-2">
                          Q{index + 1}: {question.question}
                        </p>
                        <p className="text-sm text-gray-600">
                          <span className="font-medium">Votre réponse :</span>{" "}
                          {optionLabel(userAnswer)} - {question.options[userAnswer]}
                        </p>
                        {!isCorrect && (
                          <p className="text-sm text-green-700 mt-1">
                            <span className="font-medium">Bonne réponse :</span>{" "}
                            {optionLabel(question.correctAnswer)} -{" "}
                            {question.options[question.correctAnswer]}
                          </p>
                        )}
                        {question.explanation && (
                          <p className="text-sm text-gray-600 mt-2 italic">
                            💡 {question.explanation}
                          </p>
                        )}
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {/* Actions */}
        <div className="flex gap-4">
          <button
            onClick={onBackToCourse}
            className="flex-1 px-6 py-3 border-2 border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 font-medium transition"
          >
            Retour au cours
          </button>
          <button
            onClick={onRetry}
            className="flex-1 px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium transition shadow-lg"
          >
            Refaire le quiz
          </button>
        </div>

        {/* Message d'encouragement */}
        {!passed && (
          <p className="text-center text-sm text-gray-500 mt-4">
            💪 Ne vous découragez pas ! Révisez le chapitre et réessayez.
          </p>
        )}
      </div>
    </div>
  );
};

export default QuizResults;