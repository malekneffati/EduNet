// EduNet/backend/index.js
import { db } from "./firebaseAdmin.js";
import { sendConfirmationEmail } from "./emailService.js";
import express from "express";
import fetch from "node-fetch";
import cors from "cors";

const BASE_URL = "https://sandbox.paymee.tn/api/v2";

const app = express();
app.use(cors());
app.use(express.urlencoded({ extended: true }));
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

app.post("/paymee/webhook", async (req, res) => {
  try {
    const payload = req.body;

    console.log("📩 Webhook Paymee reçu :", payload);

    if (!payload || typeof payload.payment_status === "undefined") {
      console.log("❌ Webhook invalide (payload vide)");
      return res.status(200).send("OK");
    }

    const paymentSuccess =
      payload.payment_status === true ||
      payload.payment_status === "True" ||
      payload.payment_status === "true" ||
      payload.payment_status === 1 ||
      payload.payment_status === "1";

    if (!paymentSuccess) {
      console.log("❌ Paiement non réussi :", payload.payment_status);
      return res.status(200).send("OK");
    }

    const orderId = payload.order_id;
    if (!orderId || !orderId.includes("_")) {
      console.error("❌ order_id invalide :", orderId);
      return res.status(200).send("OK");
    }

    const [userId, courseId] = orderId.split("_");

    const email = payload.email;
    const courseTitle = payload.note || "Cours EduNet";

    if (!email) {
      console.error("❌ Email manquant dans le webhook");
      return res.status(200).send("OK");
    }

    const courseRef = db.doc(`users/${userId}/myCourses/${courseId}`);
    await courseRef.set({
      joinedAt: new Date(),
      progress: 0,
      paymentStatus: "paid",
      transactionId: payload.transaction_id || null,
      amount: payload.amount || null,
    });

    console.log(`✅ Accès créé : user=${userId}, course=${courseId}`);

    const paiementRef = db.collection("paiements").doc();

    await paiementRef.set({
      userId: userId,
      userName:
        `${payload.first_name || ""} ${payload.last_name || ""}`.trim() ||
        "Utilisateur",
      courseId: courseId,
      courseTitle: courseTitle,
      montant: Number(payload.amount) || 0,
      transactionId: payload.transaction_id || null,
      date: new Date(),
    });

    await sendConfirmationEmail(email, courseTitle);
    console.log(`📧 Email envoyé à ${email}`);

    return res.status(200).send("OK");
  } catch (err) {
    console.error("🔥 Erreur webhook Paymee :", err);
    return res.status(500).send("Erreur serveur");
  }
});

const PORT = process.env.PORT || 10000;
app.listen(PORT, () => console.log("Server running on port " + PORT));
