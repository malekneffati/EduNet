import React from "react";
import ReactDOM from "react-dom/client";
import { BrowserRouter } from "react-router-dom";
import App from "./App";
import "./index.css";

const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </React.StrictMode>
);

const admin = require("firebase-admin");

admin.initializeApp();


// ---------- SET ADMIN ROLE ----------
exports.setAdminRole = functions.https.onCall(async (data, context) => {
  if (!context.auth)
    throw new functions.https.HttpsError("unauthenticated", "Non connecté.");

  if (context.auth.token.email !== "admin@example.com")
    throw new functions.https.HttpsError(
      "permission-denied",
      "Accès interdit."
    );

  await admin.auth().setCustomUserClaims(data.uid, { role: "admin" });

  return { message: "Rôle admin attribué." };
});

