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
    progress,
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
  if (course === "not_found") return <p>Cours introuvable.</p>;
  if (course === "error") return <p>Erreur de chargement.</p>;

  if (!allowed)
    return (
      <div className="max-w-2xl mx-auto text-center p-12">
        <h2 className="text-2xl font-bold mb-4">Cours non accessible</h2>
        <p className="text-gray-600 mb-6">
          Vous devez rejoindre ce cours pour voir son contenu.
        </p>
        <button
          onClick={() => navigate(`/course/${id}`)}
          className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
        >
          Revenir à la page du cours
        </button>
      </div>
    );

  return (
    <div className="max-w-4xl mx-auto p-8">
      <h1 className="text-2xl font-bold mb-4">{course.title}</h1>

      {/* Vidéo */}
      {course.videoUrl && (
        <video
          src={course.videoUrl}
          controls
          className="rounded-lg shadow-lg mb-6 w-full"
        />
      )}

      {/* PDF */}
      {course.pdfUrl && (
        <a
          href={course.pdfUrl}
          target="_blank"
          rel="noopener noreferrer"
          className="text-blue-600 underline block mb-6"
        >
          📄 Télécharger le document PDF
        </a>
      )}

      {/* Description */}
      <div className="bg-white p-6 rounded-lg shadow mb-10">
        <h2 className="text-xl font-semibold mb-4">Contenu du cours</h2>
        <p className="text-gray-700">{course.description}</p>
      </div>

      {/* Avis */}
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
