import React from "react";

const WhyChoose = () => {
  return (
    <section className="py-16 bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-12">
          <h2 className="text-3xl font-bold font-poppins text-gray-900 mb-4">
            Pourquoi choisir EduNet ?
          </h2>
          <p className="text-gray-600 max-w-2xl mx-auto">
            Rejoignez une plateforme conçue pour maximiser votre apprentissage
          </p>
        </div>

        <div className="grid md:grid-cols-3 gap-8">
          <div className="text-center">
            <div className="bg-blue-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
              <i className="fas fa-award text-blue-600 text-2xl"></i>
            </div>
            <h3 className="font-semibold text-lg mb-2">Qualité</h3>
            <p className="text-gray-600">
              Cours créés par des experts reconnus dans leur domaine
            </p>
          </div>
          <div className="text-center">
            <div className="bg-blue-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
              <i className="fas fa-universal-access text-blue-600 text-2xl"></i>
            </div>
            <h3 className="font-semibold text-lg mb-2">Accessibilité</h3>
            <p className="text-gray-600">
              Apprenez à votre rythme, où que vous soyez
            </p>
          </div>
          <div className="text-center">
            <div className="bg-blue-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
              <i className="fas fa-chart-bar text-blue-600 text-2xl"></i>
            </div>
            <h3 className="font-semibold text-lg mb-2">Suivi</h3>
            <p className="text-gray-600">
              Suivez votre progression et obtenez des certificats
            </p>
          </div>
        </div>
      </div>
    </section>
  );
};

export default WhyChoose;
