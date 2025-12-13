// EduNet/backend/index.js
import { db } from "./firebaseAdmin.js"; // Firebase Admin
import { sendConfirmationEmail } from "./emailService.js";
import express from "express";
import fetch from "node-fetch";
import cors from "cors";


const BASE_URL = "https://sandbox.paymee.tn/api/v2";

const app = express();
app.use(cors());
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

    console.log("Webhook reçu :", payload);

    // 1️⃣ Vérifier que payload existe et contient l’ID
    if (!payload || !payload.id) {
      console.log("Webhook invalide :", payload);
      return res.status(200).send("OK");
    }

    // 2️⃣ Vérification via API Paymee
    const verifyResponse = await fetch(`${BASE_URL}/payments/${payload.id}`, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Token ${process.env.PAYMEE_API_KEY}`,
      },
    });

    const verifyData = await verifyResponse.json();

    if (!verifyResponse.ok || verifyData.status !== "SUCCESS") {
      console.log("Paiement non confirmé par Paymee :", verifyData);
      return res.status(200).send("OK");
    }

    // 3️⃣ Extraire metadata
    const { userId, courseId, courseTitle, email } = payload.metadata || {};
    if (!userId || !courseId || !courseTitle || !email) {
      console.error("Metadata manquante :", payload.metadata);
      return res.status(200).send("OK");
    }

    // 4️⃣ Créer myCourses dans Firestore
    const courseRef = db.doc(`users/${userId}/myCourses/${courseId}`);
    await courseRef.set({
      joinedAt: new Date(),
      progress: 0,
      paymentStatus: "paid",
    });

    console.log(`Accès créé pour user ${userId}, course ${courseId}`);

    // 5️⃣ Envoi email
    await sendConfirmationEmail(email, courseTitle);
    console.log(`Email de confirmation envoyé à ${payload.email}`);

    // 6️⃣ Toujours répondre 200 OK
    res.status(200).send("OK");
  } catch (err) {
    console.error("Erreur webhook :", err);
    res.status(500).send("Erreur serveur");
  }
});


const PORT = process.env.PORT || 10000;
app.listen(PORT, () => console.log("Server running on port " + PORT));






