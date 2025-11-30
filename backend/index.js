// EduNet/backend/index.js
import express from "express";
import fetch from "node-fetch";
import cors from "cors";
import "dotenv/config"; // charge les variables d'environnement

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

  if (!process.env.PAYMEE_API_KEY) {
    console.error("PAYMEE_API_KEY manquant !");
    return res.status(500).json({ message: "Clé Paymee non configurée" });
  }

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
        first_name: firstName || "User",
        last_name: lastName || "Unknown",
        email: email || "user@example.com",
        phone: phone || "+21600000000",
        return_url: returnUrl,
        cancel_url: cancelUrl,
        webhook_url: process.env.PAYMEE_WEBHOOK_URL || "",
        order_id: orderId || "EDUNET-ORDER",
      }),
    });

    const data = await response.json();
    console.log("Réponse Paymee :", data);

    if (!response.ok) {
      console.error("Erreur Paymee:", data);
      return res.status(response.status).json(data);
    }

    if (!data.data?.token || !data.data?.payment_url) {
      console.error("Réponse Paymee invalide :", data);
      return res.status(500).json({ message: "Payment_url manquant" });
    }

    return res.json({
      token: data.data.token,
      payment_url: data.data.payment_url,
    });
  } catch (err) {
    console.error("Erreur backend :", err);
    res.status(500).json({ message: "Erreur serveur" });
  }
});

const PORT = process.env.PORT || 10000;
app.listen(PORT, () => console.log("Server running on port " + PORT));
