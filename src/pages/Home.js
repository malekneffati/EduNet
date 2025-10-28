import React from "react";
import HeroSection from "../components/Home/HeroSection";
import PopularCourses from "../components/Home/PopularCourses";
import WhyChoose from "../components/Home/WhyChoose";

const Home = () => {
  return (
    <div id="home-page" className="page-content">
      <HeroSection />
      <PopularCourses />
      <WhyChoose />
    </div>
  );
};

export default Home;
