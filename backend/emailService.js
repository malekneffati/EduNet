//src/backend/emailService.js
import SibApiV3Sdk from "sib-api-v3-sdk";

const client = SibApiV3Sdk.ApiClient.instance;
client.authentications["api-key"].apiKey = process.env.BREVO_API_KEY;

export async function sendConfirmationEmail(toEmail, courseTitle) {
  const apiInstance = new SibApiV3Sdk.TransactionalEmailsApi();

  const sendSmtpEmail = new SibApiV3Sdk.SendSmtpEmail();
  sendSmtpEmail.sender = { name: "EduNet", email: "malekneffati912@gmail.com" };
  sendSmtpEmail.to = [{ email: toEmail }];
  sendSmtpEmail.subject = `Confirmation d'achat : ${courseTitle}`;
  sendSmtpEmail.htmlContent = `<h1>Bravo !</h1><p>Vous avez accès au cours : <strong>${courseTitle}</strong></p>`;

  try {
    await apiInstance.sendTransacEmail(sendSmtpEmail);
    console.log(`Email envoyé à ${toEmail}`);
  } catch (err) {
    console.error("Erreur envoi email :", err);
  }
}
