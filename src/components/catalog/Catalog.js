// src/components/catalog/Catalog.js
import React from "react";
import Filters from "./Filters";
import CourseCard from "./CourseCard";

const Catalog = ({
  filteredCourses = [],
  search,
  setSearch,
  category,
  setCategory,
  priceRange,
  setPriceRange,
  sortBy,
  setSortBy,
  loading,
  error,
}) => {
  const categories = ["Développement", "Design", "Marketing", "Business"];

  return (
    <div className="page-content py-12 px-4 bg-gray-50">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="text-center mb-12">
          <h1 className="text-3xl md:text-4xl font-bold mb-4">
            Catalogue des cours
          </h1>
          <p className="text-gray-600 max-w-2xl mx-auto">
            Explorez notre large sélection de cours pour tous les niveaux
          </p>
        </div>

        {/* Filters */}
        <Filters
          search={search}
          setSearch={setSearch}
          category={category}
          setCategory={setCategory}
          priceRange={priceRange}
          setPriceRange={setPriceRange}
          sortBy={sortBy}
          setSortBy={setSortBy}
          categories={categories}
        />

        {/* Courses */}
        {loading ? (
          <div className="text-center">Chargement...</div>
        ) : error ? (
          <div className="text-center text-red-500">{error}</div>
        ) : filteredCourses.length === 0 ? (
          <div className="text-center text-gray-600">Aucun cours trouvé</div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {filteredCourses.map((course) => (
              <CourseCard key={course.id} course={course} />
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default Catalog;
