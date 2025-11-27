import React from "react";
import { useParams, useNavigate } from "react-router-dom";
import useCourseContentViewModel from "../viewmodels/courses/CourseContentViewModel";

const Star = ({ filled, onClick }) => (
  <span
    onClick={onClick}
    className={`cursor-pointer text-2xl ${
      filled ? "text-yellow-400" : "text-gray-400"
    }`}
  >
    ★
  </span>
);

const CourseContent = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const vm = useCourseContentViewModel(id);

  const {
    course,
    loading,
    allowed,
    chapters,
    reviews,
    newRating,
    setNewRating,
    newComment,
    setNewComment,
    sendingReview,
    submitReview,
    averageRating,
  } = vm;

  if (loading) return <p className="p-8 text-center">Chargement...</p>;
  if (course === "not_found")
    return <p className="text-center p-8">Cours introuvable.</p>;
  if (course === "error")
    return <p className="text-center p-8">Erreur de chargement.</p>;

  if (!allowed)
    return (
      <div className="p-8 text-center">
        <p>Vous n'avez pas accès à ce cours.</p>
        <button
          onClick={() => navigate(`/course/${id}`)}
          className="mt-4 bg-blue-600 text-white px-4 py-2 rounded-lg"
        >
          Retour
        </button>
      </div>
    );

  return (
    <div className="max-w-4xl mx-auto p-8">
      <h1 className="text-2xl font-bold mb-4">{course.title}</h1>

      {/* Chapters */}
      <div className="grid gap-6 mb-10">
        {chapters.length === 0 ? (
          <p className="text-gray-600">
            Aucun chapitre disponible pour ce cours.
          </p>
        ) : (
          chapters.map((chapter) => (
            <div
              key={chapter.id}
              className="bg-white rounded-lg shadow-md p-5 hover:shadow-lg transition-shadow"
            >
              <h2 className="text-lg font-semibold mb-2">{chapter.title}</h2>
              <p className="text-gray-700 mb-4">{chapter.description}</p>

              {/* Chapter Video */}
              {chapter.videoUrl && (
                <div className="mb-4">
                  <video
                    src={chapter.videoUrl}
                    controls
                    className="w-full max-w-md h-auto rounded-lg shadow"
                  />
                </div>
              )}

              {/* Chapter PDF */}
              {chapter.pdfUrl && (
                <a
                  href={chapter.pdfUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-blue-600 underline"
                >
                  📄 Télécharger le document PDF
                </a>
              )}
            </div>
          ))
        )}
      </div>

      {/* Leave Review */}
      <div className="bg-white p-6 rounded-lg shadow mb-10">
        <h2 className="text-xl font-semibold mb-4">Laisser un avis</h2>

        <div className="flex gap-2 mb-4">
          {[1, 2, 3, 4, 5].map((n) => (
            <Star
              key={n}
              filled={n <= newRating}
              onClick={() => setNewRating(n)}
            />
          ))}
        </div>

        <textarea
          value={newComment}
          onChange={(e) => setNewComment(e.target.value)}
          rows="3"
          placeholder="Votre avis..."
          className="w-full border p-3 rounded-lg mb-4"
        />

        <button
          onClick={submitReview}
          className="bg-blue-600 text-white px-4 py-2 rounded-lg"
          disabled={sendingReview}
        >
          {sendingReview ? "Envoi..." : "Publier l'avis"}
        </button>
      </div>
    </div>
  );
};

export default CourseContent;
