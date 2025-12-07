
import express from "express";
import fetch from "node-fetch";
import cors from "cors";
import "dotenv/config";


const BASE_URL = "https://sandbox.paymee.tn/api/v2";

const app = express();
app.use(cors());
app.use(express.json());

// 🔹 1) CREATE PAYMENT — Appelée par React

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
    return res.status(500).json({ message: "Clé Paymee non configurée" });
  }

  try {
    const payload = {
      amount: Number(amount),
      note: note || "Achat cours",
      first_name: firstName || "User",
      last_name: lastName || "Unknown",
      email: email,
      phone: phone || "+21600000000",
      return_url: returnUrl,
      cancel_url: cancelUrl,
      order_id: orderId || "EDUNET-ORDER",
    };

    const response = await fetch(`${BASE_URL}/payments/create`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Token ${process.env.PAYMEE_API_KEY}`,
      },


    });

    const data = await response.json();

    if (!response.ok) {
      console.log("Erreur Paymee:", data);
      return res.status(response.status).json(data);
    }

    return res.json({
      token: data.data.token,
      payment_url: data.data.payment_url,
    });
  } catch (err) {
    console.log("Erreur backend createPayment :", err);
    return res.status(500).json({ message: "Erreur serveur backend" });
  }
});

// 🔹 2) PAYMENT SUCCESS — Redirection Paymee → Render backend

app.get("/payment-success", async (req, res) => {
  const { courseId, userId, payment_token, returnUrl } = req.query;

  if (!payment_token) return res.status(400).send("payment_token manquant");

  try {
    // 🔎 Vérification du paiement Paymee
    const verify = await fetch(`${BASE_URL}/payments/${payment_token}`, {
      headers: { Authorization: `Token ${process.env.PAYMEE_API_KEY}` },
    });
    const data = await verify.json();
    console.log("Paymee verify response:", data);

    if (data.status !== 200 || data.data?.payment_status !== "ENDED") {
      return res.status(400).send("Paiement non validé");
    }

    await firestore
      .collection("users")
      .doc(userId)
      .collection("myCourses")
      .doc(courseId)
      .set({
        joinedAt: admin.firestore.FieldValue.serverTimestamp(),
        progress: 0,
        courseId,
      });

    // 🔁 Rediriger vers frontend
    if (returnUrl) return res.redirect(returnUrl);
    return res.send("Cours ajouté avec succès !");
  } catch (err) {
    console.error("Erreur Paymee :", err);
    return res.status(500).send("Erreur interne");
  }
});

// 🚀 Start server

const PORT = process.env.PORT || 10001;
app.listen(PORT, () => console.log("Server running on port " + PORT));

