// src/models/PaymentModel.js
class PaymentModel {
  constructor() {
    // URL de ton backend Render
    this.FUNCTION_URL = "https://edunett.onrender.com/createPayment";
  }

  /**
   * Crée un paiement via Render -> Paymee
   * @param {number} amount
   * @param {string} note
   * @param {string} returnUrl
   * @param {string} cancelUrl
   * @param {object} user {firstName, lastName, email, phone, name}
   * @returns {Promise<{token, payment_url}>}
   */
  async createPayment(amount, note, returnUrl, cancelUrl, user) {
    if (!amount || isNaN(amount)) throw new Error("Montant invalide");

    let firstName = user.firstName;
    let lastName = user.lastName;
    if (!firstName || !lastName) {
      const parts = (user.name || "User Unknown").split(" ");
      firstName = parts[0] || "User";
      lastName = parts.slice(1).join(" ") || "Unknown";
    }

    const body = {
      amount: Number(amount),
      note,
      firstName,
      lastName,
      email: user.email || "user@example.com",
      phone: user.phone || "+21600000000",
      returnUrl,
      cancelUrl,
    };

    console.log("Création paiement via Render backend:", body);

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

    if (!data.token || !data.payment_url) {
      throw new Error(
        "Réponse Paymee invalide : token ou payment_url manquant"
      );
    }

    return data; // { token, payment_url }
  }
}

export default new PaymentModel();
