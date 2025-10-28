const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.setAdminRole = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Vous devez être connecté."
    );
  }
  // Replace with your admin email or logic to determine admins
  if (context.auth.token.email !== "admin@example.com") {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Accès réservé aux admins."
    );
  }
  try {
    await admin.auth().setCustomUserClaims(data.uid, { role: "admin" });
    return { message: `Utilisateur ${data.uid} est maintenant admin.` };
  } catch (error) {
    throw new functions.https.HttpsError(
      "internal",
      "Erreur lors de l’attribution du rôle."
    );
  }
});
