// src/viewmodels/courses/QuizViewModel.js
import { useState, useEffect } from "react";
import { auth } from "../../firebase";
import QuizModel from "../../models/QuizModel";

export const useQuizViewModel = (courseId, chapterId) => {
  const [quiz, setQuiz] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  // État du quiz en cours
  const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0);
  const [selectedAnswers, setSelectedAnswers] = useState({});
  const [showResults, setShowResults] = useState(false);
  const [score, setScore] = useState(0);
  const [quizStarted, setQuizStarted] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  const user = auth.currentUser;

  // Charger le quiz
  useEffect(() => {
    const loadQuiz = async () => {
      try {
        setLoading(true);
        const quizData = await QuizModel.getQuizForChapter(courseId, chapterId);
        
        if (!quizData || !quizData.questions || quizData.questions.length === 0) {
          setError("Aucun quiz disponible pour ce chapitre");
          return;
        }

        setQuiz(quizData);
      } catch (err) {
        console.error("Erreur chargement quiz:", err);
        setError(err.message || "Erreur lors du chargement du quiz");
      } finally {
        setLoading(false);
      }
    };

    if (courseId && chapterId) {
      loadQuiz();
    }
  }, [courseId, chapterId]);

  // Démarrer le quiz
  const startQuiz = () => {
    setQuizStarted(true);
    setCurrentQuestionIndex(0);
    setSelectedAnswers({});
    setShowResults(false);
    setScore(0);
  };

  // Sélectionner une réponse
  const selectAnswer = (questionId, answerIndex) => {
    setSelectedAnswers({
      ...selectedAnswers,
      [questionId]: answerIndex,
    });
  };

  // Question suivante
  const nextQuestion = () => {
    if (currentQuestionIndex < quiz.questions.length - 1) {
      setCurrentQuestionIndex(currentQuestionIndex + 1);
    }
  };

  // Question précédente
  const previousQuestion = () => {
    if (currentQuestionIndex > 0) {
      setCurrentQuestionIndex(currentQuestionIndex - 1);
    }
  };

  // Soumettre le quiz
  const submitQuiz = async () => {
    if (!user) {
      alert("Vous devez être connecté pour soumettre le quiz");
      return;
    }

    // Vérifier que toutes les questions ont une réponse
    const unansweredQuestions = quiz.questions.filter(
      (q) => selectedAnswers[q.id] === undefined
    );

    if (unansweredQuestions.length > 0) {
      alert(`Veuillez répondre à toutes les questions (${unansweredQuestions.length} restante(s))`);
      return;
    }

    setSubmitting(true);

    try {
      // Calculer le score
      let correctAnswers = 0;
      quiz.questions.forEach((question) => {
        if (selectedAnswers[question.id] === question.correctAnswer) {
          correctAnswers++;
        }
      });

      setScore(correctAnswers);

      const totalQuestions = quiz.questions.length;
      const percentage = Math.round((correctAnswers / totalQuestions) * 100);
      const passed = percentage >= (quiz.passingScore || 60);

      // Sauvegarder dans Firebase
      await QuizModel.saveQuizResult(
        user.uid,
        courseId,
        chapterId,
        correctAnswers,
        totalQuestions,
        passed
      );

      setShowResults(true);
    } catch (err) {
      console.error("Erreur soumission quiz:", err);
      alert("Erreur lors de la soumission du quiz. Veuillez réessayer.");
    } finally {
      setSubmitting(false);
    }
  };

  // Recommencer le quiz
  const retryQuiz = () => {
    startQuiz();
  };

  const currentQuestion = quiz?.questions?.[currentQuestionIndex];
  const totalQuestions = quiz?.questions?.length || 0;
  const percentage = totalQuestions > 0 ? Math.round((score / totalQuestions) * 100) : 0;
  const passed = percentage >= (quiz?.passingScore || 60);

  return {
    quiz,
    loading,
    error,
    quizStarted,
    currentQuestion,
    currentQuestionIndex,
    totalQuestions,
    selectedAnswers,
    showResults,
    score,
    percentage,
    passed,
    submitting,
    startQuiz,
    selectAnswer,
    nextQuestion,
    previousQuestion,
    submitQuiz,
    retryQuiz,
  };
};