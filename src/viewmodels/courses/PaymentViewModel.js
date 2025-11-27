// src/viewmodels/PaymentViewModel.js
import PaymentModel from "../models/PaymentModel";
import { db } from "../firebase";
import { doc, getDoc } from "firebase/firestore";

class PaymentViewModel {
  loading = false;
  error = null;

  /**
   * Démarre le paiement pour un cours et retourne l'URL de redirection
   * @param {object} course {id, title, price}
   * @param {string} userId
   * @returns {Promise<{token, payment_url}>}
   */
  async startPayment(course, userId) {
    this.loading = true;
    this.error = null;

    try {
      // Récupérer les infos utilisateur depuis Firestore
      const userSnap = await getDoc(doc(db, "users", userId));
      if (!userSnap.exists()) throw new Error("Utilisateur introuvable");

      const user = userSnap.data();

      let firstName = user.firstName;
      let lastName = user.lastName;
      if (!firstName || !lastName) {
        const parts = (user.name || "User Unknown").split(" ");
        firstName = parts[0];
        lastName = parts.slice(1).join(" ");
      }

      const returnUrl = `https://edunet-1574d.web.app/course/payment-success?courseId=${course.id}&userId=${userId}`;
      const cancelUrl = "https://edunet-1574d.web.app/course/payment-cancel";

      // Appeler le backend Render
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
          name: user.name,
        }
      );

      this.loading = false;
      return paymentData; // { token, payment_url }
    } catch (err) {
      console.error("Erreur démarrage paiement :", err);
      this.loading = false;
      this.error = err.message;
      return null;
    }
  }
}

export default new PaymentViewModel();
