// EduNet/backend/index.js
import express from "express";
import fetch from "node-fetch";
import cors from "cors";
import "dotenv/config";

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

const PORT = process.env.PORT || 10000;
app.listen(PORT, () => console.log("Server running on port " + PORT));
