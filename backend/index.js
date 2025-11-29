import express from "express";
import fetch from "node-fetch";
import cors from "cors";

const app = express();
app.use(cors());
app.use(express.json());

app.post("/createPayment", async (req, res) => {
  try {
    const apiKey = process.env.PAYMEE_API_KEY;
    if (!apiKey) {
      return res.status(500).json({ message: "Missing Paymee API Key" });
    }

    const response = await fetch(
      "https://sandbox.paymee.tn/api/v2/payments/create",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Token ${apiKey}`, 
        },
        body: JSON.stringify(req.body),
      }
    );

    console.log("=== DEBUG ===");
    console.log("API Key lue:", apiKey);
    console.log("Header Authorization:", `Token ${apiKey}`);


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

// 🔥 OBLIGATOIRE POUR RENDER
const PORT = process.env.PORT || 10000;
app.listen(PORT, () => console.log("Server running on port " + PORT));
