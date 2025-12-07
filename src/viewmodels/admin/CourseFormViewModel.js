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
        description: "",
        videoUrl: "",
        pdfUrl: "",
        quiz: null,
      },
    ]);
  };

  // Supprimer un chapitre
  const removeChapter = (id) => {
    setChapters(chapters.filter((c) => c.id !== id));
  };

  // Mettre à jour un champ d'un chapitre
  const updateChapter = (id, field, value) => {
    setChapters(
      chapters.map((c) => (c.id === id ? { ...c, [field]: value } : c))
    );
  };

  // Ajouter un quiz à un chapitre
  const addQuizToChapter = (chapterId) => {
    setChapters(
      chapters.map((c) =>
        c.id === chapterId
          ? {
              ...c,
              quiz: {
                questions: [
                  {
                    id: uuidv4(),
                    question: "",
                    options: ["", "", "", ""],
                    correctAnswer: 0,
                    explanation: "",
                  },
                ],
                passingScore: 60,
              },
            }
          : c
      )
    );
  };

  // Supprimer le quiz d'un chapitre
  const removeQuizFromChapter = (chapterId) => {
    setChapters(
      chapters.map((c) => (c.id === chapterId ? { ...c, quiz: null } : c))
    );
  };

  // Ajouter une question au quiz
  const addQuestionToQuiz = (chapterId) => {
    setChapters(
      chapters.map((c) => {
        if (c.id === chapterId && c.quiz) {
          return {
            ...c,
            quiz: {
              ...c.quiz,
              questions: [
                ...c.quiz.questions,
                {
                  id: uuidv4(),
                  question: "",
                  options: ["", "", "", ""],
                  correctAnswer: 0,
                  explanation: "",
                },
              ],
            },
          };
        }
        return c;
      })
    );
  };

  // Supprimer une question du quiz
  const removeQuestionFromQuiz = (chapterId, questionId) => {
    setChapters(
      chapters.map((c) => {
        if (c.id === chapterId && c.quiz) {
          return {
            ...c,
            quiz: {
              ...c.quiz,
              questions: c.quiz.questions.filter((q) => q.id !== questionId),
            },
          };
        }
        return c;
      })
    );
  };

  // Mettre à jour une question du quiz
  const updateQuizQuestion = (chapterId, questionId, field, value) => {
    setChapters(
      chapters.map((c) => {
        if (c.id === chapterId && c.quiz) {
          return {
            ...c,
            quiz: {
              ...c.quiz,
              questions: c.quiz.questions.map((q) =>
                q.id === questionId ? { ...q, [field]: value } : q
              ),
            },
          };
        }
        return c;
      })
    );
  };

  // Mettre à jour une option de question
  const updateQuizQuestionOption = (
    chapterId,
    questionId,
    optionIndex,
    value
  ) => {
    setChapters(
      chapters.map((c) => {
        if (c.id === chapterId && c.quiz) {
          return {
            ...c,
            quiz: {
              ...c.quiz,
              questions: c.quiz.questions.map((q) => {
                if (q.id === questionId) {
                  const newOptions = [...q.options];
                  newOptions[optionIndex] = value;
                  return { ...q, options: newOptions };
                }
                return q;
              }),
            },
          };
        }
        return c;
      })
    );
  };

  // Mettre à jour le score de passage
  const updateQuizPassingScore = (chapterId, score) => {
    setChapters(
      chapters.map((c) => {
        if (c.id === chapterId && c.quiz) {
          return {
            ...c,
            quiz: {
              ...c.quiz,
              passingScore: Number(score),
            },
          };
        }
        return c;
      })
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

    // Fonctions pour les quiz
    addQuizToChapter,
    removeQuizFromChapter,
    addQuestionToQuiz,
    removeQuestionFromQuiz,
    updateQuizQuestion,
    updateQuizQuestionOption,
    updateQuizPassingScore,
  };
};

export default useCourseFormViewModel;