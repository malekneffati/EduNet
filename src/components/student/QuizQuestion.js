// src/components/student/QuizQuestion.js
import React from "react";

const QuizQuestion = ({ question, selectedAnswer, onSelectAnswer }) => {
  if (!question) return null;

  return (
    <div className="bg-white rounded-lg shadow-md p-8">
      {/* Question */}
      <h3 className="text-2xl font-semibold text-gray-800 mb-8">
        {question.question}
      </h3>

      {/* Options */}
      <div className="space-y-4">
        {question.options.map((option, index) => {
          const isSelected = selectedAnswer === index;
          const optionLabel = String.fromCharCode(65 + index); // A, B, C, D

          return (
            <button
              key={index}
              onClick={() => onSelectAnswer(index)}
              className={`w-full text-left p-5 rounded-lg border-2 transition-all duration-200 ${
                isSelected
                  ? "border-blue-600 bg-blue-50 shadow-md"
                  : "border-gray-200 hover:border-blue-300 hover:bg-gray-50"
              }`}
            >
              <div className="flex items-start gap-4">
                {/* Cercle de sélection */}
                <div
                  className={`flex-shrink-0 w-8 h-8 rounded-full border-2 flex items-center justify-center font-semibold ${
                    isSelected
                      ? "border-blue-600 bg-blue-600 text-white"
                      : "border-gray-300 text-gray-500"
                  }`}
                >
                  {optionLabel}
                </div>

                {/* Texte de l'option */}
                <span
                  className={`flex-1 text-lg ${
                    isSelected ? "text-blue-900 font-medium" : "text-gray-700"
                  }`}
                >
                  {option}
                </span>

                {/* Indicateur de sélection */}
                {isSelected && (
                  <div className="flex-shrink-0 text-blue-600">
                    <svg
                      className="w-6 h-6"
                      fill="currentColor"
                      viewBox="0 0 20 20"
                    >
                      <path
                        fillRule="evenodd"
                        d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                        clipRule="evenodd"
                      />
                    </svg>
                  </div>
                )}
              </div>
            </button>
          );
        })}
      </div>

      {/* Aide visuelle */}
      {selectedAnswer === undefined && (
        <p className="mt-6 text-sm text-gray-500 text-center">
          💡 Sélectionnez une réponse pour continuer
        </p>
      )}
    </div>
  );
};

export default QuizQuestion;
