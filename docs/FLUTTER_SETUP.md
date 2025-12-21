# Flutter Installation & Setup Guide

## Install Flutter

### Option 1: Using Homebrew (Recommended for Mac)

```bash
# Install Flutter via Homebrew
brew install --cask flutter

# Add Flutter to PATH (if not already added)
echo 'export PATH="$PATH:/opt/homebrew/Caskroom/flutter/latest/flutter/bin"' >> ~/.zshrc
source ~/.zshrc

# Verify installation
flutter --version
```

### Option 2: Manual Installation

1. Download Flutter SDK:
   ```bash
   cd ~/development
   git clone https://github.com/flutter/flutter.git -b stable
   ```

2. Add to PATH:
   ```bash
   echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
   source ~/.zshrc
   ```

3. Run Flutter doctor:
   ```bash
   flutter doctor
   ```

### Post-Installation

```bash
# Accept Android licenses (if using Android)
flutter doctor --android-licenses

# Install dependencies
flutter precache

# Verify everything works
flutter doctor -v
```

## Create Flutter Project (After Installation)

Once Flutter is installed, run these commands:

```bash
# Navigate to project directory
cd /Users/pawan/Desktop/anti_gravity

# Create Flutter project
flutter create flutter_app

# Navigate to flutter_app
cd flutter_app

# Add dependencies
flutter pub add flutter_riverpod dio cached_network_image intl

# Add dev dependencies
flutter pub add --dev flutter_lints

# Run the app (simulator/emulator must be running)
flutter run
```

## Quick Test

To verify Flutter is installed correctly:

```bash
flutter --version
flutter doctor
```

Expected output should show Flutter SDK version and diagnostic information.

---

## Alternative: I Can Create the Flutter Structure Manually

If you prefer, I can create all the Flutter files manually without using `flutter create`. This way you can add Flutter SDK installation later and the code will be ready to run.

Would you like me to:
1. **Wait for you to install Flutter** (recommended - takes 5-10 minutes)
2. **Create the Flutter structure manually** (I'll create all necessary files)

Let me know your preference!
