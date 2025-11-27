// src/viewmodels/admin/CourseFormViewModel.js
import { useState, useEffect } from "react";
import { v4 as uuidv4 } from "uuid";

const useCourseFormViewModel = (initialData, onSave, onCancel) => {
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [price, setPrice] = useState(0);
  const [isFree, setIsFree] = useState(false);
  const [videoUrl, setVideoUrl] = useState("");
  const [pdfUrl, setPdfUrl] = useState("");
  const [category, setCategory] = useState("Développement");
  const [instructor, setInstructor] = useState("");
  const [duration, setDuration] = useState("");

  const [chapters, setChapters] = useState([]);

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
      setChapters(initialData.chapters || []);
    }
  }, [initialData]);

  // Ajouter un chapitre
  const addChapter = () => {
    setChapters([
      ...chapters,
      {
        id: uuidv4(),
        title: "",
        videoUrl: "",
        pdfUrl: "",
      },
    ]);
  };

  // Supprimer un chapitre
  const removeChapter = (id) => {
    setChapters(chapters.filter((c) => c.id !== id));
  };

  // Mettre à jour un champ d’un chapitre
  const updateChapter = (id, field, value) => {
    setChapters(
      chapters.map((c) => (c.id === id ? { ...c, [field]: value } : c))
    );
  };

  const categories = [
    "Développement",
    "Design",
    "Marketing",
    "Business",
    "Autre",
  ];

  const handleSubmit = async (e) => {
    e.preventDefault();

    const payload = {
      title,
      description,
      price: isFree ? 0 : Number(price),
      isFree,
      videoUrl,
      pdfUrl,
      category,
      instructor,
      duration,
      chapters,
      status: "active",
    };

    await onSave(payload);
  };

  return {
    title,
    setTitle,
    description,
    setDescription,
    price,
    setPrice,
    isFree,
    setIsFree,
    videoUrl,
    setVideoUrl,
    pdfUrl,
    setPdfUrl,
    category,
    setCategory,
    instructor,
    setInstructor,
    duration,
    setDuration,
    categories,
    handleSubmit,
    onCancel,

    chapters,
    addChapter,
    updateChapter,
    removeChapter,
  };
};

export default useCourseFormViewModel;
