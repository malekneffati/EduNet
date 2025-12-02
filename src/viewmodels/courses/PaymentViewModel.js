// src/viewmodels/courses/PaymentViewModel.js
import PaymentModel from "../../models/PaymentModel";
import { db } from "../../firebase";
import { doc, getDoc, setDoc, Timestamp } from "firebase/firestore";

class PaymentViewModel {
  loading = false;
  error = null;

  /**
   * Démarre le paiement via Paymee et retourne {token, payment_url}
   */
  async startPayment(course, userId) {
    this.loading = true;
    this.error = null;

    try {
      // Charger infos utilisateur
      const userSnap = await getDoc(doc(db, "users", userId));
      if (!userSnap.exists()) throw new Error("Utilisateur introuvable");

      const user = userSnap.data();

      // Normalisation nom / prénom
      let firstName = user.firstName;
      let lastName = user.lastName;
      if (!firstName || !lastName) {
        const parts = (user.name || "Unknown User").split(" ");
        firstName = parts[0] || "User";
        lastName = parts.slice(1).join(" ") || "Unknown";
      }

      // URLs de redirection
      const returnUrl = `https://edunet-1574d.web.app/course/${course.id}/content`;
      const cancelUrl = "https://edunet-1574d.web.app/course/payment-cancel";

      // Appel backend
      const paymentData = await PaymentModel.createPayment(
        course.price,
        `Achat du cours : ${course.title}`,
        returnUrl,
        cancelUrl,
        {
          firstName,
          lastName,
          email: user.email,
          phone: user.phone,
        }
      );

      this.loading = false;
      return paymentData;
    } catch (err) {
      console.error("Erreur démarrage paiement:", err);
      this.error = err.message;
      this.loading = false;
      return null;
    }
  }

  /**
   * Ajoute un cours à l'utilisateur dans Firestore après paiement
   */
  async addCourseToStudent(userId, courseId) {
    try {
      if (!userId || !courseId) throw new Error("Paramètres manquants");

      const courseRef = doc(db, "users", userId, "myCourses", courseId);

      // Vérifier si le cours existe déjà
      const courseSnap = await getDoc(courseRef);
      if (courseSnap.exists()) {
        console.warn("Cours déjà ajouté à l'utilisateur");
        return;
      }

      await setDoc(courseRef, {
        joinedAt: Timestamp.now(),
        progress: 0,
      });

      console.log(`Cours ${courseId} ajouté à l'utilisateur ${userId}`);
    } catch (err) {
      console.error("Erreur ajout cours à l'utilisateur:", err);
      throw err;
    }
  }
}

export default new PaymentViewModel();
