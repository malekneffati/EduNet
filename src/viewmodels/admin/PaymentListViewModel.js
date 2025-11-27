// src/viewmodels/payments/PaymentListViewModel.js
import { db } from "../../firebase";
import { collection, getDocs, query, orderBy } from "firebase/firestore";

class PaymentListViewModel {
  payments = [];
  loading = false;
  error = null;

  async fetchPayments() {
    this.loading = true;
    this.error = null;

    try {
      const q = query(collection(db, "payments"), orderBy("date", "desc"));
      const snapshot = await getDocs(q);
      this.payments = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));
    } catch (err) {
      console.error("Erreur fetchPayments:", err);
      this.error = err.message;
    } finally {
      this.loading = false;
    }
  }
}

export default new PaymentListViewModel();
