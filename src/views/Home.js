import React from "react";
import HeroSection from "../components/home/HeroSection";
import PopularCourses from "../components/home/PopularCourses";
import WhyChoose from "../components/home/WhyChoose";

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
