// src/views/Quiz.js
import React from "react";
import { useParams, useNavigate } from "react-router-dom";
import { useQuizViewModel } from "../viewmodels/courses/QuizViewModel";
import QuizQuestion from "../components/student/QuizQuestion";
import QuizResults from "../components/student/QuizResults";

const Quiz = () => {
  const { id: courseId, chapterId } = useParams();
  const navigate = useNavigate();
  const vm = useQuizViewModel(courseId, chapterId);

  if (vm.loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Chargement du quiz...</p>
        </div>
      </div>
    );
  }

  if (vm.error) {
    return (
      <div className="min-h-screen flex items-center justify-center p-4">
        <div className="bg-white rounded-lg shadow-lg p-8 max-w-md w-full text-center">
          <div className="text-red-500 text-5xl mb-4">⚠️</div>
          <h2 className="text-2xl font-bold text-gray-800 mb-4">Erreur</h2>
          <p className="text-gray-600 mb-6">{vm.error}</p>
          <button
            onClick={() => navigate(`/course/${courseId}/content`)}
            className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
          >
            Retour au cours
          </button>
        </div>
      </div>
    );
  }

  // Écran de démarrage
  if (!vm.quizStarted) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4">
        <div className="bg-white rounded-2xl shadow-2xl p-8 max-w-2xl w-full">
          <div className="text-center mb-8">
            <div className="inline-block p-4 bg-blue-100 rounded-full mb-4">
              <svg
                className="w-12 h-12 text-blue-600"
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
            </div>
            <h1 className="text-3xl font-bold text-gray-800 mb-2">
              Quiz du chapitre
            </h1>
            <p className="text-gray-600">
              Testez vos connaissances sur ce chapitre
            </p>
          </div>

          <div className="bg-blue-50 rounded-lg p-6 mb-6">
            <h3 className="font-semibold text-gray-800 mb-4">
              📋 Instructions :
            </h3>
            <ul className="space-y-2 text-gray-700">
              <li className="flex items-start">
                <span className="text-blue-600 mr-2">•</span>
                <span>
                  Ce quiz contient <strong>{vm.totalQuestions} questions</strong>
                </span>
              </li>
              <li className="flex items-start">
                <span className="text-blue-600 mr-2">•</span>
                <span>
                  Score de passage : <strong>{vm.quiz?.passingScore || 60}%</strong>
                </span>
              </li>
              <li className="flex items-start">
                <span className="text-blue-600 mr-2">•</span>
                <span>Vous pouvez refaire le quiz autant de fois que vous voulez</span>
              </li>
              <li className="flex items-start">
                <span className="text-blue-600 mr-2">•</span>
                <span>Prenez votre temps, il n'y a pas de limite</span>
              </li>
            </ul>
          </div>

          <div className="flex gap-4">
            <button
              onClick={() => navigate(`/course/${courseId}/content`)}
              className="flex-1 px-6 py-3 border-2 border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 font-medium transition"
            >
              Annuler
            </button>
            <button
              onClick={vm.startQuiz}
              className="flex-1 px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium transition shadow-lg"
            >
              Commencer le quiz
            </button>
          </div>
        </div>
      </div>
    );
  }

  // Affichage des résultats
  if (vm.showResults) {
    return (
      <QuizResults
        score={vm.score}
        totalQuestions={vm.totalQuestions}
        percentage={vm.percentage}
        passed={vm.passed}
        passingScore={vm.quiz?.passingScore || 60}
        onRetry={vm.retryQuiz}
        onBackToCourse={() => navigate(`/course/${courseId}/content`)}
        questions={vm.quiz.questions}
        selectedAnswers={vm.selectedAnswers}
      />
    );
  }

  // Affichage de la question en cours
  return (
    <div className="min-h-screen bg-gray-50 py-8 px-4">
      <div className="max-w-4xl mx-auto">
        {/* En-tête avec progression */}
        <div className="bg-white rounded-lg shadow-md p-6 mb-6">
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-bold text-gray-800">
              Question {vm.currentQuestionIndex + 1} sur {vm.totalQuestions}
            </h2>
            <button
              onClick={() => navigate(`/course/${courseId}/content`)}
              className="text-gray-500 hover:text-gray-700"
            >
              ✕ Quitter
            </button>
          </div>

          {/* Barre de progression */}
          <div className="w-full bg-gray-200 rounded-full h-2">
            <div
              className="bg-blue-600 h-2 rounded-full transition-all duration-300"
              style={{
                width: `${((vm.currentQuestionIndex + 1) / vm.totalQuestions) * 100}%`,
              }}
            />
          </div>
        </div>

        {/* Question */}
        <QuizQuestion
          question={vm.currentQuestion}
          selectedAnswer={vm.selectedAnswers[vm.currentQuestion?.id]}
          onSelectAnswer={(answerIndex) =>
            vm.selectAnswer(vm.currentQuestion.id, answerIndex)
          }
        />

        {/* Navigation */}
        <div className="bg-white rounded-lg shadow-md p-6 mt-6">
          <div className="flex justify-between items-center">
            <button
              onClick={vm.previousQuestion}
              disabled={vm.currentQuestionIndex === 0}
              className={`px-6 py-2 rounded-lg font-medium transition ${
                vm.currentQuestionIndex === 0
                  ? "bg-gray-100 text-gray-400 cursor-not-allowed"
                  : "bg-gray-200 text-gray-700 hover:bg-gray-300"
              }`}
            >
              ← Précédent
            </button>

            {vm.currentQuestionIndex === vm.totalQuestions - 1 ? (
              <button
                onClick={vm.submitQuiz}
                disabled={vm.submitting}
                className="px-8 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 font-medium transition shadow-lg disabled:opacity-50"
              >
                {vm.submitting ? "Soumission..." : "Soumettre le quiz"}
              </button>
            ) : (
              <button
                onClick={vm.nextQuestion}
                className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium transition"
              >
                Suivant →
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default Quiz;