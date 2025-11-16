// src/components/admin/CourseForm.js
import React, { useState, useEffect } from "react";
import UploadThingVideo from "./UploadThingVideo";
import UploadThingPDF from "./UploadThingPDF";

const CourseForm = ({ initialData = null, onCancel, onSave }) => {
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [price, setPrice] = useState(0);
  const [isFree, setIsFree] = useState(false);
  const [videoUrl, setVideoUrl] = useState("");
  const [pdfUrl, setPdfUrl] = useState("");
  const [category, setCategory] = useState("Développement");
  const [instructor, setInstructor] = useState("");
  const [duration, setDuration] = useState("");

  useEffect(() => {
    if (initialData) {
      setTitle(initialData.title || "");
      setDescription(initialData.description || "");
      setPrice(initialData.price || 0);
      setIsFree(initialData.isFree || false);
      setVideoUrl(initialData.videoUrl || "");
      setPdfUrl(initialData.pdfUrl || "");
      setCategory(initialData.category || "Développement");
      setInstructor(initialData.instructor || "");
      setDuration(initialData.duration || "");
    }
  }, [initialData]);

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!title.trim()) return alert("Le titre est obligatoire.");
    if (!isFree && price <= 0)
      return alert("Le prix doit être supérieur à 0 pour un cours payant.");

    const payload = {
      title: title.trim(),
      description: description.trim(),
      price: isFree ? 0 : Number(price),
      isFree,
      videoUrl,
      pdfUrl,
      category,
      instructor: instructor.trim(),
      duration: duration.trim(),
      status: "active",
    };

    try {
      await onSave(payload);
      alert("Cours enregistré avec succès !");
    } catch (err) {
      console.error(err);
      alert("Erreur lors de l'enregistrement");
    }
  };

  const categories = [
    "Développement",
    "Design",
    "Marketing",
    "Business",
    "Autre",
  ];

  return (
    <div className="fixed inset-0 flex items-center justify-center z-50 p-4">
      <div className="absolute inset-0 bg-black/50" onClick={onCancel} />

      <form
        onSubmit={handleSubmit}
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
            value={title}
            onChange={(e) => setTitle(e.target.value)}
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
            value={description}
            onChange={(e) => setDescription(e.target.value)}
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
              value={category}
              onChange={(e) => setCategory(e.target.value)}
            >
              {categories.map((cat) => (
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
              value={instructor}
              onChange={(e) => setInstructor(e.target.value)}
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
            value={duration}
            onChange={(e) => setDuration(e.target.value)}
            placeholder="Ex: 12 heures"
          />
        </div>

        {/* Prix / Gratuit */}
        <div className="bg-gray-50 p-4 rounded-lg">
          <label className="flex items-center gap-3 cursor-pointer">
            <input
              type="checkbox"
              checked={isFree}
              onChange={(e) => setIsFree(e.target.checked)}
              className="w-5 h-5 text-blue-600"
            />
            <span className="font-medium text-gray-700">Cours gratuit</span>
          </label>

          {!isFree && (
            <div className="mt-3">
              <label className="block text-sm text-gray-600 mb-1">
                Prix (TND)
              </label>
              <input
                type="number"
                min="0"
                step="0.01"
                value={price}
                onChange={(e) => setPrice(e.target.value)}
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
          <UploadThingVideo
            onUploadComplete={(url) => setVideoUrl(url)}
            existingUrl={videoUrl}
          />
        </div>

        {/* Upload PDF */}
        <div className="bg-green-50 p-4 rounded-lg">
          <label className="block font-medium text-gray-700 mb-3">
            📄 Document PDF
          </label>
          <UploadThingPDF
            onUploadComplete={(url) => setPdfUrl(url)}
            existingUrl={pdfUrl}
          />
        </div>

        {/* Actions */}
        <div className="flex justify-end gap-3 pt-4 border-t">
          <button
            type="button"
            onClick={onCancel}
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
