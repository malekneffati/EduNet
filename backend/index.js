const express = require("express");
const fetch = require("node-fetch");
const cors = require("cors");

const app = express();
app.use(express.json());
app.use(cors()); // pour autoriser ton front React à appeler l'API

const PAYMEE_API_KEY = "196db5766bcfa5b7fac9b262a8cd01afe0a63d24";
const BASE_URL = "https://sandbox.paymee.tn/api/v2";

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
  } = req.body;

  try {
    const response = await fetch(`${BASE_URL}/payments/create`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${PAYMEE_API_KEY}`,
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
      }),
    });

    const data = await response.json();
    if (!response.ok) return res.status(400).json(data);

    return res.status(200).json(data.data); // { token, payment_url }
  } catch (err) {
    console.error("Erreur serveur:", err);
    return res.status(500).json({ message: err.message });
  }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
