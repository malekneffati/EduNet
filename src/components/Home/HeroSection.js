import React from "react";
import { Link } from "react-router-dom";

const HeroSection = () => {
  return (
    <section className="bg-gradient-to-r from-blue-600 to-purple-600 text-white py-20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid md:grid-cols-2 gap-12 items-center">
          <div>
            <h1 className="text-4xl md:text-5xl font-bold font-poppins mb-6">
              Apprenez autrement avec EduNet.
            </h1>
            <p className="text-xl mb-8 opacity-90">
              Découvrez des milliers de cours en ligne pour développer vos
              compétences et atteindre vos objectifs professionnels.
            </p>
            <div className="space-x-4">
              <Link
                to="/catalog"
                className="inline-block bg-white text-blue-900 px-8 py-3 rounded-lg font-semibold hover:bg-gray-100 transition"
              >
                Explorer les cours
              </Link>
              <Link
                to="/subscription"
                className="inline-block border-2 border-white text-white px-8 py-3 rounded-lg font-semibold hover:bg-white hover:text-blue-900 transition"
              >
                S'abonner
              </Link>
            </div>
          </div>
          <div className="text-center">
            <div className="bg-white bg-opacity-10 rounded-2xl p-8">
              <i className="fas fa-graduation-cap text-8xl mb-4"></i>
              <p className="text-lg font-medium">
                Plus de 10,000 étudiants nous font confiance
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default HeroSection;
