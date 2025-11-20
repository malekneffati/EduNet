import { useState, useEffect } from "react";

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

  const categories = [
    "Développement",
    "Design",
    "Marketing",
    "Business",
    "Autre",
  ];

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
  };
};

export default useCourseFormViewModel;
