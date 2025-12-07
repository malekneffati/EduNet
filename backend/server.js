const express = require('express');
const axios = require('axios');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 10000;

// Middleware
app.use(cors());
app.use(express.json());

// Configuration Paymee depuis .env
const PAYMEE_API_KEY = process.env.PAYMEE_API_KEY;
const PAYMEE_VENDOR_ID = process.env.PAYMEE_VENDOR_ID;
const PAYMEE_ENV = process.env.PAYMEE_ENV || 'sandbox';
const TUNNEL_URL = 'https://thirty-turkeys-remain.loca.lt';
const PAYMEE_API_URL = PAYMEE_ENV === 'production'
  ? 'https://app.paymee.tn/api/v2/payments/create'
  : 'https://sandbox.paymee.tn/api/v2/payments/create';

// Vérification de la configuration
if (!PAYMEE_API_KEY || PAYMEE_API_KEY === 'REMPLACEZ_PAR_VOTRE_CLE_API') {
  console.warn('⚠️  ATTENTION: Clés Paymee non configurées !');
  console.warn('⚠️  Éditez le fichier backend/.env et ajoutez vos vraies clés.');
}

// Route de test
app.get('/', (req, res) => {
  res.json({ message: 'EduNet Payment Backend is running!' });
});

// Route pour créer un paiement Paymee
app.post('/createPayment', async (req, res) => {
  try {
    const { amount, note, firstName, lastName, email, phone, orderId } = req.body;

    console.log('📝 Demande de paiement reçue:', {
      amount,
      orderId,
      email
    });

    // Validation des données
    if (!amount || !orderId || !email) {
      return res.status(400).json({
        error: 'Données manquantes',
        message: 'amount, orderId et email sont requis'
      });
    }

    // Préparer la requête pour Paymee
    const paymeePayload = {
      vendor: PAYMEE_VENDOR_ID,
      amount: parseFloat(amount) * 1000,
      note: note || `Paiement EduNet - ${orderId}`,
      first_name: firstName || 'Etudiant',
      last_name: lastName || 'EduNet',
      email: email,
      phone: phone || '00000000',
      return_url: `${TUNNEL_URL}/payment/success`,
      cancel_url: `${TUNNEL_URL}/payment/cancel`,
      webhook_url: `${TUNNEL_URL}/webhook/paymee`,
      order_id: orderId
    };

    console.log('🚀 Envoi vers Paymee:', paymeePayload);

    // Appel à l'API Paymee
    const response = await axios.post(PAYMEE_API_URL, paymeePayload, {
      headers: {
        'Authorization': `Token ${PAYMEE_API_KEY}`,
        'Content-Type': 'application/json'
      }
    });

    console.log('✅ Réponse Paymee:', response.data);

    // Retourner l'URL de paiement
    if (response.data && response.data.data && response.data.data.payment_url) {
      res.json({
        success: true,
        payment_url: response.data.data.payment_url,
        payment_token: response.data.data.token
      });
    } else {
      throw new Error('URL de paiement non reçue de Paymee');
    }

  } catch (error) {
    console.error('❌ Erreur Paymee:', error.response?.data || error.message);

    res.status(500).json({
      error: 'Erreur lors de la création du paiement',
      message: error.response?.data?.message || error.message,
      details: error.response?.data
    });
  }
});

// Route de succès après paiement
app.get('/payment/success', (req, res) => {
  const { payment_token, order_id } = req.query;

  console.log('✅ Paiement réussi !', { payment_token, order_id });

  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Paiement Réussi</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          display: flex;
          justify-content: center;
          align-items: center;
          min-height: 100vh;
          margin: 0;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .container {
          background: white;
          padding: 40px;
          border-radius: 20px;
          box-shadow: 0 20px 60px rgba(0,0,0,0.3);
          text-align: center;
          max-width: 500px;
        }
        .success-icon {
          width: 80px;
          height: 80px;
          background: #10B981;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          margin: 0 auto 20px;
        }
        h1 { color: #10B981; }
        p { color: #666; margin: 10px 0; }
        .info { font-size: 14px; color: #999; margin-top: 20px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="success-icon">✓</div>
        <h1>Paiement Réussi !</h1>
        <p>Votre paiement a été effectué avec succès.</p>
        <p>Vous pouvez fermer cette fenêtre et retourner à l'application.</p>
        <p class="info">Commande: ${order_id || 'N/A'}</p>
      </div>
    </body>
    </html>
  `);
});

// Route d'annulation de paiement
app.get('/payment/cancel', (req, res) => {
  const { order_id } = req.query;

  console.log('❌ Paiement annulé', { order_id });

  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Paiement Annulé</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          display: flex;
          justify-content: center;
          align-items: center;
          min-height: 100vh;
          margin: 0;
          background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        }
        .container {
          background: white;
          padding: 40px;
          border-radius: 20px;
          box-shadow: 0 20px 60px rgba(0,0,0,0.3);
          text-align: center;
          max-width: 500px;
        }
        .cancel-icon {
          width: 80px;
          height: 80px;
          background: #EF4444;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          margin: 0 auto 20px;
        }
        h1 { color: #EF4444; }
        p { color: #666; margin: 10px 0; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="cancel-icon">✕</div>
        <h1>Paiement Annulé</h1>
        <p>Vous avez annulé le paiement.</p>
        <p>Aucun montant n'a été débité.</p>
        <p>Vous pouvez fermer cette fenêtre.</p>
      </div>
    </body>
    </html>
  `);
});

// Webhook pour recevoir les notifications de Paymee
app.post('/webhook/paymee', async (req, res) => {
  try {
    console.log('🔔 Webhook Paymee reçu:', req.body);

    const { payment_token, status, order_id } = req.body;

    if (status === 'completed' || status === 'success') {
      console.log(`✅ Paiement réussi pour la commande ${order_id}`);
      // TODO: Mettre à jour Firestore pour donner accès au cours
    } else if (status === 'failed' || status === 'cancelled') {
      console.log(`❌ Paiement échoué/annulé pour la commande ${order_id}`);
    }

    res.status(200).json({ received: true });
  } catch (error) {
    console.error('❌ Erreur webhook:', error);
    res.status(500).json({ error: error.message });
  }
});

// Démarrer le serveur
app.listen(PORT, () => {
  console.log(`
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   🚀 EduNet Payment Backend démarré avec succès !        ║
║                                                           ║
║   📍 URL: http://localhost:${PORT}                          ║
║   📍 Tunnel: ${TUNNEL_URL}        ║
║   📍 Pour émulateur: http://10.0.2.2:${PORT}                ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
  `);
});
