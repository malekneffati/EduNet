import React, { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { collection, getDocs } from "firebase/firestore";
import { db } from "../firebase";

const Catalog = () => {
  const [courses, setCourses] = useState([]);
  const [filteredCourses, setFilteredCourses] = useState([]);
  const [search, setSearch] = useState("");
  const [category, setCategory] = useState("");
  const [priceRange, setPriceRange] = useState("");
  const [sortBy, setSortBy] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchCourses = async () => {
      try {
        const querySnapshot = await getDocs(collection(db, "courses"));

        // Charger les cours
        const coursesData = await Promise.all(
          querySnapshot.docs.map(async (docSnap) => {
            const course = { id: docSnap.id, ...docSnap.data() };

            // Charger les avis (reviews)
            const reviewsSnapshot = await getDocs(
              collection(db, "courses", course.id, "reviews")
            );

            const reviews = reviewsSnapshot.docs.map((r) => r.data());

            // Calcul moyenne
            const average =
              reviews.length > 0
                ? (
                    reviews.reduce((sum, r) => sum + r.rating, 0) /
                    reviews.length
                  ).toFixed(1)
                : 0;

            return { ...course, averageRating: average };
          })
        );

        setCourses(coursesData);
        setFilteredCourses(coursesData);
      } catch (err) {
        console.error("Error fetching courses:", err);
        setError("Impossible de charger les cours.");
      } finally {
        setLoading(false);
      }
    };

    fetchCourses();
  }, []);

  useEffect(() => {
    let result = [...courses];

    // Search filter
    if (search) {
      result = result.filter(
        (course) =>
          course.title.toLowerCase().includes(search.toLowerCase()) ||
          course.description.toLowerCase().includes(search.toLowerCase())
      );
    }

    // Category filter
    if (category) {
      result = result.filter((course) => course.category === category);
    }

    // Price range filter
    if (priceRange) {
      if (priceRange === "free") {
        result = result.filter((course) => course.price === 0);
      } else if (priceRange === "paid") {
        result = result.filter((course) => course.price > 0);
      }
    }

    // Sorting
    if (sortBy === "price-asc") {
      result.sort((a, b) => a.price - b.price);
    } else if (sortBy === "price-desc") {
      result.sort((a, b) => b.price - a.price);
    } else if (sortBy === "rating") {
      result.sort((a, b) => b.averageRating - a.averageRating);
    }

    setFilteredCourses(result);
  }, [search, category, priceRange, sortBy, courses]);

  const categories = [
    "All",
    "Développement",
    "Design",
    "Marketing",
    "Business",
  ];

  return (
    <div id="catalog-page" className="page-content py-12 px-4 bg-gray-50">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="text-center mb-12">
          <h1 className="text-3xl md:text-4xl font-bold font-poppins text-gray-900 mb-4">
            Catalogue des cours
          </h1>
          <p className="text-gray-600 max-w-2xl mx-auto">
            Explorez notre large sélection de cours pour tous les niveaux et
            intérêts
          </p>
        </div>

        {/* Filters */}
        <div className="bg-white card-shadow rounded-lg p-6 mb-12">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Recherche
              </label>
              <input
                type="text"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Rechercher un cours..."
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Catégorie
              </label>
              <select
                value={category}
                onChange={(e) => setCategory(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                {categories.map((cat) => (
                  <option key={cat} value={cat === "All" ? "" : cat}>
                    {cat}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Prix
              </label>
              <select
                value={priceRange}
                onChange={(e) => setPriceRange(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Tous</option>
                <option value="free">Gratuit</option>
                <option value="paid">Payant</option>
              </select>
            </div>
          </div>
          <div className="mt-4">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Trier par
            </label>
            <select
              value={sortBy}
              onChange={(e) => setSortBy(e.target.value)}
              className="w-full md:w-1/4 px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">Par défaut</option>
              <option value="price-asc">Prix : Croissant</option>
              <option value="price-desc">Prix : Décroissant</option>
              <option value="rating">Note</option>
            </select>
          </div>
        </div>

        {/* Course Grid */}
        {loading ? (
          <div className="text-center">Chargement des cours...</div>
        ) : error ? (
          <div className="text-center text-red-500">{error}</div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {filteredCourses.length === 0 ? (
              <div className="col-span-3 text-center text-gray-600">
                Aucun cours trouvé
              </div>
            ) : (
              filteredCourses.map((course) => (
                <Link
                  key={course.id}
                  to={`/course/${course.id}/Details`}
                  className="card-shadow rounded-2xl overflow-hidden hover:scale-105 transition-transform duration-300"
                >
                  <div className="bg-gradient-to-r from-blue-500 to-purple-600 h-48 flex items-center justify-center">
                    <i className="fas fa-code text-white text-4xl"></i>
                  </div>
                  <div className="p-6">
                    <h3 className="font-semibold text-lg mb-2">
                      {course.title}
                    </h3>
                    <p className="text-gray-600 mb-4 line-clamp-2">
                      {course.description}
                    </p>
                    <div className="flex justify-between items-center">
                      <span className="text-blue-600 font-bold">
                        {course.price === 0 ? "Gratuit" : `${course.price} TND`}
                      </span>
                      <span className="text-yellow-500">
                        <i className="fas fa-star"></i> {course.averageRating}
                      </span>
                    </div>
                  </div>
                </Link>
              ))
            )}
          </div>
        )}
      </div>
    </div>
  );
};

export default Catalog;
