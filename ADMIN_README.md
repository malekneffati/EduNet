# Interface d'Administration EduNet

## Vue d'ensemble

L'interface d'administration permet de gérer tous les aspects de la plateforme EduNet, y compris les cours, les utilisateurs, les paiements et les promotions.

## Fonctionnalités implémentées

### 1. Dashboard Admin (`/admin`)
- **Statistiques en temps réel** :
  - Nombre total d'utilisateurs
  - Nombre de cours disponibles
  - Revenus totaux (TND)
  - Abonnements actifs
- **Graphiques** :
  - Ventes mensuelles
  - Activité des utilisateurs
- **Actions rapides** :
  - Accès rapide à la gestion des cours
  - Accès rapide à la gestion des utilisateurs
  - Consultation des paiements
  - Création de promotions

### 2. Gestion des Cours (`/admin/courses`)
- **Liste des cours** :
  - Affichage en tableau avec colonnes : Titre, Catégorie, Prix, Date de création
  - Barre de recherche pour filtrer les cours
  - Actions : Modifier, Supprimer
- **Bouton d'ajout** :
  - Accès rapide au formulaire de création de cours

### 3. Formulaire de Cours (`/admin/courses/add` et `/admin/courses/edit/:id`)
- **Champs du formulaire** :
  - Titre du cours *
  - Description
  - Catégorie (Développement, Marketing, Design, Business, Finance, Langues)
  - Instructeur *
  - Durée *
  - Cours gratuit (checkbox)
  - Prix (TND) - si non gratuit
- **Upload de fichiers** :
  - Document PDF
  - Vidéo du cours
- **Validation** :
  - Tous les champs marqués * sont obligatoires
  - Vérification du prix si le cours n'est pas gratuit
- **Barre de progression** :
  - Affichage lors de l'upload des fichiers

## Architecture

### ViewModels
- `AdminDashboardViewModel` : Gestion des statistiques du dashboard
- `CourseManagementViewModel` : Gestion de la liste des cours et recherche
- `CourseFormViewModel` : Gestion du formulaire de cours et upload de fichiers
- `AdminSidebarViewModel` : Gestion de la navigation dans la sidebar

### Services
- `CourseService` : Service pour toutes les opérations CRUD sur les cours
  - Création, lecture, mise à jour, suppression de cours
  - Upload de PDF et vidéos vers Firebase Storage
  - Recherche de cours
  - Filtrage par catégorie

### Composants
- `AdminSidebar` : Barre latérale de navigation
- `AdminHeader` : En-tête avec informations utilisateur
- `StatCard` : Carte de statistique réutilisable

## Routes

```dart
/admin                      → Dashboard administrateur
/admin/courses              → Liste des cours
/admin/courses/add          → Ajouter un cours
/admin/courses/edit/:id     → Modifier un cours
/admin/users                → Gestion des utilisateurs (à implémenter)
/admin/payments             → Gestion des paiements (à implémenter)
/admin/promotions           → Gestion des promotions (à implémenter)
```

## Dépendances ajoutées

```yaml
flutter_riverpod: ^2.4.0    # State management
go_router: ^13.0.0          # Routing
file_picker: ^6.1.1         # Sélection de fichiers
firebase_storage: ^11.7.0   # Upload de fichiers
intl: ^0.19.0              # Formatage de dates
```

## Utilisation

### Accéder au dashboard admin
```dart
context.go('/admin');
```

### Ajouter un cours
1. Naviguer vers `/admin/courses`
2. Cliquer sur "Ajouter un cours"
3. Remplir le formulaire
4. Uploader les fichiers (optionnel)
5. Cliquer sur "Mettre à jour"

### Modifier un cours
1. Naviguer vers `/admin/courses`
2. Cliquer sur "Modifier" pour le cours souhaité
3. Modifier les champs
4. Cliquer sur "Mettre à jour"

### Supprimer un cours
1. Naviguer vers `/admin/courses`
2. Cliquer sur "Supprimer" pour le cours souhaité
3. Confirmer la suppression

## Prochaines étapes

- [ ] Implémenter la gestion des utilisateurs
- [ ] Implémenter la gestion des paiements
- [ ] Implémenter la gestion des promotions
- [ ] Ajouter des graphiques interactifs
- [ ] Ajouter l'export de données
- [ ] Ajouter des filtres avancés
- [ ] Implémenter la pagination pour les grandes listes
