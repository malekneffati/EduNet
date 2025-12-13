// src/viewmodels/PaymentViewModel.js
import PaymentModel from "../../models/PaymentModel";
import { db } from "../../firebase";
import { doc, getDoc } from "firebase/firestore";

class PaymentViewModel {
  loading = false;
  error = null;

  async startPayment(course, userId) {
    this.loading = true;
    this.error = null;

    try {
      const userSnap = await getDoc(doc(db, "users", userId));
      if (!userSnap.exists()) throw new Error("Utilisateur introuvable");

      const user = userSnap.data();

      const firstName =
        user.firstName || (user.name ? user.name.split(" ")[0] : "User");
      const lastName =
        user.lastName ||
        (user.name ? user.name.split(" ").slice(1).join(" ") : "Unknown");

      const returnUrl = `https://edunet-1574d.web.app/course/${course.id}/content`;
      const cancelUrl = "https://edunet-1574d.web.app/course/payment-cancel";

      const orderId = `${userId}_${course.id}`;

      const paymentData = await PaymentModel.createPayment({
        amount: course.price,
        note: `Achat du cours : ${course.title}`,
        returnUrl,
        cancelUrl,
        firstName,
        lastName,
        email: user.email,
        phone: user.phone || "+21600000000",
        orderId,
      });

      this.loading = false;
      return paymentData;
    } catch (err) {
      console.error("Erreur démarrage paiement :", err);
      this.loading = false;
      this.error = err.message;
      return null;
    }
  }
}

export default new PaymentViewModel();
