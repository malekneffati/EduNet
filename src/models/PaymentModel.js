// src/models/PaymentModel.js
class PaymentModel {
  constructor() {
    this.FUNCTION_URL = "https://edunet-1bqg.onrender.com/createPayment";
  }

  async createPayment({
    amount,
    note,
    returnUrl,
    cancelUrl,
    firstName,
    lastName,
    email,
    phone,
    orderId,
  }) {
    if (!amount || isNaN(amount)) {
      throw new Error("Montant invalide");
    }

    const body = {
      amount: Number(amount),
      note,
      firstName,
      lastName,
      email,
      phone,
      returnUrl,
      cancelUrl,
      orderId,
    };

    console.log("Création paiement via Render backend :", body);

    const response = await fetch(this.FUNCTION_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });

    const data = await response.json();

    if (!response.ok) {
      console.error("Erreur paiement :", data);
      throw new Error(data.message || "Erreur paiement");
    }

    if (!data.payment_url) {
      throw new Error("Réponse Paymee invalide");
    }

    return data; 
  }
}

export default new PaymentModel();
