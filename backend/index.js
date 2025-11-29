import express from "express";
import fetch from "node-fetch";
import cors from "cors";

const BASE_URL = "https://sandbox.paymee.tn/api/v2"; // important

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
    orderId, // optionnel mais pratique
  } = req.body;

  try {
    const response = await fetch(`${BASE_URL}/payments/create`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        // Paymee attend "Token <clé>", pas "Bearer <clé>"
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
        webhook_url:
          process.env.PAYMEE_WEBHOOK_URL ||
          "https://api.render.com/deploy/srv-d4lav2ggjchc73ak44t0?key=fohpEePdf-4", 
        order_id: orderId || "TEST-ORDER",
      }),
    });

    console.log("PAYMEE_API_KEY length:", process.env.PAYMEE_API_KEY?.length);

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
