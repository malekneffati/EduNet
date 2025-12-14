// src/backend/emailService.js
import SibApiV3Sdk from "sib-api-v3-sdk";

const client = SibApiV3Sdk.ApiClient.instance;
client.authentications["api-key"].apiKey = process.env.BREVO_API_KEY;

export async function sendConfirmationEmail(toEmail, courseTitle) {
  const apiInstance = new SibApiV3Sdk.TransactionalEmailsApi();

  const sendSmtpEmail = new SibApiV3Sdk.SendSmtpEmail();

  sendSmtpEmail.sender = {
    name: "EduNet",
    email: "malekneffati912@gmail.com",
  };

  sendSmtpEmail.to = [{ email: toEmail }];

  sendSmtpEmail.subject = `Confirmation d'achat – ${courseTitle}`;

  sendSmtpEmail.htmlContent = `
<!DOCTYPE html>
<html>
  <body style="margin:0; padding:0; background-color:#f5f7fa; font-family: Arial, sans-serif;">
    <table width="100%" cellpadding="0" cellspacing="0" style="padding:30px 0;">
      <tr>
        <td align="center">
          <table width="600" cellpadding="0" cellspacing="0"
            style="background:#ffffff; border-radius:8px; padding:30px;
                   box-shadow:0 2px 8px rgba(0,0,0,0.08);">

            <tr>
              <td align="center" style="padding-bottom:20px;">
                <h1 style="margin:0; color:#1f2937;">Bravo 🎉</h1>
                <p style="margin:10px 0 0; color:#6b7280; font-size:15px;">
                  Votre paiement a été confirmé avec succès
                </p>
              </td>
            </tr>

            <tr>
              <td style="padding:20px 0; color:#374151; font-size:16px;">
                <p style="margin:0 0 10px;">Vous avez désormais accès au cours :</p>
                <p style="margin:0; font-size:18px;">
                  <strong>${courseTitle}</strong>
                </p>
              </td>
            </tr>

            <tr>
              <td align="center" style="padding:30px 0;">
                <a href="https://edunet-1574d.web.app/dashboard"
                  style="background:#2563eb; color:#ffffff; text-decoration:none;
                         padding:12px 24px; border-radius:6px;
                         font-weight:bold; display:inline-block;">
                  Accéder à mon cours
                </a>
              </td>
            </tr>

            <tr>
              <td style="border-top:1px solid #e5e7eb; padding-top:20px;
                         color:#6b7280; font-size:13px;">
                <p style="margin:0;">
                  Support :
                  <a href="mailto:support@edunet.tn" style="color:#2563eb;">
                    support@edunet.tn
                  </a>
                </p>
                <p style="margin:8px 0 0;">
                  © ${new Date().getFullYear()} EduNet — Tous droits réservés
                </p>
              </td>
            </tr>

          </table>
        </td>
      </tr>
    </table>
  </body>
</html>
`;

  try {
    await apiInstance.sendTransacEmail(sendSmtpEmail);
    console.log(`📧 Email envoyé à ${toEmail}`);
  } catch (err) {
    console.error("❌ Erreur envoi email :", err);
  }
}
