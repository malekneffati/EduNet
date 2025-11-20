// src/viewmodels/courses/CatalogViewModel.js
import { useState, useEffect } from "react";
import { fetchCoursesFromDB } from "../../models/CourseModel";

export const useCatalogViewModel = () => {
  const [courses, setCourses] = useState([]);
  const [filteredCourses, setFilteredCourses] = useState([]);
  const [search, setSearch] = useState("");
  const [category, setCategory] = useState("");
  const [priceRange, setPriceRange] = useState("");
  const [sortBy, setSortBy] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const loadCourses = async () => {
      try {
        setLoading(true);
        const data = await fetchCoursesFromDB();
        setCourses(data);
        setFilteredCourses(data);
      } catch (err) {
        console.error(err);
        setError("Impossible de charger les cours.");
      } finally {
        setLoading(false);
      }
    };
    loadCourses();
  }, []);

  useEffect(() => {
    let result = [...courses];

    // Filtre recherche
    if (search) {
      result = result.filter(
        (c) =>
          c.title?.toLowerCase().includes(search.toLowerCase()) ||
          c.description?.toLowerCase().includes(search.toLowerCase())
      );
    }

    // Filtre catégorie
    if (category) result = result.filter((c) => c.category === category);

    //  Filtre prix
    if (priceRange === "free") result = result.filter((c) => c.isFree);
    else if (priceRange === "paid") result = result.filter((c) => !c.isFree);

    // Tri
    if (sortBy === "price-asc") result.sort((a, b) => a.price - b.price);
    else if (sortBy === "price-desc") result.sort((a, b) => b.price - a.price);
    else if (sortBy === "rating")
      result.sort((a, b) => b.averageRating - a.averageRating);

    setFilteredCourses(result);
  }, [search, category, priceRange, sortBy, courses]);

  return {
    filteredCourses,
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
  };
};
