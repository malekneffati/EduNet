// paymee-backend/index.js
const express = require("express");
const cors = require("cors");
const axios = require("axios");
require("dotenv").config();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 5000;
const PAYMEE_KEY = process.env.PAYMEE_KEY; // Ta clé sandbox

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

app.post("/paymeeWebhook", (req, res) => {
  const { token, check_sum, payment_status, order_id } = req.body;
  console.log("Webhook reçu:", req.body);

  // Ici tu peux stocker le paiement réussi dans Firestore si besoin
  res.send("OK");
});

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
