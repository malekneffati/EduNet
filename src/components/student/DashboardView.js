// src/components/student/DashboardView.js
import React from "react";
import { Link, useNavigate } from "react-router-dom";
import MyCourseCard from "./MyCourseCard";



const DashboardView = ({ user, userData, myCourses, loading, error }) => {
  const navigate = useNavigate();

  if (!user) {
    return (
      <div className="p-8 max-w-4xl mx-auto text-center">
        <h1 className="text-3xl font-bold text-green-600 mb-4">
          Dashboard Étudiant
        </h1>
        <p className="mb-6">Vous n'êtes pas connecté(e).</p>
        <div className="flex justify-center gap-4">
          <button
            onClick={() => navigate("/login")}
            className="px-6 py-2 bg-blue-600 text-white rounded-lg"
          >
            Se connecter
          </button>
          <Link to="/catalog" className="px-6 py-2 border rounded-lg">
            Parcourir le catalogue
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="p-8 max-w-5xl mx-auto">
      <h1 className="text-3xl font-bold text-blue-600 mb-6">
        Bienvenue, {userData?.name || user.displayName || user.email} !
      </h1>

      {loading ? (
        <div className="p-6 bg-white rounded-lg shadow text-center">
          Chargement de vos cours...
        </div>
      ) : error ? (
        <div className="p-6 bg-red-100 rounded-lg text-red-700">{error}</div>
      ) : myCourses.length === 0 ? (
        <div className="p-8 bg-white rounded-lg shadow text-center">
          <h2 className="text-2xl font-semibold mb-4">
            Vous n'avez aucun cours pour le moment
          </h2>
          <p className="text-gray-600 mb-6">
            Découvrez nos cours populaires et commencez votre apprentissage dès
            aujourd'hui.
          </p>
          <Link
            to="/catalog"
            className="px-6 py-2 bg-blue-600 text-white rounded-lg"
          >
            Découvrir nos cours
          </Link>
        </div>
      ) : (
        <div className="space-y-6">
          <h2 className="text-xl font-semibold">
            Mes cours ({myCourses.length})
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {myCourses.map(({ courseId, joinedAt, courseData }) => (
              <MyCourseCard
                key={courseId}
                courseId={courseId}
                joinedAt={joinedAt}
                courseData={courseData}
              />
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default DashboardView;
