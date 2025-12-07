// src/models/QuizModel.js
import { doc, getDoc, setDoc, updateDoc, Timestamp } from "firebase/firestore";
import { db } from "../firebase";

class QuizModel {
  /**
   * Récupère le quiz d'un chapitre spécifique
   */
  async getQuizForChapter(courseId, chapterId) {
    try {
      const courseRef = doc(db, "courses", courseId);
      const courseSnap = await getDoc(courseRef);

      if (!courseSnap.exists()) {
        throw new Error("Cours introuvable");
      }

      const courseData = courseSnap.data();
      const chapter = courseData.chapters?.find((ch) => ch.id === chapterId);

      if (!chapter) {
        throw new Error("Chapitre introuvable");
      }

      return chapter.quiz || null;
    } catch (error) {
      console.error("Erreur getQuizForChapter:", error);
      throw error;
    }
  }

  /**
   * Enregistre le résultat d'un quiz pour un utilisateur
   */
  async saveQuizResult(
    userId,
    courseId,
    chapterId,
    score,
    totalQuestions,
    passed
  ) {
    try {
      const progressRef = doc(db, "users", userId, "myCourses", courseId);
      const progressSnap = await getDoc(progressRef);

      let progressData = progressSnap.exists() ? progressSnap.data() : {};

      // Initialiser chaptersCompleted si inexistant
      if (!progressData.chaptersCompleted) {
        progressData.chaptersCompleted = {};
      }

      // Mettre à jour les données du chapitre
      progressData.chaptersCompleted[chapterId] = {
        completedAt: Timestamp.now(),
        quizScore: score,
        quizTotalQuestions: totalQuestions,
        quizPercentage: Math.round((score / totalQuestions) * 100),
        passed: passed,
        lastAttempt: Timestamp.now(),
      };

      // Sauvegarder dans Firestore
      await setDoc(progressRef, progressData, { merge: true });

      return progressData.chaptersCompleted[chapterId];
    } catch (error) {
      console.error("Erreur saveQuizResult:", error);
      throw error;
    }
  }

  /**
   * Récupère la progression d'un utilisateur pour un cours
   */
  async getUserProgress(userId, courseId) {
    try {
      const progressRef = doc(db, "users", userId, "myCourses", courseId);
      const progressSnap = await getDoc(progressRef);

      if (!progressSnap.exists()) {
        return { chaptersCompleted: {} };
      }

      return progressSnap.data();
    } catch (error) {
      console.error("Erreur getUserProgress:", error);
      throw error;
    }
  }

  /**
   * Vérifie si un chapitre a été complété
   */
  async isChapterCompleted(userId, courseId, chapterId) {
    try {
      const progress = await this.getUserProgress(userId, courseId);
      return progress.chaptersCompleted?.[chapterId]?.passed || false;
    } catch (error) {
      console.error("Erreur isChapterCompleted:", error);
      return false;
    }
  }
}

export default new QuizModel();
