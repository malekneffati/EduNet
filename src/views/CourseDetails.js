// src/views/CourseDetails.js
import React from "react";
import { useParams } from "react-router-dom";
import useCourseDetailsViewModel from "../viewmodels/courses/CourseDetailsViewModel";
import PaymentViewModel from "../viewmodels/courses/PaymentViewModel";

const CourseDetails = () => {
  const { id } = useParams();
  const {
    course,
    loading,
    reviews,
    averageRating,
    joinCourse,
    handlePayment,
    canAccessCourse,
  } = useCourseDetailsViewModel(id);

  if (loading) return <p className="p-8 text-center">Chargement...</p>;
  if (course === "not_found") return <p>Cours introuvable.</p>;
  if (course === "error") return <p>Erreur de chargement.</p>;

  const handlePay = async () => {
    const paymentData = await PaymentViewModel.startPayment(course, userId);

    if (paymentData?.payment_url) {
      // Rediriger l'utilisateur vers Paymee
      window.location.href = paymentData.payment_url;
    } else {
      alert("Erreur paiement : " + PaymentViewModel.error);
    }
  };

  return (
    <div className="max-w-5xl mx-auto py-12 px-4">
      <h1 className="text-3xl font-bold mb-2">{course.title}</h1>

      <div className="flex items-center gap-1 mb-6">
        {[1, 2, 3, 4, 5].map((n) => (
          <span
            key={n}
            className={`text-2xl ${
              n <= Math.round(averageRating)
                ? "text-yellow-400"
                : "text-gray-300"
            }`}
          >
            ★
          </span>
        ))}
        <span className="ml-2 text-gray-700">{averageRating}/5</span>
        <span className="text-gray-500 ml-2">({reviews.length} avis)</span>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
        <div className="md:col-span-2 space-y-6">
          <h2 className="text-xl font-semibold mb-3">
            Apercu gratuit du cour{" "}
          </h2>
          {course.videoUrl && (
            <video
              src={course.videoUrl}
              controls
              className="rounded-lg shadow-lg mb-6 w-full"
            />
          )}

          <div className="bg-white p-6 rounded-lg shadow">
            <h2 className="text-xl font-semibold mb-3">Description</h2>
            <p>{course.description}</p>
          </div>

          <div className="bg-white p-6 rounded-lg shadow">
            <h2 className="text-xl font-semibold mb-4">Avis des étudiants</h2>
            {reviews.length === 0 ? (
              <p className="text-gray-600">Aucun avis pour le moment.</p>
            ) : (
              reviews.map((rev) => (
                <div key={rev.id} className="bg-gray-100 p-4 rounded-lg mb-4">
                  <div className="flex gap-1">
                    {[1, 2, 3, 4, 5].map((n) => (
                      <span
                        key={n}
                        className={
                          n <= rev.rating ? "text-yellow-400" : "text-gray-300"
                        }
                      >
                        ★
                      </span>
                    ))}
                  </div>
                  <p className="mt-2">{rev.comment}</p>
                  <p className="text-xs text-gray-500">
                    {rev.createdAt?.toDate().toLocaleDateString()}
                  </p>
                </div>
              ))
            )}
          </div>
        </div>

        <div className="w-full md:w-80">
          <div className="bg-white p-6 rounded-lg shadow space-y-3">
            <p>
              <strong>Catégorie :</strong> {course.category}
            </p>
            <p>
              <strong>Durée :</strong> {course.duration}
            </p>
            <p>
              <strong>Instructeur :</strong> {course.instructor}
            </p>
            <hr />
            {course.isFree ? (
              <button
                onClick={joinCourse}
                className="w-full py-2 bg-green-600 text-white rounded-lg"
              >
                Commencer gratuitement
              </button>
            ) : canAccessCourse ? (
              <button
                onClick={joinCourse}
                className="w-full py-2 bg-green-600 text-white rounded-lg"
              >
                Accéder au cours
              </button>
            ) : (
              <button
                onClick={handlePayment}
                className="w-full py-2 bg-blue-600 text-white rounded-lg"
              >
                Payer maintenant — {course.price} TND
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default CourseDetails;
