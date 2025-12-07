# 🎯 GUIDE RAPIDE - Configuration Backend Paymee

## ✅ Ce qui a été fait

J'ai créé un backend Node.js complet pour gérer les paiements Paymee :

```
EduNetmobil/
├── backend/
│   ├── server.js          ← Serveur principal
│   ├── package.json       ← Dépendances
│   ├── .env              ← Configuration (À ÉDITER !)
│   ├── .env.example      ← Exemple de configuration
│   └── README.md         ← Documentation complète
└── start-backend.bat     ← Script de démarrage rapide
```

## 🚀 DÉMARRAGE RAPIDE (3 étapes)

### Étape 1 : Configurer vos clés Paymee

1. Ouvrez le fichier `backend/.env`
2. Remplacez ces lignes :
   ```env
   PAYMEE_API_KEY=REMPLACEZ_PAR_VOTRE_CLE_API
   PAYMEE_VENDOR_ID=REMPLACEZ_PAR_VOTRE_VENDOR_ID
   ```
3. Par vos vraies clés obtenues sur https://paymee.tn

### Étape 2 : Démarrer le backend

**Option A - Double-cliquez sur** `start-backend.bat`

**Option B - En ligne de commande :**
```bash
cd backend
npm start
```

### Étape 3 : Tester

1. Le serveur démarre sur `http://localhost:10000`
2. Lancez votre application Flutter
3. Cliquez sur "Payer maintenant — 10 TND"
4. L'interface Paymee s'ouvrira automatiquement !

## 📱 Configuration selon votre appareil

### Sur émulateur Android
✅ Déjà configuré ! Utilise `http://10.0.2.2:10000`

### Sur appareil physique
1. Trouvez l'IP de votre PC (ex: `192.168.1.100`)
2. Modifiez `lib/services/payment_service.dart` ligne 50 :
   ```dart
   const String backendUrl = 'http://VOTRE_IP:10000/createPayment';
   ```

## 🧪 Test sans vraies clés Paymee

Si vous n'avez pas encore de compte Paymee :
1. Laissez `.env` tel quel
2. L'application affichera un dialogue "Simulation Paiement"
3. Cliquez sur "Simuler Paiement" pour tester

## ❓ Problèmes courants

### "Erreur lors de l'initialisation du paiement"
→ Le backend n'est pas démarré. Lancez `start-backend.bat`

### "Connection refused"
→ Vérifiez que le port 10000 n'est pas bloqué par le pare-feu

### "API Key invalide"
→ Vérifiez vos clés dans `backend/.env`

## 📞 Besoin d'aide ?

Consultez `backend/README.md` pour la documentation complète !
