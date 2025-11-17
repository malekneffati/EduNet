// paymee-backend/index.js
const admin = require("firebase-admin");
const express = require("express");
const cors = require("cors");
const axios = require("axios");
require("dotenv").config();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 5000;
const PAYMEE_KEY = process.env.PAYMEE_KEY; // Ta clé sandbox

// ------------------- ROUTE ADMIN -------------------
app.post("/set-admin-role", async (req, res) => {
  try {
    const { uid, requesterEmail } = req.body;

    // Vérifie que la personne qui fait la requête est admin
    if (requesterEmail !== "admin@example.com") {
      return res.status(403).json({ error: "Accès interdit." });
    }

    await admin.auth().setCustomUserClaims(uid, { role: "admin" });
    res.json({ message: `Rôle admin attribué à ${uid}` });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Erreur lors de l’attribution du rôle." });
  }
});

// ------------------- ROUTE PAYMEE -------------------
app.post("/createPaymeePayment", async (req, res) => {
  try {
    const { amount, note, first_name, last_name, email, phone, courseId } =
      req.body;

    const payload = {
      amount,
      note,
      first_name,
      last_name,
      email,
      phone,
      return_url: `https://ton-frontend.netlify.app/payment-success?courseId=${courseId}`,
      cancel_url: `https://ton-frontend.netlify.app/payment-cancel`,
      webhook_url: `https://ton-backend.onrender.com/paymeeWebhook`,
      order_id: courseId,
    };

    const response = await axios.post(
      "https://sandbox.paymee.tn/api/v2/payments/create",
      payload,
      {
        headers: {
          "Content-Type": "application/json",
          Authorization: `Token ${PAYMEE_KEY}`,
        },
      }
    );

    return res.send(response.data);
  } catch (err) {
    console.error(err);
    return res.status(500).send({ error: "Payment creation failed" });
  }
});

// ------------------- WEBHOOK PAYMEE -------------------
app.post("/paymeeWebhook", (req, res) => {
  const { token, check_sum, payment_status, order_id } = req.body;
  console.log("Webhook reçu:", req.body);

  // Ici tu peux stocker le paiement réussi dans Firestore si besoin
  res.send("OK");
});

// ------------------- DEMARRAGE DU SERVEUR -------------------
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
