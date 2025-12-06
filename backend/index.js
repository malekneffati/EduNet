// EduNet/backend/index.js

import express from "express";
import fetch from "node-fetch";
import cors from "cors";
import "dotenv/config";

// Firebase Admin
import admin from "firebase-admin";
import serviceAccount from "./serviceAccountKey.json" assert { type: "json" };

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

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
    userId,
    courseId,
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

        // 🔥 Callback backend
        callback_url: "https://edunet-1bqg.onrender.com/paymeeCallback",

        // 🔥 On envoie user + cours dans metadata
        metadata: {
          userId,
          courseId,
        },
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
    console.error("Erreur backend createPayment:", err);
    res.status(500).json({ message: "Erreur serveur" });
  }
});

app.post("/paymeeCallback", async (req, res) => {
  console.log("🔥 Callback Paymee reçu :", req.body);

  try {
    const { status, payment_token, transaction_id, metadata } = req.body;

    // Vérifier paiement confirmé par Paymee
    if (status !== "completed") {
      console.log("❌ Paiement NON confirmé");
      return res.status(400).send("Payment not completed");
    }

    const { userId, courseId } = metadata || {};

    if (!userId || !courseId) {
      console.error("❌ Metadata manquants !");
      return res.status(400).send("Missing metadata");
    }

    // 🔥 Ajouter le cours à Firestore
    await db
      .collection("users")
      .doc(userId)
      .collection("myCourses")
      .doc(courseId)
      .set({
        joinedAt: admin.firestore.Timestamp.now(),
        progress: 0,
        transactionId: transaction_id,
        token: payment_token,
      });

    console.log("✅ Cours ajouté dans Firestore après paiement confirmé !");
    res.status(200).send("OK");
  } catch (err) {
    console.error("Erreur callback Paymee :", err);
    res.status(500).send("Callback error");
  }
});

const PORT = process.env.PORT || 10000;
app.listen(PORT, () => console.log("🚀 Server running on port " + PORT));
