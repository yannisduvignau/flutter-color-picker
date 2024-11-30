# Color Picker

**Color Picker** est une application Flutter permettant aux utilisateurs de créer et de gérer des palettes de couleurs. Vous pouvez enregistrer vos palettes, ajouter des couleurs, voir les détails de chaque palette, et plus encore. L'application utilise Firebase pour stocker les palettes et gérer les utilisateurs.

## Getting Started

### Prérequis

Avant de démarrer avec le projet, assurez-vous d'avoir installé les outils suivants :

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Firebase](https://firebase.google.com/docs/flutter/setup) : Assurez-vous d'avoir configuré un projet Firebase pour votre application.
- [Android Studio / VS Code](https://flutter.dev/docs/get-started/editor) : Éditeurs recommandés pour développer des applications Flutter.

### Installation

Clonez le dépôt du projet :

```bash
git clone https://github.com/your-username/color_picker.git
cd color_picker
```

### Configuration de Firebase

1. Allez sur Firebase Console.
2. Créez un nouveau projet Firebase et connectez-le à votre application Flutter.
3. Ajoutez les fichiers de configuration nécessaires à votre projet Flutter :
    - Pour Android : google-services.json
    - Pour iOS : GoogleService-Info.plist
4. Activez Firestore et l'authentification par email et mot de passe dans la console Firebase.

### Dépendances

Exécutez la commande suivante pour installer les dépendances :

```bash
flutter pub get
```

## Commandes à lancer

### Pour démarrer l'application sur un simulateur ou un appareil :
```bash
flutter run
```

### Pour vérifier la qualité du code et la présence de problèmes :
```bash
flutter analyze
```

### Pour générer une version de production de votre application (Android) :
```bash
flutter build apk
```

### Pour générer une version iOS de votre application :
```bash
flutter build ios
```

## Lancer Firebase en local

Si vous souhaitez exécuter Firebase en local pour le développement, vous pouvez utiliser Firebase Local Emulator Suite pour émuler Firestore et d'autres services Firebase.

```bash
Copier le code
firebase emulators:start
```
Assurez-vous que Firebase CLI est installé avant de lancer cette commande.

## Fonctionnalités
- Création de palettes de couleurs : Créez et enregistrez des palettes de couleurs dans Firebase.
- Affichage des palettes : Consultez vos palettes précédemment enregistrées.
- Affichage des couleurs en hexadécimal : Chaque couleur est affichée avec sa valeur hexadécimale.
- Suppression des palettes : Supprimez les palettes dont vous n'avez plus besoin.
- Modification du nom des palettes : Modifiez facilement le nom d'une palette de couleurs.


