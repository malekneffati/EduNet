// src/models/PaymentModel.js
class PaymentModel {
  constructor() {
    // URL du backend Render
    this.FUNCTION_URL = "https://edunet-1bqg.onrender.com/createPayment";
  }

  async createPayment(amount, note, returnUrl, cancelUrl, user) {
    if (!amount || isNaN(amount)) throw new Error("Montant invalide");

    // Paymee veut amount en millimes → 10 TND = 10000
    const finalAmount = Number(amount) * 1000;

    const body = {
      amount: finalAmount,
      note,
      firstName: user.firstName || "User",
      lastName: user.lastName || "Unknown",
      email: user.email || "user@example.com",
      phone: user.phone || "+21600000000",
      returnUrl: returnUrl,
      cancelUrl: cancelUrl,
    };

    console.log("Payload envoyé au backend Render:", body);

    const response = await fetch(this.FUNCTION_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });

    const data = await response.json();

    if (!response.ok) {
      console.error("Erreur Paymee:", data);
      throw new Error(data.message || "Erreur paiement");
    }

    if (!data.token || !data.payment_url) {
      console.error("Réponse backend incorrecte:", data);
      throw new Error("Réponse Paymee invalide : token/payment_url manquant");
    }

    return data; // { token, payment_url }
  }
}

export default new PaymentModel();
