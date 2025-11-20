// src/components/catalog/Filters.js
const Filters = ({
  search,
  setSearch,
  category,
  setCategory,
  priceRange,
  setPriceRange,
  sortBy,
  setSortBy,
  categories,
}) => (
  <div className="bg-white card-shadow rounded-lg p-6 mb-12">
    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
      <div>
        <label className="block mb-2">Recherche</label>
        <input
          type="text"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Rechercher un cours..."
          className="w-full px-3 py-2 border rounded-lg"
        />
      </div>
      <div>
        <label className="block mb-2">Catégorie</label>
        <select
          value={category}
          onChange={(e) => setCategory(e.target.value)}
          className="w-full px-3 py-2 border rounded-lg"
        >
          <option value="">Toutes</option>
          {categories.map((cat) => (
            <option key={cat} value={cat}>
              {cat}
            </option>
          ))}
        </select>
      </div>
      <div>
        <label className="block mb-2">Prix</label>
        <select
          value={priceRange}
          onChange={(e) => setPriceRange(e.target.value)}
          className="w-full px-3 py-2 border rounded-lg"
        >
          <option value="">Tous</option>
          <option value="free">Gratuit</option>
          <option value="paid">Payant</option>
        </select>
      </div>
    </div>
    <div className="mt-4">
      <label className="block mb-2">Trier par</label>
      <select
        value={sortBy}
        onChange={(e) => setSortBy(e.target.value)}
        className="w-full md:w-1/4 px-3 py-2 border rounded-lg"
      >
        <option value="">Par défaut</option>
        <option value="price-asc">Prix : Croissant</option>
        <option value="price-desc">Prix : Décroissant</option>
        <option value="rating">Note</option>
      </select>
    </div>
  </div>
);

export default Filters;
