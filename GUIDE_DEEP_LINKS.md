# 🔄 Guide - Retour Automatique vers l'Application

## ✅ Ce qui a été configuré

Le système de deep linking est maintenant en place pour que l'application mobile reçoive automatiquement les notifications de paiement.

### 📱 Flux de paiement complet :

```
1. Utilisateur clique "Payer maintenant — 10 TND"
   ↓
2. App Flutter → Backend → Paymee API
   ↓
3. Navigateur s'ouvre sur Paymee
   ↓
4. Utilisateur entre téléphone + mot de passe
   ↓
5. Paiement effectué sur Paymee
   ↓
6. Paymee redirige vers: edunet://payment/success
   ↓
7. Android intercepte le lien et ouvre l'app
   ↓
8. L'app reçoit la notification de succès
   ↓
9. L'accès au cours est accordé automatiquement
   ↓
10. Message de confirmation affiché
   ↓
11. Scroll automatique vers les chapitres
```

## 🔧 Fichiers modifiés :

1. **AndroidManifest.xml** - Ajout du deep link intent filter
2. **pubspec.yaml** - Ajout du package `uni_links`
3. **deep_link_service.dart** - Service pour gérer les deep links
4. **course_details_view.dart** - Écoute des retours de paiement
5. **server.js** - URLs de retour mises à jour

## 🧪 Comment tester :

### Étape 1 : Redémarrer l'application
```bash
# Arrêtez l'app actuelle (Ctrl+C dans le terminal flutter run)
# Puis relancez :
flutter run
```

### Étape 2 : Tester le paiement
1. Ouvrez le cours "Développement Web Complet"
2. Cliquez sur "Payer maintenant — 10 TND"
3. Paymee s'ouvre dans le navigateur
4. Complétez le paiement
5. **L'application se rouvrira automatiquement**
6. Vous verrez un message vert "✅ Paiement réussi !"
7. La page scrollera vers les chapitres
8. Le contenu sera déverrouillé

### Étape 3 : Tester l'annulation
1. Recommencez le processus
2. Sur Paymee, cliquez sur "Annuler"
3. **L'application se rouvrira automatiquement**
4. Vous verrez un message orange "❌ Paiement annulé"

## 🎯 Schéma des Deep Links :

```
edunet://payment/success?order_id=COURSE_123&payment_token=abc
└─┬─┘  └──┬───┘ └──┬──┘ └────────────┬────────────────────┘
  │       │        │                  │
Scheme  Host    Path            Query Parameters
```

- **Scheme**: `edunet` (identifie votre app)
- **Host**: `payment` (catégorie de deep link)
- **Path**: `success` ou `cancel` (résultat)
- **Query**: Données additionnelles (order_id, payment_token)

## ⚙️ Configuration Android :

Le fichier `AndroidManifest.xml` contient maintenant :

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="edunet"/>
    <data android:host="payment"/>
</intent-filter>
```

Cela permet à Android d'intercepter les liens `edunet://payment/*` et de les rediriger vers votre application.

## 🐛 Dépannage :

### L'app ne se rouvre pas après paiement
- Vérifiez que vous avez bien redémarré l'app après les modifications
- Sur émulateur, les deep links fonctionnent parfois différemment
- Testez sur un appareil physique si possible

### Le message de succès n'apparaît pas
- Vérifiez les logs dans le terminal : `print('Deep link reçu: ...')`
- Assurez-vous que le backend est toujours en cours d'exécution

### Tester manuellement un deep link
```bash
# Sur Android (via adb)
adb shell am start -W -a android.intent.action.VIEW -d "edunet://payment/success?order_id=TEST123"
```

## 📝 Notes importantes :

1. **Backend doit être actif** : Le backend Node.js doit tourner pendant les tests
2. **Redémarrage requis** : Après modification de AndroidManifest.xml, redémarrez l'app
3. **Logs utiles** : Surveillez la console pour voir les deep links reçus

Tout est prêt ! Testez maintenant le flux complet de paiement. 🚀
