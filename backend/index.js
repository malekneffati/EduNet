// EduNet/backend/index.js
import { db } from "./firebaseAdmin.js"; // Firebase Admin
import { sendConfirmationEmail } from "./emailService.js";
import express from "express";
import fetch from "node-fetch";
import cors from "cors";

const BASE_URL = "https://sandbox.paymee.tn/api/v2";

const app = express();
app.use(cors());
// 🔑 OBLIGATOIRE pour Paymee webhook
app.use(express.urlencoded({ extended: true }));

// Pour les autres routes JSON
app.use(express.json());

app.post("/createPayment", async (req, res) => {
  const {
    amount,
    note,
    firstName,
    lastName,
    email,
    phone,
    returnUrl,
    cancelUrl,
    orderId,
  } = req.body;

  try {
    const response = await fetch(`${BASE_URL}/payments/create`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Token ${process.env.PAYMEE_API_KEY}`,
      },
      body: JSON.stringify({
        amount,
        note,
        first_name: firstName,
        last_name: lastName,
        email,
        phone,
        return_url: returnUrl,
        cancel_url: cancelUrl,
        webhook_url: process.env.PAYMEE_WEBHOOK_URL,
        order_id: orderId || "EDUNET-ORDER",
      }),
    });

    const data = await response.json();

    if (!response.ok) {
      console.error("Erreur Paymee:", data);
      return res.status(400).json(data);
    }

    return res.json({
      token: data.data?.token,
      payment_url: data.data?.payment_url,
    });
  } catch (err) {
    console.error("Erreur backend :", err);
    res.status(500).json({ message: "Erreur serveur" });
  }
});

// Endpoint webhook Paymee
app.post("/paymee/webhook", async (req, res) => {
  try {
    const payload = req.body;

    console.log("📩 Webhook Paymee reçu :", payload);

    /**
     * 1️⃣ Vérifier que le payload existe
     * Paymee envoie toujours payment_status (true / false)
     */
    if (!payload || typeof payload.payment_status === "undefined") {
      console.log("❌ Webhook invalide (payload vide)");
      return res.status(200).send("OK");
    }

    /**
     * 2️⃣ Vérifier que le paiement est réussi
     */
    if (payload.payment_status !== true) {
      console.log("❌ Paiement non réussi :", payload.payment_status);
      return res.status(200).send("OK");
    }

    /**
     * 3️⃣ Extraire userId et courseId depuis order_id
     * Format attendu : userId_courseId
     */
    const orderId = payload.order_id;
    if (!orderId || !orderId.includes("_")) {
      console.error("❌ order_id invalide :", orderId);
      return res.status(200).send("OK");
    }

    const [userId, courseId] = orderId.split("_");

    /**
     * 4️⃣ Récupérer email et titre du cours
     * note = "Achat du cours : XXX"
     */
    const email = payload.email;
    const courseTitle = payload.note || "Cours EduNet";

    if (!email) {
      console.error("❌ Email manquant dans le webhook");
      return res.status(200).send("OK");
    }

    /**
     * 5️⃣ Écrire dans Firestore (myCourses)
     */
    const courseRef = db.doc(`users/${userId}/myCourses/${courseId}`);
    await courseRef.set({
      joinedAt: new Date(),
      progress: 0,
      paymentStatus: "paid",
      transactionId: payload.transaction_id || null,
      amount: payload.amount || null,
    });

    console.log(`✅ Accès créé : user=${userId}, course=${courseId}`);

    /**
     * 6️⃣ Envoyer l’email de confirmation
     */
    await sendConfirmationEmail(email, courseTitle);
    console.log(`📧 Email envoyé à ${email}`);

    /**
     * 7️⃣ Toujours répondre 200 à Paymee
     */
    return res.status(200).send("OK");
  } catch (err) {
    console.error("🔥 Erreur webhook Paymee :", err);
    return res.status(500).send("Erreur serveur");
  }
});

const PORT = process.env.PORT || 10000;
app.listen(PORT, () => console.log("Server running on port " + PORT));
