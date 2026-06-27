#!/bin/bash
# ONE1GOD — Android SDK Auto-Setup pour Codespaces
set -e
G='\033[0;32m'; B='\033[0;34m'; Y='\033[1;33m'; N='\033[0m'

ANDROID_HOME="$HOME/android-sdk"
CMDLINE_TOOLS="$ANDROID_HOME/cmdline-tools"
SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"

echo -e "${B}🤖 Configuration Android SDK...${N}"

sudo apt-get update -qq
sudo apt-get install -y -qq wget unzip curl git 2>/dev/null

if [ ! -d "$CMDLINE_TOOLS/latest" ]; then
  echo -e "${Y}📥 Téléchargement Android SDK...${N}"
  mkdir -p "$CMDLINE_TOOLS"
  wget -q "$SDK_URL" -O /tmp/cmdline-tools.zip
  unzip -q /tmp/cmdline-tools.zip -d /tmp/cmdline-tools-tmp
  mv /tmp/cmdline-tools-tmp/cmdline-tools "$CMDLINE_TOOLS/latest"
  rm -rf /tmp/cmdline-tools.zip /tmp/cmdline-tools-tmp
  echo -e "${G}✅ Android SDK téléchargé${N}"
else
  echo -e "${G}✅ Android SDK déjà présent${N}"
fi

export ANDROID_HOME="$HOME/android-sdk"
export PATH="$PATH:$CMDLINE_TOOLS/latest/bin:$ANDROID_HOME/platform-tools"

echo -e "${Y}📋 Acceptation licences Android...${N}"
yes | sdkmanager --licenses > /dev/null 2>&1 || true

echo -e "${Y}📦 Installation composants Android...${N}"
sdkmanager --install \
  "platform-tools" \
  "platforms;android-34" \
  "build-tools;34.0.0" \
  > /dev/null 2>&1
echo -e "${G}✅ Composants Android installés${N}"

if ! grep -q "ANDROID_HOME" ~/.bashrc; then
  echo '' >> ~/.bashrc
  echo '# Android SDK' >> ~/.bashrc
  echo "export ANDROID_HOME=\"$HOME/android-sdk\"" >> ~/.bashrc
  echo "export ANDROID_SDK_ROOT=\"$HOME/android-sdk\"" >> ~/.bashrc
  echo 'export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"' >> ~/.bashrc
fi

java -version 2>&1 | head -1
node --version

echo -e "\n${B}╔══════════════════════════════════════════╗${N}"
echo -e "${B}║  ✅  ENVIRONNEMENT PRÊT !                ║${N}"
echo -e "${B}║  Java 21 + Node 24 + Android SDK         ║${N}"
echo -e "${B}╚══════════════════════════════════════════╝${N}"
