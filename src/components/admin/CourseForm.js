// src/components/admin/CourseForm.js
import React, { useState, useEffect } from "react";
import UploadVideo from "./UploadVideo";
import UploadPDF from "./UploadPDF";
import useCourseFormViewModel from "../../viewmodels/admin/CourseFormViewModel";

const CourseForm = ({ initialData, onSave, onCancel }) => {
  const vm = useCourseFormViewModel(initialData, onSave, onCancel);
  const [expandedQuiz, setExpandedQuiz] = useState({});

  // Auto-expand quiz qui ont déjà des questions lors de l'édition
  useEffect(() => {
    if (initialData?.chapters) {
      const expanded = {};
      initialData.chapters.forEach((chapter) => {
        if (chapter.quiz && chapter.quiz.questions?.length > 0) {
          expanded[chapter.id] = true;
        }
      });
      setExpandedQuiz(expanded);
    }
  }, [initialData]);

  const toggleQuizExpand = (chapterId) => {
    setExpandedQuiz((prev) => ({
      ...prev,
      [chapterId]: !prev[chapterId],
    }));
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50">
      {/* Overlay cliquable */}
      <div 
        className="absolute inset-0" 
        onClick={vm.onCancel}
      />

      {/* Modal container avec scroll */}
      <div className="relative z-10 w-full max-w-5xl max-h-[95vh] bg-white rounded-2xl shadow-2xl flex flex-col">
        
        {/* Header fixe */}
        <div className="flex-shrink-0 px-6 py-4 border-b bg-white rounded-t-2xl sticky top-0 z-20">
          <div className="flex justify-between items-center">
            <h2 className="text-2xl font-bold text-gray-800">
              {initialData ? "Modifier le cours" : "Ajouter un cours"}
            </h2>
            <button
              type="button"
              onClick={vm.onCancel}
              className="text-gray-400 hover:text-gray-600 text-2xl font-bold"
            >
              ✕
            </button>
          </div>
        </div>

        {/* Contenu scrollable */}
        <div className="flex-1 overflow-y-auto px-6 py-4">
          <form
            id="course-form"
            onSubmit={vm.handleSubmit}
            className="space-y-5"
          >
            {/* Titre */}
            <div>
              <label className="block font-medium text-sm text-gray-700 mb-2">
                Titre du cours <span className="text-red-500">*</span>
              </label>
              <input
                required
                className="w-full border border-gray-300 rounded-lg px-4 py-2"
                value={vm.title}
                onChange={(e) => vm.setTitle(e.target.value)}
                placeholder="Ex: Développement Web Complet"
              />
            </div>

            {/* Description */}
            <div>
              <label className="block font-medium text-sm text-gray-700 mb-2">
                Description
              </label>
              <textarea
                rows="4"
                className="w-full border border-gray-300 rounded-lg px-4 py-2"
                value={vm.description}
                onChange={(e) => vm.setDescription(e.target.value)}
                placeholder="Décrivez le contenu du cours..."
              />
            </div>

            {/* Catégorie + Instructeur */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block font-medium text-sm text-gray-700 mb-2">
                  Catégorie
                </label>
                <select
                  className="w-full border rounded-lg px-4 py-2"
                  value={vm.category}
                  onChange={(e) => vm.setCategory(e.target.value)}
                >
                  {vm.categories.map((cat) => (
                    <option key={cat} value={cat}>
                      {cat}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block font-medium text-sm text-gray-700 mb-2">
                  Instructeur
                </label>
                <input
                  className="w-full border rounded-lg px-4 py-2"
                  value={vm.instructor}
                  onChange={(e) => vm.setInstructor(e.target.value)}
                  placeholder="Ex: Jean Dupont"
                />
              </div>
            </div>

            {/* Durée */}
            <div>
              <label className="block font-medium text-sm text-gray-700 mb-2">
                Durée
              </label>
              <input
                className="w-full border rounded-lg px-4 py-2"
                value={vm.duration}
                onChange={(e) => vm.setDuration(e.target.value)}
                placeholder="Ex: 12 heures"
              />
            </div>

            {/* Prix / Gratuit */}
            <div className="bg-gray-50 p-4 rounded-lg">
              <label className="flex items-center gap-3 cursor-pointer">
                <input
                  type="checkbox"
                  checked={vm.isFree}
                  onChange={(e) => vm.setIsFree(e.target.checked)}
                  className="w-5 h-5"
                />
                <span className="font-medium">Cours gratuit</span>
              </label>

              {!vm.isFree && (
                <div className="mt-3">
                  <label className="block text-sm mb-1">Prix (TND)</label>
                  <input
                    type="number"
                    min="0"
                    step="0.01"
                    value={vm.price}
                    onChange={(e) => vm.setPrice(e.target.value)}
                    className="w-full md:w-48 border rounded-lg px-4 py-2"
                    placeholder="Ex: 89"
                  />
                </div>
              )}
            </div>

            {/* Vidéo Aperçu */}
            <div className="bg-blue-50 p-4 rounded-lg">
              <label className="block font-medium mb-3">🎬 Aperçu gratuit</label>
              <UploadVideo
                onUploadComplete={(url) => vm.setVideoUrl(url)}
                existingUrl={vm.videoUrl}
              />
            </div>

            {/* 🔥 CHAPITRES */}
            <div className="border-t pt-6">
              <h3 className="text-xl font-semibold mb-4">Chapitres du cours</h3>

              {vm.chapters.length === 0 && (
                <p className="text-gray-500 text-center py-8 bg-gray-50 rounded-lg">
                  Aucun chapitre ajouté. Cliquez sur le bouton ci-dessous pour commencer.
                </p>
              )}

              {vm.chapters.map((chapter, index) => (
                <div
                  key={chapter.id}
                  className="mb-6 p-5 border-2 border-gray-200 rounded-xl bg-gray-50 shadow-sm"
                >
                  <div className="flex justify-between items-center mb-4">
                    <h4 className="font-bold text-lg text-blue-600">
                      Chapitre {index + 1}
                    </h4>
                    <button
                      type="button"
                      onClick={() => vm.removeChapter(chapter.id)}
                      className="px-3 py-1 text-red-600 hover:bg-red-50 rounded-lg transition"
                    >
                      🗑️ Supprimer
                    </button>
                  </div>

                  {/* Titre chapitre */}
                  <div className="mb-3">
                    <label className="block text-sm font-medium mb-1">Titre</label>
                    <input
                      className="w-full border rounded-lg px-3 py-2"
                      value={chapter.title}
                      onChange={(e) =>
                        vm.updateChapter(chapter.id, "title", e.target.value)
                      }
                      placeholder="Ex: Introduction au Marketing Digital"
                    />
                  </div>

                  {/* Description chapitre */}
                  <div className="mb-3">
                    <label className="block text-sm font-medium mb-1">
                      Description
                    </label>
                    <textarea
                      className="w-full border rounded-lg px-3 py-2"
                      rows={3}
                      value={chapter.description}
                      onChange={(e) =>
                        vm.updateChapter(chapter.id, "description", e.target.value)
                      }
                      placeholder="Description du chapitre"
                    />
                  </div>

                  {/* Vidéo */}
                  <div className="mb-3">
                    <label className="block text-sm font-medium mb-1">
                      Vidéo du chapitre
                    </label>
                    <UploadVideo
                      onUploadComplete={(url) =>
                        vm.updateChapter(chapter.id, "videoUrl", url)
                      }
                      existingUrl={chapter.videoUrl}
                    />
                  </div>

                  {/* PDF */}
                  <div className="mb-4">
                    <label className="block text-sm font-medium mb-1">
                      PDF du chapitre
                    </label>
                    <UploadPDF
                      existingUrl={chapter.pdfUrl}
                      onUploadComplete={(url) =>
                        vm.updateChapter(chapter.id, "pdfUrl", url)
                      }
                    />
                  </div>

                  {/* QUIZ SECTION */}
                  <div className="mt-4 p-4 bg-gradient-to-r from-blue-50 to-indigo-50 rounded-lg border-2 border-blue-300">
                    <div className="flex justify-between items-center mb-3">
                      <h5 className="font-bold text-blue-800 flex items-center gap-2">
                        📝 Quiz du chapitre
                        {chapter.quiz && (
                          <span className="text-xs bg-blue-600 text-white px-2 py-1 rounded-full">
                            {chapter.quiz.questions?.length || 0} questions
                          </span>
                        )}
                      </h5>
                      {!chapter.quiz ? (
                        <button
                          type="button"
                          onClick={() => {
                            vm.addQuizToChapter(chapter.id);
                            setExpandedQuiz((prev) => ({
                              ...prev,
                              [chapter.id]: true,
                            }));
                          }}
                          className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 text-sm font-medium transition shadow"
                        >
                          ➕ Créer un quiz
                        </button>
                      ) : (
                        <div className="flex gap-2">
                          <button
                            type="button"
                            onClick={() => toggleQuizExpand(chapter.id)}
                            className="px-3 py-1 bg-blue-100 text-blue-700 rounded-lg hover:bg-blue-200 text-sm font-medium transition"
                          >
                            {expandedQuiz[chapter.id] ? "🔼 Réduire" : "🔽 Développer"}
                          </button>
                          <button
                            type="button"
                            onClick={() => {
                              if (
                                window.confirm(
                                  "Êtes-vous sûr de vouloir supprimer ce quiz ?"
                                )
                              ) {
                                vm.removeQuizFromChapter(chapter.id);
                              }
                            }}
                            className="px-3 py-1 bg-red-500 text-white rounded-lg hover:bg-red-600 text-sm font-medium transition"
                          >
                            🗑️ Supprimer
                          </button>
                        </div>
                      )}
                    </div>

                    {chapter.quiz && expandedQuiz[chapter.id] && (
                      <div className="space-y-4 mt-4">
                        {/* Score de passage */}
                        <div className="bg-white p-3 rounded-lg">
                          <label className="block text-sm font-medium mb-1">
                            Score minimum requis (%)
                          </label>
                          <input
                            type="number"
                            min="0"
                            max="100"
                            value={chapter.quiz.passingScore || 60}
                            onChange={(e) =>
                              vm.updateQuizPassingScore(chapter.id, e.target.value)
                            }
                            className="w-32 border rounded px-3 py-2"
                          />
                        </div>

                        {/* Questions */}
                        <div>
                          <div className="flex justify-between items-center mb-3">
                            <span className="font-semibold text-gray-700">
                              Questions du quiz
                            </span>
                            <button
                              type="button"
                              onClick={() => vm.addQuestionToQuiz(chapter.id)}
                              className="px-3 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 text-sm font-medium transition shadow"
                            >
                              ➕ Ajouter une question
                            </button>
                          </div>

                          {(!chapter.quiz.questions ||
                            chapter.quiz.questions.length === 0) && (
                            <p className="text-gray-500 text-center py-4 bg-white rounded-lg">
                              Aucune question. Cliquez sur "Ajouter une question".
                            </p>
                          )}

                          <div className="space-y-4">
                            {chapter.quiz.questions?.map((question, qIndex) => (
                              <div
                                key={question.id}
                                className="p-4 bg-white rounded-lg border-2 border-gray-200 shadow-sm"
                              >
                                <div className="flex justify-between items-center mb-3">
                                  <span className="font-bold text-gray-700">
                                    Question {qIndex + 1}
                                  </span>
                                  <button
                                    type="button"
                                    onClick={() => {
                                      if (
                                        window.confirm(
                                          "Supprimer cette question ?"
                                        )
                                      ) {
                                        vm.removeQuestionFromQuiz(
                                          chapter.id,
                                          question.id
                                        );
                                      }
                                    }}
                                    className="text-red-500 hover:text-red-700 text-sm font-medium"
                                  >
                                    🗑️ Supprimer
                                  </button>
                                </div>

                                {/* Question text */}
                                <div className="mb-3">
                                  <label className="block text-sm font-medium mb-1">
                                    Énoncé de la question
                                  </label>
                                  <input
                                    className="w-full border rounded-lg px-3 py-2"
                                    value={question.question}
                                    onChange={(e) =>
                                      vm.updateQuizQuestion(
                                        chapter.id,
                                        question.id,
                                        "question",
                                        e.target.value
                                      )
                                    }
                                    placeholder="Posez votre question..."
                                  />
                                </div>

                                {/* Options */}
                                <div className="mb-3">
                                  <label className="block text-sm font-medium mb-2">
                                    Options de réponse (cochez la bonne réponse)
                                  </label>
                                  <div className="space-y-2">
                                    {question.options?.map((option, optIndex) => (
                                      <div
                                        key={optIndex}
                                        className="flex items-center gap-3 bg-gray-50 p-2 rounded"
                                      >
                                        <input
                                          type="radio"
                                          name={`correct-${chapter.id}-${question.id}`}
                                          checked={
                                            question.correctAnswer === optIndex
                                          }
                                          onChange={() =>
                                            vm.updateQuizQuestion(
                                              chapter.id,
                                              question.id,
                                              "correctAnswer",
                                              optIndex
                                            )
                                          }
                                          className="w-4 h-4 text-green-600"
                                        />
                                        <span className="font-medium text-gray-600 w-6">
                                          {String.fromCharCode(65 + optIndex)}.
                                        </span>
                                        <input
                                          className="flex-1 border rounded px-3 py-2"
                                          value={option}
                                          onChange={(e) =>
                                            vm.updateQuizQuestionOption(
                                              chapter.id,
                                              question.id,
                                              optIndex,
                                              e.target.value
                                            )
                                          }
                                          placeholder={`Option ${String.fromCharCode(
                                            65 + optIndex
                                          )}`}
                                        />
                                      </div>
                                    ))}
                                  </div>
                                </div>

                                {/* Explication */}
                                <div>
                                  <label className="block text-sm font-medium mb-1">
                                    Explication (optionnel)
                                  </label>
                                  <textarea
                                    className="w-full border rounded-lg px-3 py-2"
                                    rows={2}
                                    value={question.explanation || ""}
                                    onChange={(e) =>
                                      vm.updateQuizQuestion(
                                        chapter.id,
                                        question.id,
                                        "explanation",
                                        e.target.value
                                      )
                                    }
                                    placeholder="Explication de la réponse"
                                  />
                                </div>
                              </div>
                            ))}
                          </div>
                        </div>
                      </div>
                    )}
                  </div>
                </div>
              ))}

              <button
                type="button"
                onClick={vm.addChapter}
                className="w-full py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium transition shadow-lg"
              >
                ➕ Ajouter un chapitre
              </button>
            </div>
          </form>
        </div>

        {/* Footer fixe avec boutons d'action */}
        <div className="flex-shrink-0 px-6 py-4 border-t bg-gray-50 rounded-b-2xl">
          <div className="flex justify-end gap-3">
            <button
              type="button"
              onClick={vm.onCancel}
              className="px-6 py-3 border-2 border-gray-300 rounded-lg hover:bg-white font-medium transition"
            >
              Annuler
            </button>

            <button
              type="submit"
              form="course-form"
              className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium transition shadow-lg"
            >
              {initialData ? "💾 Mettre à jour" : "✨ Créer le cours"}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default CourseForm;