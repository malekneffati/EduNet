# 🚀 Backend de Paiement EduNet - Paymee

Backend Node.js pour gérer les paiements via Paymee pour l'application mobile EduNet.

## 📋 Prérequis

- Node.js (version 14 ou supérieure)
- npm ou yarn
- Compte Paymee (https://paymee.tn)

## 🔧 Installation

### 1. Installer les dépendances

```bash
cd backend
npm install
```

### 2. Configurer les clés Paymee

1. Copiez le fichier `.env.example` vers `.env` :
```bash
copy .env.example .env
```

2. Ouvrez `.env` et remplacez les valeurs par vos vraies clés Paymee :
```env
PAYMEE_API_KEY=votre_vraie_cle_api
PAYMEE_VENDOR_ID=votre_vraie_vendor_id
```

### 3. Obtenir vos clés Paymee

1. Créez un compte sur https://paymee.tn
2. Connectez-vous à votre tableau de bord
3. Allez dans **Paramètres** > **API**
4. Copiez votre **API Key** et **Vendor ID**
5. Pour tester, utilisez l'environnement **Sandbox**

## 🚀 Démarrage

### Mode développement (avec auto-reload)
```bash
npm run dev
```

### Mode production
```bash
npm start
```

Le serveur démarre sur `http://localhost:10000`

## 📱 Configuration de l'application Flutter

L'application Flutter est déjà configurée pour se connecter au backend :

- **Sur émulateur Android** : `http://10.0.2.2:10000`
- **Sur appareil physique** : Remplacez par l'IP de votre PC (ex: `http://192.168.1.100:10000`)

## 🔌 Endpoints disponibles

### GET /
Test de connexion au serveur

### POST /createPayment
Crée un paiement Paymee

**Body (JSON):**
```json
{
  "amount": 10,
  "orderId": "COURSE_abc123_1234567890",
  "email": "user@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "phone": "12345678",
  "returnUrl": "https://edunet.com/success",
  "cancelUrl": "https://edunet.com/cancel"
}
```

**Réponse:**
```json
{
  "success": true,
  "payment_url": "https://sandbox.paymee.tn/gateway/...",
  "payment_token": "token_xyz"
}
```

### POST /webhook/paymee
Reçoit les notifications de Paymee après paiement

## 🧪 Test du backend

### Avec curl
```bash
curl http://localhost:10000
```

### Avec Postman
1. Créez une requête POST vers `http://localhost:10000/createPayment`
2. Ajoutez le body JSON avec les données de paiement
3. Envoyez la requête

## 🔒 Sécurité

⚠️ **IMPORTANT** :
- Ne commitez JAMAIS le fichier `.env` avec vos vraies clés
- Utilisez l'environnement Sandbox pour les tests
- En production, utilisez HTTPS et validez les webhooks

## 📝 Logs

Le serveur affiche des logs détaillés :
- 📝 Demandes reçues
- 🚀 Envois vers Paymee
- ✅ Réponses réussies
- ❌ Erreurs
- 🔔 Webhooks reçus

## 🐛 Dépannage

### Le serveur ne démarre pas
- Vérifiez que le port 10000 n'est pas déjà utilisé
- Vérifiez que Node.js est installé : `node --version`

### L'application Flutter ne se connecte pas
- Vérifiez que le serveur est démarré
- Sur émulateur Android, utilisez `10.0.2.2` au lieu de `localhost`
- Sur appareil physique, utilisez l'IP de votre PC

### Erreur "API Key invalide"
- Vérifiez que vous avez copié la bonne clé depuis Paymee
- Vérifiez que vous utilisez l'environnement correct (Sandbox/Production)

## 📞 Support

Pour toute question sur Paymee, consultez :
- Documentation : https://docs.paymee.tn
- Support : support@paymee.tn
