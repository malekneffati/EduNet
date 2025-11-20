import React from "react";
import UploadVideo from "./UploadVideo";
import UploadPDF from "./UploadPDF";
import useCourseFormViewModel from "../../viewmodels/admin/CourseFormViewModel";

const CourseForm = ({ initialData, onSave, onCancel }) => {
  const vm = useCourseFormViewModel(initialData, onSave, onCancel);

  return (
    <div className="fixed inset-0 flex items-center justify-center z-50 p-4">
      <div className="absolute inset-0 bg-black/50" onClick={vm.onCancel} />

      <form
        onSubmit={vm.handleSubmit}
        className="relative z-10 bg-white p-6 rounded-2xl shadow-2xl w-full max-w-3xl max-h-[90vh] overflow-y-auto space-y-5"
      >
        <h2 className="text-2xl font-bold text-gray-800 mb-4">
          {initialData ? "Modifier le cours" : "Ajouter un cours"}
        </h2>

        {/* Titre */}
        <div>
          <label className="block font-medium text-sm text-gray-700 mb-2">
            Titre du cours <span className="text-red-500">*</span>
          </label>
          <input
            required
            className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500 focus:outline-none"
            value={vm.title}
            onChange={(e) => vm.setTitle(e.target.value)}
            placeholder="Ex: Développement Web Complet"
          />
        </div>

        {/* Description */}
        <div>
          <label className="block font-medium text-sm text-gray-700 mb-2">
            Description
          </label>
          <textarea
            rows="4"
            className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500 focus:outline-none"
            value={vm.description}
            onChange={(e) => vm.setDescription(e.target.value)}
            placeholder="Décrivez le contenu du cours..."
          />
        </div>

        {/* Catégorie et Instructeur */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block font-medium text-sm text-gray-700 mb-2">
              Catégorie
            </label>
            <select
              className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500 focus:outline-none"
              value={vm.category}
              onChange={(e) => vm.setCategory(e.target.value)}
            >
              {vm.categories.map((cat) => (
                <option key={cat} value={cat}>
                  {cat}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block font-medium text-sm text-gray-700 mb-2">
              Instructeur
            </label>
            <input
              className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500 focus:outline-none"
              value={vm.instructor}
              onChange={(e) => vm.setInstructor(e.target.value)}
              placeholder="Ex: Jean Dupont"
            />
          </div>
        </div>

        {/* Durée */}
        <div>
          <label className="block font-medium text-sm text-gray-700 mb-2">
            Durée
          </label>
          <input
            className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500 focus:outline-none"
            value={vm.duration}
            onChange={(e) => vm.setDuration(e.target.value)}
            placeholder="Ex: 12 heures"
          />
        </div>

        {/* Prix / Gratuit */}
        <div className="bg-gray-50 p-4 rounded-lg">
          <label className="flex items-center gap-3 cursor-pointer">
            <input
              type="checkbox"
              checked={vm.isFree}
              onChange={(e) => vm.setIsFree(e.target.checked)}
              className="w-5 h-5 text-blue-600"
            />
            <span className="font-medium text-gray-700">Cours gratuit</span>
          </label>

          {!vm.isFree && (
            <div className="mt-3">
              <label className="block text-sm text-gray-600 mb-1">
                Prix (TND)
              </label>
              <input
                type="number"
                min="0"
                step="0.01"
                value={vm.price}
                onChange={(e) => vm.setPrice(e.target.value)}
                className="w-full md:w-48 border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500 focus:outline-none"
                placeholder="Ex: 89"
              />
            </div>
          )}
        </div>

        {/* Upload Vidéo */}
        <div className="bg-blue-50 p-4 rounded-lg">
          <label className="block font-medium text-gray-700 mb-3">
            🎬 Vidéo du cours
          </label>
          <UploadVideo
            onUploadComplete={(url) => vm.setVideoUrl(url)}
            existingUrl={vm.videoUrl}
          />
        </div>

        {/* Upload PDF */}
        <div className="bg-green-50 p-4 rounded-lg">
          <label className="block font-medium text-gray-700 mb-3">
            📄 Document PDF
          </label>
          <UploadPDF
            onUploadComplete={(url) => vm.setPdfUrl(url)}
            existingUrl={vm.pdfUrl}
          />
        </div>

        {/* Actions */}
        <div className="flex justify-end gap-3 pt-4 border-t">
          <button
            type="button"
            onClick={vm.onCancel}
            className="px-6 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
          >
            Annuler
          </button>

          <button
            type="submit"
            className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors shadow-md"
          >
            {initialData ? "Mettre à jour" : "Créer le cours"}
          </button>
        </div>
      </form>
    </div>
  );
};

export default CourseForm;
