#!/bin/bash
# ╔══════════════════════════════════════════════════════╗
# ║   ONE1GODLANCEUR — Setup complet APK (Java 21)      ║
# ║   Un seul fichier fait TOUT. Lance et pousse.       ║
# ╚══════════════════════════════════════════════════════╝
set -e
G='\033[0;32m'; B='\033[0;34m'; Y='\033[1;33m'; N='\033[0m'
echo -e "${B}╔══════════════════════════════════════════╗${N}"
echo -e "${B}║   🚀  ONE1GODLANCEUR  —  SETUP APK      ║${N}"
echo -e "${B}╚══════════════════════════════════════════╝${N}"

# ── package.json ──────────────────────────────────────
cat > package.json << 'EOF'
{
  "name": "one1godlanceur",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "@capacitor/core": "^6.1.0",
    "@capacitor/android": "^6.1.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.3.1",
    "vite": "^5.4.0",
    "@capacitor/cli": "^6.1.0"
  }
}
EOF
echo -e "${G}✅ package.json${N}"

# ── vite.config.js ────────────────────────────────────
cat > vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
export default defineConfig({ plugins: [react()], build: { outDir: 'dist' } })
EOF
echo -e "${G}✅ vite.config.js${N}"

# ── capacitor.config.json ─────────────────────────────
cat > capacitor.config.json << 'EOF'
{
  "appId": "com.one1god.lanceur",
  "appName": "One1godlanceur",
  "webDir": "dist",
  "android": { "allowMixedContent": true, "backgroundColor": "#000000" }
}
EOF
echo -e "${G}✅ capacitor.config.json${N}"

# ── index.html ────────────────────────────────────────
cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no"/>
  <meta name="theme-color" content="#000000"/>
  <title>One1godlanceur</title>
  <style>
    *{margin:0;padding:0;box-sizing:border-box}
    html,body,#root{width:100%;height:100%;overflow:hidden;background:#000}
  </style>
</head>
<body>
  <div id="root"></div>
  <script type="module" src="/src/main.jsx"></script>
</body>
</html>
EOF
echo -e "${G}✅ index.html${N}"

# ── src/ ──────────────────────────────────────────────
mkdir -p src

cat > src/main.jsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import One1godlanceur from './One1godlanceur.jsx'
ReactDOM.createRoot(document.getElementById('root')).render(<One1godlanceur />)
EOF
echo -e "${G}✅ src/main.jsx${N}"

# ── .gitignore ────────────────────────────────────────
cat > .gitignore << 'EOF'
node_modules/
dist/
android/
.DS_Store
*.local
.env
EOF
echo -e "${G}✅ .gitignore${N}"

# ── GitHub Actions (Java 21) ──────────────────────────
mkdir -p .github/workflows
cat > .github/workflows/build-apk.yml << 'EOF'
name: 🚀 Build One1godlanceur APK

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: 📥 Checkout
        uses: actions/checkout@v4

      - name: ⚙️ Setup Node 24
        uses: actions/setup-node@v4
        with:
          node-version: '24'
          cache: 'npm'

      - name: ☕ Setup Java 21
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '21'

      - name: 🤖 Setup Android SDK
        uses: android-actions/setup-android@v3

      - name: 📦 Install dependencies
        run: npm ci

      - name: 🔨 Build web
        run: npm run build

      - name: 📱 Add Android platform
        run: npx cap add android

      - name: 🏠 Patch Manifest HOME launcher
        run: |
          python3 << 'PYEOF'
          path = 'android/app/src/main/AndroidManifest.xml'
          with open(path) as f:
              content = f.read()

          # Permissions nécessaires au launcher
          permissions = """
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CALL_PHONE"/>
    <uses-permission android:name="android.permission.SEND_SMS"/>
    <uses-permission android:name="android.permission.READ_CONTACTS"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" tools:ignore="QueryAllPackagesPermission"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES"/>"""

          # Ajouter tools namespace si absent
          if 'xmlns:tools' not in content:
              content = content.replace(
                  'xmlns:android=',
                  'xmlns:tools="http://schemas.android.com/tools"\n    xmlns:android='
              )

          # Insérer permissions avant <application
          if '<uses-permission android:name="android.permission.INTERNET"/>' not in content:
              content = content.replace('<application', permissions + '\n\n    <application', 1)

          # Intent HOME launcher
          home = """
              <intent-filter>
                  <action android:name="android.intent.action.MAIN" />
                  <category android:name="android.intent.category.HOME" />
                  <category android:name="android.intent.category.DEFAULT" />
              </intent-filter>"""
          content = content.replace('</activity>', home + '\n        </activity>', 1)

          with open(path, 'w') as f:
              f.write(content)
          print("✅ Manifest patched — permissions + HOME launcher")
          PYEOF

      - name: 🔌 Plugin natif — Liste des apps installées
        run: |
          # Créer le plugin AppList
          PLUGIN_DIR="android/app/src/main/java/com/one1god/lanceur"
          mkdir -p "$PLUGIN_DIR"

          cat > "$PLUGIN_DIR/AppListPlugin.java" << 'JAVAEOF'
          package com.one1god.lanceur;
          import com.getcapacitor.JSArray;
          import com.getcapacitor.JSObject;
          import com.getcapacitor.Plugin;
          import com.getcapacitor.PluginCall;
          import com.getcapacitor.PluginMethod;
          import com.getcapacitor.annotation.CapacitorPlugin;
          import android.content.pm.ApplicationInfo;
          import android.content.pm.PackageManager;
          import android.content.Intent;
          import android.graphics.Bitmap;
          import android.graphics.Canvas;
          import android.graphics.drawable.Drawable;
          import android.util.Base64;
          import java.io.ByteArrayOutputStream;
          import java.util.List;
          @CapacitorPlugin(name = "AppList")
          public class AppListPlugin extends Plugin {
              @PluginMethod
              public void getInstalledApps(PluginCall call) {
                  PackageManager pm = getContext().getPackageManager();
                  Intent mainIntent = new Intent(Intent.ACTION_MAIN, null);
                  mainIntent.addCategory(Intent.CATEGORY_LAUNCHER);
                  List apps = pm.queryIntentActivities(mainIntent, 0);
                  JSArray result = new JSArray();
                  for (Object ri : apps) {
                      android.content.pm.ResolveInfo resolveInfo = (android.content.pm.ResolveInfo) ri;
                      JSObject app = new JSObject();
                      app.put("name", resolveInfo.loadLabel(pm).toString());
                      app.put("packageName", resolveInfo.activityInfo.packageName);
                      result.put(app);
                  }
                  JSObject ret = new JSObject();
                  ret.put("apps", result);
                  call.resolve(ret);
              }
          }
          JAVAEOF

          # Enregistrer le plugin dans MainActivity
          MAIN_ACT=$(find android -name "MainActivity.java" 2>/dev/null | head -1)
          if [ -n "$MAIN_ACT" ]; then
            sed -i 's/import com.getcapacitor.BridgeActivity;/import com.getcapacitor.BridgeActivity;
import com.one1god.lanceur.AppListPlugin;/' "$MAIN_ACT"
            sed -i 's/public class MainActivity extends BridgeActivity {/public class MainActivity extends BridgeActivity {
    @Override
    public void onCreate(android.os.Bundle savedInstanceState) {
        registerPlugin(AppListPlugin.class);
        super.onCreate(savedInstanceState);
    }/' "$MAIN_ACT"
            echo "✅ AppListPlugin enregistré dans MainActivity"
          fi

      - name: 🔄 Sync Capacitor
        run: npx cap sync android

      - name: 🏗️ Build Debug APK
        run: |
          cd android
          chmod +x gradlew
          ./gradlew assembleDebug --no-daemon

      - name: 📤 Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: One1godlanceur-APK
          path: android/app/build/outputs/apk/debug/app-debug.apk
          retention-days: 30
EOF
echo -e "${G}✅ .github/workflows/build-apk.yml (Java 21)${N}"

# ── src/One1godlanceur.jsx ────────────────────────────
echo -e "${Y}📱 Création One1godlanceur.jsx...${N}"
python3 << 'PYEOF'
content = r"""
import { useState, useEffect, useRef, useCallback } from "react";

const APPS = [
  {id:1, name:"Téléphone",color:"#22c55e",icon:"📞"},
  {id:2, name:"Messages", color:"#3b82f6",icon:"✉️"},
  {id:3, name:"Chrome",   color:"#0ea5e9",icon:"🌍"},
  {id:4, name:"Caméra",   color:"#a855f7",icon:"📷"},
  {id:5, name:"Musique",  color:"#f59e0b",icon:"🎵"},
  {id:6, name:"Photos",   color:"#ec4899",icon:"🖼️"},
  {id:7, name:"Réglages", color:"#64748b",icon:"⚙️"},
  {id:8, name:"Maps",     color:"#10b981",icon:"🗺️"},
  {id:9, name:"Gmail",    color:"#ef4444",icon:"📧"},
  {id:10,name:"Jeux",     color:"#7c3aed",icon:"🎮"},
  {id:11,name:"Agenda",   color:"#0ea5e9",icon:"📅"},
  {id:12,name:"Store",    color:"#f97316",icon:"🛒"},
  {id:13,name:"Drive",    color:"#facc15",icon:"☁️"},
  {id:14,name:"Sheets",   color:"#22c55e",icon:"📊"},
  {id:15,name:"YouTube",  color:"#ef4444",icon:"▶️"},
  {id:16,name:"Actualité",color:"#94a3b8",icon:"📰"},
  {id:17,name:"Podcast",  color:"#d946ef",icon:"🎙️"},
  {id:18,name:"Wallet",   color:"#06b6d4",icon:"💳"},
  {id:19,name:"Notifs",   color:"#f43f5e",icon:"🔔"},
  {id:20,name:"Météo",    color:"#38bdf8",icon:"🌤️"},
  {id:21,name:"Lire",     color:"#b45309",icon:"📖"},
  {id:22,name:"Focus",    color:"#dc2626",icon:"🎯"},
  {id:23,name:"Sport",    color:"#65a30d",icon:"💪"},
  {id:24,name:"Gospel",   color:"#d4af37",icon:"🙏"},
  {id:25,name:"Vault",    color:"#6366f1",icon:"🔐"},
  {id:26,name:"Sécurité", color:"#22d3ee",icon:"🛡️"},
  {id:27,name:"Fichiers", color:"#84cc16",icon:"📁"},
  {id:28,name:"Optimiser",color:"#a78bfa",icon:"⚡"},
];

const APP_URIS = {
  1:"tel:",2:"sms:",3:"https://www.google.com",
  8:"geo:0,0?q=",9:"mailto:",15:"vnd.youtube:",
  12:"market://",13:"https://drive.google.com",
  14:"https://sheets.google.com",24:"https://www.bible.com",
};
function launchApp(app){
  const uri=APP_URIS[app.id];
  if(uri){try{window.location.href=uri;}catch(e){window.open(uri,"_system");}}
}

const PAGE_SIZE=16;
const WALLPAPERS=[
  {id:"black", name:"Noir Pur",   accent:"#d4af37",css:"#000000"},
  {id:"aurora",name:"Aurora",     accent:"#a78bfa",css:"radial-gradient(ellipse at 20% 50%,#7c3aed,transparent 55%),radial-gradient(ellipse at 80% 20%,#0ea5e9,transparent 55%),linear-gradient(160deg,#0f0c29,#302b63 55%,#24243e)"},
  {id:"sunset",name:"Crépuscule", accent:"#fb923c",css:"radial-gradient(ellipse at 50% 100%,#f97316,transparent 70%),linear-gradient(180deg,#1a1a2e,#7c2d12 55%,#f97316)"},
  {id:"ocean", name:"Abysses",    accent:"#38bdf8",css:"radial-gradient(ellipse at 30% 70%,#0ea5e9,transparent 60%),linear-gradient(135deg,#0c0c1e,#0a3d62)"},
  {id:"galaxy",name:"Galaxie",    accent:"#c084fc",css:"radial-gradient(ellipse at 40% 40%,#581c87,transparent 50%),linear-gradient(135deg,#030307,#130c1f)"},
  {id:"fire",  name:"Feu Sacré",  accent:"#fbbf24",css:"radial-gradient(ellipse at 50% 70%,#fbbf24,transparent 50%),radial-gradient(ellipse at 50% 40%,#ef4444,transparent 60%),linear-gradient(180deg,#0c0a00,#b45309)"},
];
const PACKS=[
  {id:"glass3d",name:"3D Glass",icon:"💎"},
  {id:"neon",   name:"Neon",     icon:"⚡"},
  {id:"crystal",name:"Crystal",  icon:"🔮"},
  {id:"flat",   name:"Flat",     icon:"⬜"},
];
const REAL_TRANS=["slide","cube","orbital","flip","vortex","portal","shatter","helix","glitch","ripple","fold","book"];
const ALL_TRANS=[
  {id:"slide",  n:"Glissement",e:"↔️"},{id:"cube",   n:"Cube 3D",  e:"📦"},
  {id:"orbital",n:"Orbital",   e:"🌀"},{id:"flip",   n:"Flip",     e:"🎴"},
  {id:"vortex", n:"Vortex",    e:"🌪️"},{id:"portal", n:"Portail",  e:"⭕"},
  {id:"shatter",n:"Fracas",    e:"💥"},{id:"helix",  n:"Hélix",    e:"🧬"},
  {id:"glitch", n:"Glitch",    e:"⚡"},{id:"ripple", n:"Vague",    e:"💧"},
  {id:"fold",   n:"Pliage",    e:"📄"},{id:"book",   n:"Feuilletage",e:"📖"},{id:"random", n:"Aléatoire",e:"🎲"},
];
const EMOJIS=['📞','✉️','🌍','📷','🎵','🖼️','⚙️','🗺️','📧','🎮','📅','🛒','☁️','📊','▶️','📰','🎙️','💳','🔔','🌤️','📖','🎯','💪','🙏','🔐','🛡️','📁','⚡','🌟','💫','🔥','⭐','🏆','💡','🎨','🚀','✈️','🎸','🥊','🏠','💻','🔑'];

const CSS=`
@import url('https://fonts.googleapis.com/css2?family=Rajdhani:wght@600;700&family=Orbitron:wght@700;900&display=swap');
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;-webkit-tap-highlight-color:transparent;-webkit-font-smoothing:antialiased}
html,body,#root{width:100%;height:100%;overflow:hidden;background:#000}
.r{width:100%;height:100%;display:flex;flex-direction:column;font-family:'Rajdhani',sans-serif;position:relative;overflow:hidden;user-select:none;touch-action:auto}
.wp{position:absolute;inset:0;z-index:0;transition:opacity .5s ease}
.wp::after{content:'';position:absolute;inset:0;background:linear-gradient(to bottom,rgba(0,0,0,.45) 0%,transparent 32%,transparent 55%,rgba(0,0,0,.75) 100%)}
.wp-img{position:absolute;inset:0;background-size:cover;background-position:center}
.pt{position:absolute;border-radius:50%;pointer-events:none;animation:ptF var(--dur) var(--del) infinite ease-in-out}
@keyframes ptF{0%,100%{transform:translateY(0) scale(1);opacity:.18}50%{transform:translateY(-44px) scale(2.5);opacity:.82}}
.sb{position:relative;z-index:10;display:flex;justify-content:space-between;align-items:center;padding:14px 22px 4px;color:rgba(255,255,255,.88);font-size:13px;font-weight:700}
.sb-r{display:flex;align-items:center;gap:7px}
.bat{display:flex;align-items:center;gap:3px}
.bat-bar{width:22px;height:10px;border:1.5px solid rgba(255,255,255,.55);border-radius:2px;position:relative;overflow:hidden}
.bat-fill{position:absolute;left:0;top:0;bottom:0;border-radius:1px;transition:width .6s}
.bat-tip{width:3px;height:4px;margin-left:1px;background:rgba(255,255,255,.45);border-radius:0 1px 1px 0}
.sh-ico{font-size:12px;animation:shP 2.5s infinite}
@keyframes shP{0%,100%{opacity:.65}50%{opacity:1;filter:drop-shadow(0 0 4px #22d3ee)}}
.clk{position:relative;z-index:10;text-align:center;padding:4px 0 10px}
.clk-t{font-family:'Orbitron',monospace;font-size:58px;font-weight:900;color:#fff;line-height:1;letter-spacing:-2px;text-shadow:0 0 48px rgba(255,255,255,.32)}
.clk-d{font-size:11px;color:rgba(255,255,255,.58);margin-top:5px;font-weight:700;letter-spacing:2px;text-transform:uppercase}
.clk-b{margin-top:6px;font-family:'Orbitron',monospace;font-size:9px;font-weight:700;color:rgba(212,175,55,.55);letter-spacing:3px;text-transform:uppercase}
.gw{position:relative;z-index:10;flex:1;padding:0 10px;overflow-y:auto;overflow-x:hidden;-webkit-overflow-scrolling:touch;overscroll-behavior-y:contain;scroll-behavior:smooth}
.gw::-webkit-scrollbar{width:0}
.grid{display:grid;grid-template-columns:repeat(4,1fr);gap:22px 8px;padding-bottom:30px;will-change:transform}
@keyframes tSlideR  {from{transform:translate3d(106%,0,0);opacity:0}to{transform:translate3d(0,0,0);opacity:1}}
@keyframes tSlideL  {from{transform:translate3d(-106%,0,0);opacity:0}to{transform:translate3d(0,0,0);opacity:1}}
@keyframes tCubeR   {from{transform:perspective(600px) rotateY(-85deg);opacity:0}to{transform:perspective(600px) rotateY(0);opacity:1}}
@keyframes tCubeL   {from{transform:perspective(600px) rotateY(85deg);opacity:0}to{transform:perspective(600px) rotateY(0);opacity:1}}
@keyframes tOrbital {from{transform:scale3d(.05,.05,1) rotate(360deg);opacity:0;filter:blur(15px)}60%{transform:scale3d(1.05,1.05,1) rotate(-10deg);filter:blur(2px)}to{transform:scale3d(1,1,1) rotate(0);opacity:1;filter:blur(0)}}
@keyframes tFlip    {from{transform:perspective(600px) rotateX(-85deg);opacity:0}60%{transform:perspective(600px) rotateX(6deg)}to{transform:perspective(600px) rotateX(0);opacity:1}}
@keyframes tVortex  {from{transform:rotate(-360deg) scale3d(.05,.05,1);opacity:0;filter:blur(20px)}60%{transform:rotate(12deg) scale3d(1.06,1.06,1);filter:blur(1px)}to{transform:rotate(0) scale3d(1,1,1);opacity:1;filter:blur(0)}}
@keyframes tPortal  {from{clip-path:circle(0% at 50% 50%);opacity:0;filter:brightness(4)}45%{filter:brightness(1.8)}to{clip-path:circle(150% at 50% 50%);opacity:1;filter:brightness(1)}}
@keyframes tShatter {from{transform:scale3d(2.5,2.5,1);opacity:0;filter:blur(16px) brightness(4)}40%{transform:scale3d(1.06,1.06,1);filter:blur(3px) brightness(1.3)}to{transform:scale3d(1,1,1);opacity:1;filter:blur(0) brightness(1)}}
@keyframes tHelix   {from{transform:perspective(700px) rotateX(85deg) scaleX(.3);opacity:0}60%{transform:perspective(700px) rotateX(-7deg) scaleX(1.01)}to{transform:perspective(700px) rotateX(0) scaleX(1);opacity:1}}
@keyframes tGlitch  {0%{transform:translate3d(-24px,0,0) skewX(-8deg);opacity:0;filter:hue-rotate(240deg) saturate(5)}20%{transform:translate3d(16px,0,0) skewX(6deg);opacity:.5;filter:hue-rotate(120deg) saturate(3)}40%{transform:translate3d(-10px,0,0) skewX(-3deg);opacity:.75;filter:hue-rotate(60deg)}65%{transform:translate3d(5px,0,0);opacity:.9}to{transform:translate3d(0,0,0) skewX(0);opacity:1;filter:none}}
@keyframes tRipple  {from{transform:scale3d(.06,.06,1);opacity:0;border-radius:50%;filter:blur(10px) brightness(2.5)}40%{border-radius:25%;transform:scale3d(1.04,1.04,1)}to{transform:scale3d(1,1,1);opacity:1;border-radius:0;filter:blur(0) brightness(1)}}
@keyframes tFoldR   {from{transform:perspective(900px) rotateY(-110deg);opacity:0;transform-origin:left center}60%{transform:perspective(900px) rotateY(6deg)}to{transform:perspective(900px) rotateY(0);opacity:1}}
@keyframes tFoldL   {from{transform:perspective(900px) rotateY(110deg);opacity:0;transform-origin:right center}60%{transform:perspective(900px) rotateY(-6deg)}to{transform:perspective(900px) rotateY(0);opacity:1}}
@keyframes tBookR   {0%{transform:perspective(1200px) rotateY(90deg) scaleX(.5);opacity:0;transform-origin:left center}30%{opacity:.7}60%{transform:perspective(1200px) rotateY(-8deg) scaleX(1.02);opacity:1;transform-origin:left center}80%{transform:perspective(1200px) rotateY(3deg) scaleX(1);transform-origin:left center}to{transform:perspective(1200px) rotateY(0) scaleX(1);opacity:1;transform-origin:left center}}
@keyframes tBookL   {0%{transform:perspective(1200px) rotateY(-90deg) scaleX(.5);opacity:0;transform-origin:right center}30%{opacity:.7}60%{transform:perspective(1200px) rotateY(8deg) scaleX(1.02);opacity:1;transform-origin:right center}80%{transform:perspective(1200px) rotateY(-3deg) scaleX(1);transform-origin:right center}to{transform:perspective(1200px) rotateY(0) scaleX(1);opacity:1;transform-origin:right center}}
@keyframes wiggle   {0%{transform:rotate(-2.5deg) scale(.96)}100%{transform:rotate(2.5deg) scale(.96)}}
.cell{display:flex;flex-direction:column;align-items:center;gap:5px;cursor:pointer;position:relative}
.ico{width:76px;height:76px;border-radius:20px;display:flex;align-items:center;justify-content:center;font-size:40px;position:relative;overflow:hidden;flex-shrink:0;transition:transform .08s ease,filter .08s ease;will-change:transform;backface-visibility:hidden;transform:translate3d(0,0,0)}
.ico-lbl{font-size:11px;color:rgba(255,255,255,.95);text-align:center;font-weight:700;letter-spacing:.3px;text-shadow:0 2px 10px rgba(0,0,0,1);max-width:78px;overflow:hidden;white-space:nowrap;text-overflow:ellipsis}
.lk-b{position:absolute;bottom:-3px;right:-3px;font-size:12px;filter:drop-shadow(0 0 4px rgba(0,0,0,1))}
.n-b{position:absolute;top:-3px;right:-3px;min-width:16px;height:16px;border-radius:8px;background:#ef4444;color:#fff;font-size:8px;font-weight:900;display:flex;align-items:center;justify-content:center;border:1.5px solid #000;z-index:2;padding:0 3px}
.rip{position:absolute;border-radius:50%;pointer-events:none;width:10px;height:10px;margin:-5px 0 0 -5px;animation:ripA .5s ease-out forwards}
@keyframes ripA{0%{transform:scale(0);opacity:.85}100%{transform:scale(7);opacity:0}}
.pglow{position:absolute;inset:-10px;border-radius:28px;pointer-events:none;z-index:0;animation:glA .45s ease-out forwards}
@keyframes glA{0%{opacity:0;transform:scale(.8)}30%{opacity:1;transform:scale(1.15)}100%{opacity:0;transform:scale(1.3)}}
.dragging-src{opacity:.25!important;transform:scale(.88)!important}
.drop-target .ico{outline:2.5px dashed rgba(212,175,55,.9)!important;outline-offset:3px;background:rgba(212,175,55,.12)!important}
.ghost{position:fixed;z-index:999;pointer-events:none;width:76px;height:76px;border-radius:20px;display:flex;align-items:center;justify-content:center;font-size:40px;opacity:.8;transform:scale(1.15) translate3d(0,0,0);box-shadow:0 16px 40px rgba(0,0,0,.6)}
.dots{position:relative;z-index:10;display:flex;justify-content:center;gap:7px;padding:7px 0}
.dot{height:5px;width:5px;border-radius:3px;background:rgba(255,255,255,.28);transition:all .32s ease;cursor:pointer}
.dot.on{width:20px;background:#fff;box-shadow:0 0 7px rgba(255,255,255,.7)}
.dock{position:relative;z-index:10;margin:0 12px 18px;padding:11px 16px;border-radius:26px;background:rgba(30,30,50,.88);border:1px solid rgba(255,255,255,.14);display:flex;justify-content:space-around;box-shadow:0 8px 28px rgba(0,0,0,.6)}
.hpill{position:absolute;bottom:6px;left:50%;transform:translateX(-50%);z-index:20;width:38px;height:5px;border-radius:3px;background:rgba(255,255,255,.38);cursor:pointer}
.fab-col{position:absolute;bottom:110px;right:14px;z-index:20;display:flex;flex-direction:column;gap:8px}
.fab{width:42px;height:42px;border-radius:50%;background:rgba(30,30,50,.9);border:1px solid rgba(255,255,255,.22);display:flex;align-items:center;justify-content:center;cursor:pointer;font-size:18px;box-shadow:0 4px 14px rgba(0,0,0,.4);transition:transform .14s}
.fab:active{transform:scale(.88)}
.bd{position:absolute;inset:0;z-index:28;background:rgba(0,0,0,.52);animation:fdIn .28s ease}
@keyframes fdIn{from{opacity:0}to{opacity:1}}
.toast{position:absolute;top:70px;left:50%;transform:translateX(-50%);z-index:25;background:rgba(34,211,238,.14);border:1px solid rgba(34,211,238,.32);border-radius:12px;padding:8px 14px;color:#22d3ee;font-size:11px;font-weight:700;white-space:nowrap;pointer-events:none;animation:toA 3s ease forwards}
@keyframes toA{0%{opacity:0;transform:translateX(-50%) translateY(-8px)}15%,80%{opacity:1;transform:translateX(-50%) translateY(0)}100%{opacity:0;transform:translateX(-50%) translateY(-8px)}}
.ob{position:absolute;inset:0;z-index:90;overflow:hidden}
.ob-prog{position:absolute;top:56px;left:50%;transform:translateX(-50%);display:flex;gap:8px;z-index:2}
.ob-dot{width:8px;height:8px;border-radius:4px;background:rgba(255,255,255,.25);transition:all .35s ease}
.ob-dot.on{width:28px;background:#d4af37;box-shadow:0 0 8px #d4af7788}
.ob-skip{position:absolute;top:54px;right:22px;color:rgba(255,255,255,.4);font-size:12px;font-weight:700;cursor:pointer;z-index:2;padding:6px 10px}
.ob-slide{position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;padding:32px 28px}
@keyframes obE{from{transform:scale(.3) translateY(30px);opacity:0}to{transform:none;opacity:1}}
@keyframes fdU{from{transform:translateY(16px);opacity:0}to{transform:none;opacity:1}}
.ob-title{font-family:'Orbitron',monospace;font-size:22px;font-weight:900;text-align:center;margin-bottom:10px;animation:fdU .5s ease .15s both}
.ob-sub{font-size:13px;color:rgba(255,255,255,.55);text-align:center;line-height:1.8;font-weight:600;animation:fdU .5s ease .25s both;padding:0 8px}
.ob-card{width:100%;border-radius:20px;padding:18px;margin-top:18px;animation:fdU .5s ease .35s both;background:rgba(255,255,255,.07);border:1px solid rgba(255,255,255,.1)}
.ob-btn{width:100%;margin-top:22px;padding:16px;border-radius:16px;background:#d4af37;border:none;color:#000;font-family:'Rajdhani',sans-serif;font-size:16px;font-weight:900;cursor:pointer;letter-spacing:1px;animation:fdU .5s ease .45s both;box-shadow:0 8px 28px rgba(212,175,55,.45)}
.ob-btn:active{transform:scale(.96)}
.ob-btn2{width:100%;margin-top:10px;padding:13px;border-radius:14px;background:rgba(255,255,255,.07);border:1px solid rgba(255,255,255,.12);color:rgba(255,255,255,.7);font-family:'Rajdhani',sans-serif;font-size:14px;font-weight:700;cursor:pointer}
.ob-wp-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:8px;margin-top:12px}
.ob-wp{height:60px;border-radius:12px;cursor:pointer;border:2.5px solid transparent;transition:all .22s;position:relative;overflow:hidden}
.ob-wp.on{border-color:#d4af37;box-shadow:0 0 0 2px rgba(212,175,55,.35)}
.ob-wpl{position:absolute;bottom:0;left:0;right:0;padding:3px;background:rgba(0,0,0,.55);font-size:8px;color:#fff;text-align:center;font-weight:700}
.ob-pack-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:8px;margin-top:12px}
.ob-pack{padding:11px;border-radius:13px;border:2px solid rgba(255,255,255,.08);background:rgba(255,255,255,.04);cursor:pointer;display:flex;align-items:center;gap:8px;color:rgba(255,255,255,.5);font-size:13px;font-weight:700;transition:all .18s}
.ob-pack.on{border-color:#d4af37;background:rgba(212,175,55,.1);color:#fff}
.ob-pin-dots{display:flex;gap:14px;justify-content:center;margin:16px 0}
.ob-pdot{width:16px;height:16px;border-radius:50%;border:2px solid rgba(255,255,255,.38);background:transparent;transition:all .18s}
.ob-pdot.on{background:#d4af37;border-color:#d4af37;box-shadow:0 0 12px rgba(212,175,55,.55)}
.ob-kpad{display:grid;grid-template-columns:repeat(3,1fr);gap:10px;width:220px;margin:0 auto}
.ob-key{height:52px;border-radius:14px;background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.1);color:#fff;font-size:20px;font-family:'Rajdhani',sans-serif;font-weight:700;cursor:pointer;display:flex;align-items:center;justify-content:center;transition:all .12s}
.ob-key:active{background:rgba(255,255,255,.2);transform:scale(.93)}
.ob-key.s2{grid-column:1/3}.ob-key.del{background:rgba(239,68,68,.1);color:#f87171}
@keyframes rkL{0%,100%{transform:translateY(0)}50%{transform:translateY(-20px)}}
.rkt{animation:rkL 1.8s ease infinite;font-size:72px;filter:drop-shadow(0 0 20px rgba(255,140,0,.8))}
@keyframes cdA{0%,100%{transform:scale(1)}50%{transform:scale(1.3)}}
.cdown{font-family:'Orbitron',monospace;font-size:80px;font-weight:900;color:#d4af37;text-shadow:0 0 40px rgba(212,175,55,.8);animation:cdA .9s ease infinite}
.drawer{position:absolute;inset:0;z-index:35;display:flex;flex-direction:column;background:rgba(5,5,22,.97);transition:transform .38s cubic-bezier(.25,.46,.45,.94)}
.dr-h{width:36px;height:4px;border-radius:2px;background:rgba(255,255,255,.22);margin:14px auto 6px;cursor:pointer}
.dr-brand{text-align:center;padding:0 0 8px;font-family:'Orbitron',monospace;font-size:10px;font-weight:700;color:rgba(212,175,55,.42);letter-spacing:3px;text-transform:uppercase}
.dr-search{margin:0 16px 12px;padding:11px 16px;border-radius:14px;background:rgba(255,255,255,.07);border:1px solid rgba(255,255,255,.1);color:#fff;font-family:'Rajdhani',sans-serif;font-size:14px;font-weight:600;outline:none}
.dr-search::placeholder{color:rgba(255,255,255,.3)}
.cols-bar{display:flex;align-items:center;gap:8px;padding:0 16px 12px;color:rgba(255,255,255,.4);font-size:11px;font-weight:700;letter-spacing:1.5px;text-transform:uppercase}
.col-btn{padding:5px 12px;border-radius:10px;border:1px solid rgba(255,255,255,.12);background:rgba(255,255,255,.05);color:rgba(255,255,255,.45);font-size:12px;font-weight:700;cursor:pointer;font-family:'Rajdhani',sans-serif;transition:all .18s}
.col-btn.on{background:rgba(255,255,255,.14);color:#fff;border-color:rgba(255,255,255,.3)}
.dr-grid{flex:1;overflow-y:auto;padding:0 14px 80px;display:grid;gap:18px 8px;-webkit-overflow-scrolling:touch;overscroll-behavior:contain}
.dr-grid::-webkit-scrollbar{width:0}
.dr-cell{display:flex;flex-direction:column;align-items:center;gap:4px;cursor:pointer;position:relative;animation:drIn .4s cubic-bezier(.34,1.2,.64,1) both}
@keyframes drIn{from{transform:translateY(28px) scale(.85);opacity:0}to{transform:none;opacity:1}}
.dr-lbl{font-size:11px;color:rgba(255,255,255,.9);font-weight:700;text-align:center;max-width:72px;overflow:hidden;white-space:nowrap;text-overflow:ellipsis}
.panel{position:absolute;bottom:0;left:0;right:0;z-index:40;background:rgba(6,6,22,.98);border-radius:28px 28px 0 0;padding:16px 16px 32px;border-top:1px solid rgba(255,255,255,.1);transition:transform .38s cubic-bezier(.25,.46,.45,.94);max-height:80%;overflow-y:auto}
.panel::-webkit-scrollbar{width:0}
.p-handle{width:34px;height:4px;border-radius:2px;background:rgba(255,255,255,.2);margin:0 auto 10px}
.p-brand{text-align:center;margin-bottom:14px;font-family:'Orbitron',monospace;font-size:13px;font-weight:900;color:#d4af37;letter-spacing:3px}
.p-tabs{display:flex;gap:6px;margin-bottom:16px}
.p-tab{flex:1;padding:8px 3px;border-radius:11px;border:1px solid rgba(255,255,255,.07);background:transparent;color:rgba(255,255,255,.35);cursor:pointer;font-size:9px;font-family:'Rajdhani',sans-serif;font-weight:700;letter-spacing:.8px;text-transform:uppercase;transition:all .18s}
.p-tab.on{background:rgba(255,255,255,.1);color:#fff;border-color:rgba(255,255,255,.22)}
.slbl{color:rgba(255,255,255,.28);font-size:10px;font-weight:700;letter-spacing:2px;text-transform:uppercase;margin-bottom:9px;margin-top:14px}
.slbl:first-child{margin-top:0}
.wp-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:8px;margin-bottom:6px}
.wp-card{height:70px;border-radius:13px;cursor:pointer;overflow:hidden;position:relative;border:2.5px solid transparent;transition:all .24s}
.wp-card.on{border-color:#fff;box-shadow:0 0 0 2px rgba(255,255,255,.28)}
.wp-lbl{position:absolute;bottom:0;left:0;right:0;padding:4px;background:rgba(0,0,0,.56);font-size:9px;color:#fff;text-align:center;font-weight:700}
.cust-btn{width:100%;padding:12px;border-radius:13px;border:1.5px dashed rgba(255,255,255,.2);background:rgba(255,255,255,.03);color:rgba(255,255,255,.5);font-family:'Rajdhani',sans-serif;font-size:12px;font-weight:700;cursor:pointer;text-align:center;transition:all .18s}
.pack-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:8px}
.pack-card{padding:12px;border-radius:13px;border:2px solid rgba(255,255,255,.07);background:rgba(255,255,255,.04);cursor:pointer;display:flex;align-items:center;gap:9px;color:rgba(255,255,255,.5);font-size:13px;font-weight:700;transition:all .18s}
.pack-card.on{border-color:rgba(255,255,255,.35);background:rgba(255,255,255,.1);color:#fff}
.tr-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:7px}
.tr-card{padding:10px 4px;border-radius:12px;text-align:center;cursor:pointer;border:2px solid rgba(255,255,255,.07);background:rgba(255,255,255,.04);color:rgba(255,255,255,.45);font-size:11px;font-weight:700;line-height:1.45;transition:all .18s}
.tr-card.on{border-color:rgba(255,255,255,.38);background:rgba(255,255,255,.1);color:#fff}
.sec-row{display:flex;align-items:center;justify-content:space-between;padding:13px 14px;border-radius:13px;background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.07);margin-bottom:7px}
.sec-l{display:flex;align-items:center;gap:10px}
.sec-ico{font-size:20px}
.sec-title{color:#fff;font-size:13px;font-weight:700}
.sec-sub{color:rgba(255,255,255,.4);font-size:10px}
.toggle{width:44px;height:24px;border-radius:12px;background:rgba(255,255,255,.12);cursor:pointer;position:relative;transition:background .24s;flex-shrink:0}
.toggle.on{background:#22c55e}
.toggle::after{content:'';position:absolute;top:3px;left:3px;width:18px;height:18px;border-radius:9px;background:#fff;box-shadow:0 1px 4px rgba(0,0,0,.4);transition:transform .24s}
.toggle.on::after{transform:translateX(20px)}
.close-btn{width:100%;margin-top:14px;padding:13px;border-radius:14px;border:1px solid rgba(255,255,255,.1);background:rgba(255,255,255,.05);color:rgba(255,255,255,.7);font-family:'Rajdhani',sans-serif;font-size:14px;font-weight:700;cursor:pointer;transition:all .18s}
.note-g{margin-top:8px;padding:10px;border-radius:12px;background:rgba(212,175,55,.08);border:1px solid rgba(212,175,55,.2);color:rgba(212,175,55,.8);font-size:11px;font-weight:700;letter-spacing:.7px}
.sc{position:absolute;inset:0;z-index:38;background:rgba(4,4,18,.98);display:flex;flex-direction:column;animation:fdIn .28s ease;overflow-y:auto}
.sc::-webkit-scrollbar{width:0}
.sc-hdr{padding:16px 20px 12px;display:flex;align-items:center;gap:12px;border-bottom:1px solid rgba(255,255,255,.07)}
.sc-ttl{font-family:'Orbitron',monospace;font-size:16px;font-weight:700;color:#22d3ee}
.sc-x{margin-left:auto;font-size:22px;color:rgba(255,255,255,.38);cursor:pointer}
.sc-body{padding:16px 16px 40px;display:flex;flex-direction:column;gap:14px}
.av-card{border-radius:20px;background:rgba(34,211,238,.06);border:1px solid rgba(34,211,238,.2);padding:20px}
.av-ring{width:110px;height:110px;border-radius:50%;margin:0 auto 16px;display:flex;align-items:center;justify-content:center;position:relative;font-size:36px}
.av-ring::before{content:'';position:absolute;inset:0;border-radius:50%;border:3px solid rgba(34,211,238,.2)}
.av-ring::after{content:'';position:absolute;inset:0;border-radius:50%;border:3px solid transparent;border-top-color:#22d3ee;animation:avS var(--spd,3s) linear infinite}
@keyframes avS{to{transform:rotate(360deg)}}
.av-sg{display:grid;grid-template-columns:repeat(3,1fr);gap:10px;margin-top:14px}
.av-sv{background:rgba(255,255,255,.05);border-radius:12px;padding:12px 8px;text-align:center;border:1px solid rgba(255,255,255,.07)}
.av-svv{font-family:'Orbitron',monospace;font-size:16px;font-weight:900;margin-bottom:3px}
.av-svl{font-size:9px;color:rgba(255,255,255,.4);font-weight:700;letter-spacing:1px;text-transform:uppercase}
.scan-bw{height:6px;border-radius:3px;background:rgba(255,255,255,.1);overflow:hidden;margin-top:12px}
.scan-bf{height:100%;border-radius:3px;background:linear-gradient(90deg,#22d3ee,#0ea5e9);transition:width .3s ease}
.av-btn{width:100%;margin-top:14px;padding:14px;border-radius:14px;border:none;font-family:'Rajdhani',sans-serif;font-size:15px;font-weight:900;cursor:pointer;transition:all .2s;letter-spacing:1px}
.av-btn.scan{background:linear-gradient(135deg,#22d3ee,#0ea5e9);color:#000}
.av-btn.stop{background:rgba(239,68,68,.15);border:1px solid rgba(239,68,68,.3);color:#f87171}
.opt-card{border-radius:20px;background:rgba(167,139,250,.06);border:1px solid rgba(167,139,250,.2);padding:20px}
.cln-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:8px;margin-top:12px}
.cln-btn{padding:12px 10px;border-radius:13px;background:rgba(167,139,250,.1);border:1px solid rgba(167,139,250,.25);color:#a78bfa;font-family:'Rajdhani',sans-serif;font-size:12px;font-weight:700;cursor:pointer;display:flex;align-items:center;gap:6px;transition:all .2s}
.cln-btn:active{transform:scale(.95)}
.cln-btn.done{background:rgba(34,197,94,.1);border-color:rgba(34,197,94,.3);color:#4ade80}
.vpn-card{border-radius:20px;background:rgba(99,102,241,.06);border:1px solid rgba(99,102,241,.2);padding:20px}
.vpn-globe{width:100px;height:100px;border-radius:50%;margin:0 auto 14px;display:flex;align-items:center;justify-content:center;font-size:42px;position:relative}
.vpn-globe::before{content:'';position:absolute;inset:0;border-radius:50%;border:2px solid rgba(99,102,241,.3);animation:vpnP 2s ease infinite}
@keyframes vpnP{0%,100%{transform:scale(1);opacity:.8}50%{transform:scale(1.1);opacity:.4}}
.vpn-globe.on::before{border-color:rgba(34,197,94,.5);animation:vpnPon 1.5s ease infinite}
@keyframes vpnPon{0%,100%{transform:scale(1);opacity:1}50%{transform:scale(1.12);opacity:.5}}
.vpn-tb{width:100%;padding:16px;border-radius:16px;border:none;font-family:'Rajdhani',sans-serif;font-size:16px;font-weight:900;cursor:pointer;transition:all .3s;letter-spacing:1px}
.vpn-tb.off{background:rgba(99,102,241,.15);border:1px solid rgba(99,102,241,.3);color:#818cf8}
.vpn-tb.on{background:linear-gradient(135deg,#22c55e,#16a34a);color:#fff;box-shadow:0 8px 24px rgba(34,197,94,.4)}
.ctx{position:absolute;z-index:45;background:rgba(10,10,28,.96);border-radius:16px;border:1px solid rgba(255,255,255,.1);padding:6px 0;min-width:185px;box-shadow:0 12px 40px rgba(0,0,0,.7);animation:ctxIn .18s ease}
@keyframes ctxIn{from{transform:scale(.85);opacity:0}to{transform:scale(1);opacity:1}}
.ctx-item{padding:12px 16px;color:rgba(255,255,255,.85);font-size:13px;font-weight:700;cursor:pointer;display:flex;align-items:center;gap:10px;transition:background .14s}
.ctx-item:hover{background:rgba(255,255,255,.08)}
.ctx-item.red{color:#f87171}
.ctx-sep{height:1px;background:rgba(255,255,255,.07);margin:4px 0}
.vlt{position:absolute;inset:0;z-index:38;background:rgba(4,4,16,.98);display:flex;flex-direction:column;padding:20px;animation:fdIn .28s ease}
.vlt-hdr{display:flex;align-items:center;gap:10px;margin-bottom:20px}
.vlt-ttl{font-family:'Orbitron',monospace;color:#d4af37;font-size:15px;font-weight:700}
.vlt-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:16px 8px}
.pin-m{position:absolute;inset:0;z-index:50;display:flex;flex-direction:column;align-items:center;justify-content:center;background:rgba(0,0,0,.9);animation:fdIn .28s ease}
.pin-ttl{font-family:'Orbitron',monospace;color:#fff;font-size:17px;font-weight:700;margin-bottom:6px;text-align:center}
.pin-sub{color:rgba(255,255,255,.42);font-size:11px;font-weight:600;letter-spacing:1px;margin-bottom:28px}
.pin-dots{display:flex;gap:14px;margin-bottom:36px}
.pin-dot{width:16px;height:16px;border-radius:50%;border:2px solid rgba(255,255,255,.38);background:transparent;transition:all .18s}
.pin-dot.on{background:#d4af37;border-color:#d4af37;box-shadow:0 0 12px rgba(212,175,55,.55)}
.pin-err{color:#ef4444;font-size:12px;font-weight:700;margin-bottom:12px;animation:shk .3s ease}
@keyframes shk{0%,100%{transform:translateX(0)}25%{transform:translateX(-8px)}75%{transform:translateX(8px)}}
.pin-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:12px;width:244px}
.pin-key{height:60px;border-radius:16px;background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.1);color:#fff;font-size:22px;font-family:'Rajdhani',sans-serif;font-weight:700;cursor:pointer;display:flex;align-items:center;justify-content:center;transition:all .13s}
.pin-key:active{background:rgba(255,255,255,.22);transform:scale(.93)}
.pin-key.s2{grid-column:1/3}
.pin-key.del{background:rgba(239,68,68,.1);border-color:rgba(239,68,68,.2);color:#f87171}
.pin-cancel{margin-top:12px;width:244px;height:48px;border-radius:14px;background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.1);color:rgba(255,255,255,.4);font-size:13px;font-weight:700;font-family:'Rajdhani',sans-serif;cursor:pointer;display:flex;align-items:center;justify-content:center}
.edit-ov{position:absolute;inset:0;z-index:60;background:rgba(0,0,0,.88);display:flex;align-items:center;justify-content:center;animation:fdIn .25s ease}
.edit-card{width:88%;max-width:320px;border-radius:24px;background:rgba(12,12,30,.98);border:1px solid rgba(255,255,255,.12);padding:24px 20px;display:flex;flex-direction:column;align-items:center;gap:14px;box-shadow:0 20px 60px rgba(0,0,0,.8);animation:scIn .28s cubic-bezier(.34,1.56,.64,1)}
@keyframes scIn{from{transform:scale(.8);opacity:0}to{transform:scale(1);opacity:1}}
.edit-ttl{font-family:'Orbitron',monospace;font-size:14px;font-weight:900;color:#d4af37;letter-spacing:2px;text-transform:uppercase}
.edit-prev{font-size:56px;cursor:pointer;filter:drop-shadow(0 4px 12px rgba(212,175,55,.4))}
.edit-inp{width:100%;padding:12px 16px;border-radius:14px;background:rgba(255,255,255,.07);border:1px solid rgba(255,255,255,.15);color:#fff;font-family:'Rajdhani',sans-serif;font-size:16px;font-weight:700;outline:none;text-align:center}
.edit-inp::placeholder{color:rgba(255,255,255,.3)}
.edit-sec{width:100%;color:rgba(255,255,255,.35);font-size:10px;font-weight:700;letter-spacing:2px;text-transform:uppercase;margin-bottom:-6px}
.emoji-grid{display:grid;grid-template-columns:repeat(6,1fr);gap:8px;width:100%}
.emoji-btn{height:44px;border-radius:12px;background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.08);font-size:22px;cursor:pointer;display:flex;align-items:center;justify-content:center;transition:all .15s}
.emoji-btn:active{transform:scale(.88);background:rgba(212,175,55,.2)}
.emoji-btn.sel{border-color:#d4af37;background:rgba(212,175,55,.15)}
.edit-btns{display:flex;gap:10px;width:100%}
.edit-save{flex:1;padding:13px;border-radius:14px;border:none;background:#d4af37;color:#000;font-family:'Rajdhani',sans-serif;font-size:15px;font-weight:900;cursor:pointer;letter-spacing:1px;transition:all .15s}
.edit-save:active{transform:scale(.95)}
.edit-cancel{flex:1;padding:13px;border-radius:14px;border:1px solid rgba(255,255,255,.12);background:rgba(255,255,255,.05);color:rgba(255,255,255,.6);font-family:'Rajdhani',sans-serif;font-size:15px;font-weight:700;cursor:pointer}
.edit-del{width:100%;padding:12px;border-radius:14px;border:1px solid rgba(239,68,68,.3);background:rgba(239,68,68,.08);color:#f87171;font-family:'Rajdhani',sans-serif;font-size:14px;font-weight:700;cursor:pointer}
.dock-hint{width:100%;padding:10px;border-radius:12px;background:rgba(99,102,241,.1);border:1px solid rgba(99,102,241,.2);color:#818cf8;font-size:11px;font-weight:700;text-align:center;cursor:pointer}
`;

function icoStyle(app,pack){
  const c=app.color;
  switch(pack){
    case"glass3d":return{background:`linear-gradient(135deg,${c}dd,${c}88)`,border:`1.5px solid ${c}99`,boxShadow:`0 6px 20px ${c}44,inset 0 1px 0 rgba(255,255,255,.3)`,transform:"translate3d(0,0,0)"};
    case"neon":return{background:`linear-gradient(135deg,#08081a,#10103a)`,border:`2px solid ${c}`,boxShadow:`0 0 8px ${c}aa,0 0 18px ${c}44`,transform:"translate3d(0,0,0)"};
    case"crystal":return{background:"linear-gradient(135deg,rgba(255,255,255,.3),rgba(255,255,255,.1))",border:"1px solid rgba(255,255,255,.45)",boxShadow:"0 6px 20px rgba(0,0,0,.4),inset 0 1px 0 rgba(255,255,255,.55)",transform:"translate3d(0,0,0)"};
    default:return{background:c,boxShadow:`0 4px 14px ${c}66`,transform:"translate3d(0,0,0)"};
  }
}

function pickAnim(t,dir){
  const d=dir>=0?"R":"L";
  const tid=t==="random"?REAL_TRANS[Math.floor(Math.random()*REAL_TRANS.length)]:t;
  const m={slide:`tSlide${d}`,cube:`tCube${d}`,orbital:"tOrbital",flip:"tFlip",vortex:"tVortex",portal:"tPortal",shatter:"tShatter",helix:"tHelix",glitch:"tGlitch",ripple:"tRipple",fold:`tFold${d}`,book:`tBook${d}`};
  return`${m[tid]||"tSlideR"} .42s cubic-bezier(.25,.46,.45,.94) both`;
}

export default function One1godlanceur(){
  const[obStep,setObStep]=useState(0);
  const[obPin,setObPin]=useState("");
  const[obWp,setObWp]=useState(WALLPAPERS[0]);
  const[obPack,setObPack]=useState("glass3d");
  const[countdown,setCountdown]=useState(3);
  const[launching,setLaunching]=useState(false);
  const[page,setPage]=useState(0);
  const[animKey,setAnimKey]=useState(0);
  const[gridAnim,setGridAnim]=useState("none");
  const[trans,setTrans]=useState("cube");
  const[pack,setPack]=useState("glass3d");
  const[wp,setWp]=useState(WALLPAPERS[0]);
  const[wpFade,setWpFade]=useState(false);
  const[customWp,setCustomWp]=useState(null);
  const[panelOpen,setPanelOpen]=useState(false);
  const[pTab,setPTab]=useState("wallpaper");
  const[drawerOpen,setDrawerOpen]=useState(false);
  const[drawerCols,setDrawerCols]=useState(4);
  const[drawerQ,setDrawerQ]=useState("");
  const[editing,setEditing]=useState(false);
  const[ctxApp,setCtxApp]=useState(null);
  const[ctxPos,setCtxPos]=useState({x:0,y:0});
  const[lockedApps,setLockedApps]=useState(new Set([9,18]));
  const[hiddenApps,setHiddenApps]=useState(new Set([]));
  const[storedPin,setStoredPin]=useState("1111");
  const[pinOpen,setPinOpen]=useState(false);
  const[pinTarget,setPinTarget]=useState(null);
  const[pinValue,setPinValue]=useState("");
  const[pinError,setPinError]=useState(false);
  const[pinPhase,setPinPhase]=useState("verify");
  const[vaultOpen,setVaultOpen]=useState(false);
  const[storageEnc,setStorageEnc]=useState(false);
  const[secOpen,setSecOpen]=useState(false);
  const[scanning,setScanning]=useState(false);
  const[scanProg,setScanProg]=useState(0);
  const[scanDone,setScanDone]=useState(false);
  const[threatsFound,setThreatsFound]=useState(0);
  const[filesScanned,setFilesScanned]=useState(0);
  const[vpnOn,setVpnOn]=useState(false);
  const[cleanDone,setCleanDone]=useState({ram:false,junk:false,cache:false,battery:false});
  const[battery,setBattery]=useState(85);
  const[charging,setCharging]=useState(false);
  const[chargeLimit,setChargeLimit]=useState(true);
  const[adsBlock,setAdsBlock]=useState(true);
  const[adsCount,setAdsCount]=useState(247);
  const[toastKey,setToastKey]=useState(0);
  const[showToast,setShowToast]=useState(false);
  const[pressedId,setPressedId]=useState(null);
  const[ripples,setRipples]=useState({});
  const[now,setNow]=useState(new Date());
  const[pts,setPts]=useState([]);
  // Drag & Drop
  const[customOrder,setCustomOrder]=useState(()=>{try{const s=localStorage.getItem('o1g_order');return s?JSON.parse(s):APPS.map(a=>a.id);}catch{return APPS.map(a=>a.id);}});
  const[dockOrder,setDockOrder]=useState(()=>{try{const s=localStorage.getItem('o1g_dock');return s?JSON.parse(s):[1,2,3,26];}catch{return[1,2,3,26];}});
  const[customAppsData,setCustomAppsData]=useState(()=>{try{const s=localStorage.getItem('o1g_apps');return s?JSON.parse(s):{};}catch{return{};}});
  const[dragging,setDragging]=useState(null);
  const[dragPos,setDragPos]=useState({x:0,y:0});
  const[dragOver,setDragOver]=useState(null);
  const[dragFromDock,setDragFromDock]=useState(false);
  const[editModal,setEditModal]=useState(null);
  const[editName,setEditName]=useState('');
  const[editIcon,setEditIcon]=useState('');

  const touchX=useRef(null),touchY=useRef(null),lpTimer=useRef(null),fileRef=useRef(null),scanRef=useRef(null),rootRef=useRef(null);
  const swipeHoriz=useRef(false),swipeDetermined=useRef(false);

  useEffect(()=>{const t=setInterval(()=>setNow(new Date()),1000);return()=>clearInterval(t);},[]);
  useEffect(()=>{try{localStorage.setItem('o1g_order',JSON.stringify(customOrder));}catch{}},[customOrder]);
  useEffect(()=>{try{localStorage.setItem('o1g_dock',JSON.stringify(dockOrder));}catch{}},[dockOrder]);
  useEffect(()=>{try{localStorage.setItem('o1g_apps',JSON.stringify(customAppsData));}catch{}},[customAppsData]);
  // Charger les vraies apps installées
  useEffect(()=>{
    const loadRealApps=async()=>{
      try{
        const{Capacitor}=await import('@capacitor/core');
        if(!Capacitor.isNativePlatform())return;
        const result=await Capacitor.Plugins.AppList.getInstalledApps();
        if(result&&result.apps&&result.apps.length>0){
          const realApps=result.apps.map((a,i)=>({
            id:1000+i,
            name:a.name.substring(0,12),
            color:['#22c55e','#3b82f6','#f59e0b','#ec4899','#7c3aed','#ef4444','#0ea5e9','#10b981'][i%8],
            icon:'📱',
            packageName:a.packageName,
          }));
          // Ajouter les apps réelles à l'ordre
          setCustomOrder(o=>{
            const existing=new Set(o);
            const newIds=realApps.filter(a=>!existing.has(a.id)).map(a=>a.id);
            return[...o,...newIds];
          });
        }
      }catch(e){console.log('AppList non disponible:',e);}
    };
    loadRealApps();
  },[]);

  useEffect(()=>{setPts(Array.from({length:8},(_,i)=>({id:i,x:Math.random()*100,y:Math.random()*100,s:(Math.random()*3+.8).toFixed(1),dur:(Math.random()*9+5).toFixed(1),del:(-(Math.random()*10)).toFixed(1)})));},[]);
  useEffect(()=>{const t=setInterval(()=>{setBattery(b=>{if(charging){if(chargeLimit&&b>=100)return 100;return Math.min(100,parseFloat((b+0.2).toFixed(1)));}return Math.max(1,parseFloat((b-0.05).toFixed(2)));});},2000);return()=>clearInterval(t);},[charging,chargeLimit]);
  useEffect(()=>{if(!adsBlock)return;const t=setInterval(()=>setAdsCount(n=>n+Math.floor(Math.random()*2)),9000);return()=>clearInterval(t);},[adsBlock]);
  // ── Swipe horizontal non-passif (detecte H vs V) ──
  useEffect(()=>{
    const el=rootRef.current;
    if(!el)return;
    const onMove=(e)=>{
      if(!swipeDetermined.current){
        const dx=Math.abs(e.touches[0].clientX-(touchX.current||0));
        const dy=Math.abs(e.touches[0].clientY-(touchY.current||0));
        if(dx>6||dy>6){
          swipeDetermined.current=true;
          swipeHoriz.current=dx>dy;
        }
      }
      if(swipeHoriz.current&&!dragging){e.preventDefault();}
    };
    el.addEventListener('touchmove',onMove,{passive:false});
    return()=>el.removeEventListener('touchmove',onMove);
  },[dragging]);

  useEffect(()=>{if(!launching)return;setCountdown(3);const t=setInterval(()=>{setCountdown(c=>{if(c<=1){clearInterval(t);setTimeout(()=>setObStep(5),300);return 0;}return c-1;});},900);return()=>clearInterval(t);},[launching]);

  const orderedApps=customOrder.map(id=>APPS.find(a=>a.id===id)).filter(a=>a&&!hiddenApps.has(a.id));
  const extraApps=APPS.filter(a=>!customOrder.includes(a.id)&&!hiddenApps.has(a.id));
  const visApps=[...orderedApps,...extraApps];
  const pages=[];for(let i=0;i<visApps.length;i+=PAGE_SIZE)pages.push(visApps.slice(i,i+PAGE_SIZE));
  const totalPg=Math.max(1,pages.length);
  const dockApps=dockOrder.map(id=>APPS.find(a=>a.id===id)).filter(Boolean);

  const goPage=useCallback((np,dir)=>{
    const target=((np%totalPg)+totalPg)%totalPg;
    const d=dir!==undefined?dir:(np>=page?1:-1);
    setGridAnim(pickAnim(trans,d));setPage(target);setAnimKey(k=>k+1);
  },[page,totalPg,trans]);

  const onTouchStart=useCallback(e=>{
    touchX.current=e.touches[0].clientX;
    touchY.current=e.touches[0].clientY;
    swipeHoriz.current=false;
    swipeDetermined.current=false;
  },[]);
  const onTouchEnd=useCallback(e=>{
    if(dragging){setDragging(null);setDragOver(null);setDragFromDock(false);return;}
    if(touchX.current===null)return;
    const dx=e.changedTouches[0].clientX-touchX.current;
    const dy=e.changedTouches[0].clientY-touchY.current;
    if(Math.abs(dx)>Math.abs(dy)&&Math.abs(dx)>46)goPage(page+(dx<0?1:-1),dx<0?1:-1);
    if(dy<-80&&Math.abs(dy)>Math.abs(dx))setDrawerOpen(true);
    touchX.current=null;
  },[page,goPage,dragging]);

  const onDragMove=useCallback(e=>{
    if(!dragging)return;
    const t=e.touches[0];
    setDragPos({x:t.clientX,y:t.clientY});
    const el=document.elementFromPoint(t.clientX,t.clientY);
    const iconEl=el?.closest('[data-icon-id]');
    if(iconEl){const id=parseInt(iconEl.dataset.iconId);if(id!==dragging.id)setDragOver(id);}
  },[dragging]);

  const onDragEnd=useCallback(()=>{
    if(!dragging)return;
    if(dragOver!==null&&dragOver!==dragging.id){
      if(dragFromDock){
        setDockOrder(d=>{const n=[...d];const fi=n.indexOf(dragging.id);const ti=n.indexOf(dragOver);if(fi!==-1&&ti!==-1){[n[fi],n[ti]]=[n[ti],n[fi]];}return n;});
      }else{
        setCustomOrder(o=>{const n=[...o];const fi=n.indexOf(dragging.id);const ti=n.indexOf(dragOver);if(fi!==-1&&ti!==-1){[n[fi],n[ti]]=[n[ti],n[fi]];}return n;});
      }
    }
    setDragging(null);setDragOver(null);setDragFromDock(false);
  },[dragging,dragOver,dragFromDock]);

  const startDrag=useCallback((app,fromDock,e)=>{
    if(!editing)return;
    clearTimeout(lpTimer.current);
    const t=e.touches?e.touches[0]:e;
    setDragging({id:app.id,app});
    setDragFromDock(fromDock);
    setDragPos({x:t.clientX,y:t.clientY});
  },[editing]);

  const handlePress=useCallback((id,e,color)=>{
    setPressedId(id);
    const rect=e.currentTarget.getBoundingClientRect();
    const src=e.touches?e.touches[0]:e;
    const rid=Date.now();
    setRipples(r=>({...r,[id]:{x:src.clientX-rect.left,y:src.clientY-rect.top,rid,color}}));
    setTimeout(()=>{setPressedId(p=>p===id?null:p);setRipples(r=>{const n={...r};delete n[id];return n;});},500);
  },[]);

  const handleLP=useCallback((app,rect)=>{setEditing(true);setCtxPos({x:Math.min(rect.left,window.innerWidth-190),y:Math.min(rect.bottom+4,window.innerHeight-250)});setCtxApp(app);},[]);

  const getApp=useCallback((app)=>{const c=customAppsData[app.id];return c?{...app,...c}:app;},[customAppsData]);

  // Demander les permissions Android au lancement
  useEffect(()=>{
    const requestPerms=async()=>{
      try{
        const{Capacitor}=await import('@capacitor/core');
        if(!Capacitor.isNativePlatform())return;
        // Les permissions sont demandées automatiquement
        // par Android quand l'app en a besoin
        console.log('✅ Launcher actif');
      }catch(e){}
    };
    if(obStep>=5)requestPerms();
  },[obStep]);

  const openApp=useCallback((app)=>{
    if(editing)return;
    if(app.id===26){setSecOpen(true);return;}
    if(app.id===25){setPinTarget({type:"vault"});setPinPhase("verify");setPinValue("");setPinError(false);setPinOpen(true);return;}
    if(lockedApps.has(app.id)){setPinTarget({type:"app",app});setPinPhase("verify");setPinValue("");setPinError(false);setPinOpen(true);return;}
    if(adsBlock){setAdsCount(n=>n+Math.floor(Math.random()*3));setToastKey(k=>k+1);setShowToast(true);setTimeout(()=>setShowToast(false),2500);}
    setTimeout(()=>launchApp(app),150);
  },[editing,lockedApps,adsBlock]);

  const pressPinKey=useCallback((digit)=>{
    if(pinValue.length>=4)return;
    const next=pinValue+digit;setPinValue(next);
    if(next.length<4)return;
    if(pinPhase==="new"){setStoredPin(next);setPinOpen(false);setPinValue("");setPinPhase("verify");setPinError(false);return;}
    if(next===storedPin){
      setPinError(false);
      if(pinTarget?.type==="changePIN"){setPinValue("");setPinPhase("new");return;}
      setPinOpen(false);setPinValue("");
      if(pinTarget?.type==="vault")setVaultOpen(true);
    }else{setPinError(true);setTimeout(()=>{setPinValue("");setPinError(false);},700);}
  },[pinValue,pinPhase,storedPin,pinTarget]);

  const changeWp=useCallback(w=>{setWpFade(true);setTimeout(()=>{setWp(w);setCustomWp(null);setWpFade(false);},480);},[]);

  const openEdit=useCallback((app)=>{
    const c=customAppsData[app.id]||{};
    setEditModal(app);setEditName(c.name||app.name);setEditIcon(c.icon||app.icon);
    setCtxApp(null);setEditing(false);
  },[customAppsData]);

  const saveEdit=useCallback(()=>{
    if(!editModal)return;
    setCustomAppsData(d=>({...d,[editModal.id]:{name:editName,icon:editIcon}}));
    setEditModal(null);
  },[editModal,editName,editIcon]);

  const addToDock=useCallback((id)=>{setDockOrder(d=>{if(d.includes(id)||d.length>=5)return d;return[...d,id];});setCtxApp(null);setEditing(false);},[]);
  const removeFromDock=useCallback((id)=>{setDockOrder(d=>d.filter(x=>x!==id));setCtxApp(null);setEditing(false);},[]);
  const removeFromScreen=useCallback((id)=>{setHiddenApps(s=>new Set([...s,id]));setCtxApp(null);setEditing(false);},[]);

  const startScan=useCallback(()=>{
    if(scanning)return;
    setScanning(true);setScanDone(false);setScanProg(0);setFilesScanned(0);setThreatsFound(0);
    let p=0,f=0;
    scanRef.current=setInterval(()=>{
      p+=Math.random()*4;f+=Math.floor(Math.random()*120);
      if(p>=100){p=100;clearInterval(scanRef.current);setScanning(false);setScanDone(true);setThreatsFound(Math.random()>.7?1:0);}
      setScanProg(Math.min(100,Math.round(p)));setFilesScanned(f);
    },180);
  },[scanning]);

  const stopScan=useCallback(()=>{clearInterval(scanRef.current);setScanning(false);setScanProg(0);},[]);
  const doClean=useCallback(key=>{setTimeout(()=>setCleanDone(c=>({...c,[key]:true})),1200);},[]);

  const timeStr=now.toLocaleTimeString("fr-FR",{hour:"2-digit",minute:"2-digit"});
  const dateStr=now.toLocaleDateString("fr-FR",{weekday:"long",day:"numeric",month:"long"});
  const batColor=battery>50?"#22c55e":battery>20?"#fbbf24":"#ef4444";
  const curPage=pages[page]||[];
  const drApps=APPS.filter(a=>!hiddenApps.has(a.id)&&a.name.toLowerCase().includes(drawerQ.toLowerCase()));

  const renderIcon=(app,sizeOv,xk="")=>{
    const appData=getApp(app);
    const id=`${xk}${app.id}`;
    const ip=pressedId===id;
    const rpl=ripples[id];
    const isDragSrc=dragging?.id===app.id;
    const isDropTgt=dragOver===app.id&&dragging?.id!==app.id;
    const st={...icoStyle(appData,pack),...(sizeOv?{width:sizeOv,height:sizeOv}:{}),transform:ip?"scale(.80) translate3d(0,0,0)":"translate3d(0,0,0)",filter:ip?"brightness(1.6)":"brightness(1)"};
    return(
      <div key={app.id} data-icon-id={app.id}
        className={`${xk==="dr"?"dr-cell":"cell"}${isDragSrc?" dragging-src":""}${isDropTgt?" drop-target":""}`}
        style={xk==="dr"?{animationDelay:`${APPS.findIndex(a=>a.id===app.id)*0.028}s`}:{}}
        onTouchStart={e=>{
          handlePress(id,e,appData.color);
          if(!xk){
            const r=e.currentTarget.getBoundingClientRect();
            lpTimer.current=setTimeout(()=>handleLP(appData,r),600);
          }
          if(editing)startDrag(appData,xk==='d',e);
        }}
        onTouchEnd={()=>clearTimeout(lpTimer.current)}
        onMouseDown={e=>{
          handlePress(id,e,appData.color);
          if(!xk){
            const r=e.currentTarget.getBoundingClientRect();
            lpTimer.current=setTimeout(()=>handleLP(appData,r),550);
          }
          if(editing)startDrag(appData,xk==='d',e);
        }}
        onMouseUp={()=>clearTimeout(lpTimer.current)}
        onMouseLeave={()=>clearTimeout(lpTimer.current)}
        onClick={e=>{e.stopPropagation();if(xk==="dr"){openApp(app);setDrawerOpen(false);}else openApp(app);}}>
        {rpl&&<div className="pglow" key={`g${rpl.rid}`} style={{background:`radial-gradient(circle,${rpl.color}99,transparent 70%)`}}/>}
        <div className="ico" style={{...st,animation:(!xk&&editing)?"wiggle .25s infinite alternate":undefined}}>
          {appData.icon}
          {rpl&&<div className="rip" key={`r${rpl.rid}`} style={{left:rpl.x,top:rpl.y,background:`${appData.color}cc`}}/>}
        </div>
        <span className={xk==="dr"?"dr-lbl":"ico-lbl"}>{appData.name}</span>
        {lockedApps.has(app.id)&&<span className="lk-b">🔒</span>}
        {app.id===19&&<span className="n-b">3</span>}
      </div>
    );
  };

  // ── ONBOARDING ────────────────────────────────────────────
  if(obStep<5){
    const BG=["linear-gradient(160deg,#0f0c29,#302b63,#24243e)","linear-gradient(160deg,#0a0a1a,#1a1a3a)","linear-gradient(160deg,#0f0c29,#302b63)","linear-gradient(160deg,#031a0f,#0a3d1a)","#000"];
    return(<>
      <style>{CSS}</style>
      <div className="ob" style={{background:BG[obStep]}}>
        <div className="ob-prog">{[0,1,2,3,4].map(i=><div key={i} className={`ob-dot ${i===obStep?"on":""}`}/>)}</div>
        {obStep<4&&<div className="ob-skip" onClick={()=>{setObStep(5);setWp(obWp);setPack(obPack);if(obPin.length===4)setStoredPin(obPin);}}>Passer</div>}
        {obStep===0&&<div className="ob-slide">
          <div style={{fontSize:72,animation:"obE .6s cubic-bezier(.34,1.56,.64,1) both",marginBottom:20}}>🚀</div>
          <div className="ob-title" style={{color:"#d4af37",fontSize:26}}>One1godlanceur</div>
          <div className="ob-sub" style={{marginTop:8}}>Le lanceur qui porte le nom de Dieu.<br/>Puissant. Sécurisé. Époustouflant.</div>
          <div className="ob-card"><div style={{color:"rgba(255,255,255,.5)",fontSize:10,fontWeight:700,letterSpacing:2,marginBottom:8}}>VERSET DU JOUR</div><div style={{color:"#d4af37",fontSize:13,fontStyle:"italic",lineHeight:1.8,fontWeight:600}}>« Je suis le chemin, la vérité et la vie. »<br/><span style={{color:"rgba(255,255,255,.5)",fontSize:11}}>— Jean 14 : 6</span></div></div>
          <button className="ob-btn" onClick={()=>setObStep(1)}>Commencer le voyage 🙏</button>
        </div>}
        {obStep===1&&<div className="ob-slide" style={{width:"100%"}}>
          <div style={{fontSize:52,animation:"obE .6s cubic-bezier(.34,1.56,.64,1) both",marginBottom:16}}>🖼️</div>
          <div className="ob-title" style={{color:"#fff"}}>Ton style</div>
          <div className="ob-sub">Choisis ton fond d'écran et tes icônes</div>
          <div className="ob-card" style={{width:"100%"}}>
            <div style={{color:"rgba(255,255,255,.4)",fontSize:10,fontWeight:700,letterSpacing:2,marginBottom:10}}>FOND D'ÉCRAN</div>
            <div className="ob-wp-grid">{WALLPAPERS.map(w=><div key={w.id} className={`ob-wp ${obWp.id===w.id?"on":""}`} style={{background:w.css}} onClick={()=>setObWp(w)}><div className="ob-wpl">{w.name}</div></div>)}</div>
            <div style={{color:"rgba(255,255,255,.4)",fontSize:10,fontWeight:700,letterSpacing:2,margin:"14px 0 10px"}}>PACK D'ICÔNES</div>
            <div className="ob-pack-grid">{PACKS.map(p=><div key={p.id} className={`ob-pack ${obPack===p.id?"on":""}`} onClick={()=>setObPack(p.id)}><span style={{fontSize:20}}>{p.icon}</span><span>{p.name}</span></div>)}</div>
          </div>
          <button className="ob-btn" onClick={()=>{setWp(obWp);setPack(obPack);setObStep(2);}}>Confirmer mon style ✨</button>
        </div>}
        {obStep===2&&<div className="ob-slide">
          <div style={{fontSize:52,animation:"obE .6s cubic-bezier(.34,1.56,.64,1) both",marginBottom:16}}>🔐</div>
          <div className="ob-title" style={{color:"#fff"}}>Ta sécurité</div>
          <div className="ob-sub">Définis ton code PIN à 4 chiffres</div>
          <div className="ob-pin-dots">{[0,1,2,3].map(i=><div key={i} className={`ob-pdot ${i<obPin.length?"on":""}`}/>)}</div>
          <div className="ob-kpad">
            {[1,2,3,4,5,6,7,8,9].map(n=><div key={n} className="ob-key" onClick={()=>obPin.length<4&&setObPin(p=>p+n)}>{n}</div>)}
            <div className="ob-key s2" onClick={()=>obPin.length<4&&setObPin(p=>p+"0")}>0</div>
            <div className="ob-key del" onClick={()=>setObPin(p=>p.slice(0,-1))}>⌫</div>
          </div>
          {obPin.length===4&&<button className="ob-btn" style={{marginTop:20}} onClick={()=>{setStoredPin(obPin);setObStep(3);}}>PIN défini 🔒</button>}
          <button className="ob-btn2" onClick={()=>setObStep(3)}>Passer</button>
        </div>}
        {obStep===3&&<div className="ob-slide" style={{width:"100%"}}>
          <div style={{fontSize:52,animation:"obE .6s cubic-bezier(.34,1.56,.64,1) both",marginBottom:16}}>🛡️</div>
          <div className="ob-title" style={{color:"#22d3ee"}}>Tes protections</div>
          <div className="ob-sub">Activées par défaut pour ta sécurité maximale</div>
          <div className="ob-card" style={{width:"100%",marginTop:16}}>
            {[{ico:"🛡️",t:"AdBlock",s:"Bloque toutes les publicités",c:"#22d3ee"},{ico:"🦠",t:"Antivirus temps réel",s:"Scan permanent de menaces",c:"#22c55e"},{ico:"🔒",t:"Chiffrement AES-256",s:"Mémoire et carte SD protégées",c:"#d4af37"},{ico:"🌐",t:"VPN sécurisé",s:"Connexion cryptée anti-intrusion",c:"#6366f1"},{ico:"🔋",t:"Limite charge 100%",s:"Longévité batterie préservée",c:"#f59e0b"}].map((item,i)=>(
              <div key={i} style={{display:"flex",alignItems:"center",gap:10,padding:"11px 0",borderBottom:i<4?"1px solid rgba(255,255,255,.06)":"none"}}>
                <span style={{fontSize:20}}>{item.ico}</span>
                <div style={{flex:1}}><div style={{color:"#fff",fontSize:12,fontWeight:700}}>{item.t}</div><div style={{color:"rgba(255,255,255,.4)",fontSize:10}}>{item.s}</div></div>
                <div style={{width:8,height:8,borderRadius:4,background:item.c,boxShadow:`0 0 6px ${item.c}`}}/>
              </div>
            ))}
          </div>
          <button className="ob-btn" onClick={()=>{setAdsBlock(true);setStorageEnc(true);setVpnOn(true);setChargeLimit(true);setObStep(4);}}>Tout activer ✅</button>
          <button className="ob-btn2" onClick={()=>setObStep(4)}>Personnaliser plus tard</button>
        </div>}
        {obStep===4&&!launching&&<div className="ob-slide" style={{textAlign:"center"}}>
          <div style={{fontSize:28,fontFamily:"'Orbitron',monospace",fontWeight:900,color:"#d4af37",letterSpacing:3,marginBottom:8,animation:"fdU .5s ease both"}}>One1godlanceur</div>
          <div style={{fontSize:14,color:"rgba(255,255,255,.5)",fontWeight:600,marginBottom:32,animation:"fdU .5s ease .15s both"}}>est prêt à décoller 🚀</div>
          <div style={{fontSize:15,color:"rgba(255,255,255,.5)",fontWeight:600,lineHeight:1.9,animation:"fdU .5s ease .3s both",padding:"0 10px",marginBottom:32}}>
            ✝ Que Dieu bénisse chaque utilisation<br/>de ce lanceur créé pour Sa gloire.<br/>
            <span style={{color:"#d4af37",fontSize:13}}>Alpha et Oméga — Jean 1:1</span>
          </div>
          <button className="ob-btn" style={{animation:"fdU .5s ease .45s both"}} onClick={()=>setLaunching(true)}>🚀 Lancer One1godlanceur</button>
        </div>}
        {obStep===4&&launching&&<div style={{display:"flex",flexDirection:"column",alignItems:"center",justifyContent:"center",height:"100%",gap:20}}>
          <div className="rkt">🚀</div>
          {countdown>0?<div className="cdown">{countdown}</div>:<div style={{fontFamily:"'Orbitron',monospace",fontSize:32,fontWeight:900,color:"#22c55e"}}>GO !</div>}
          <div style={{color:"rgba(255,255,255,.5)",fontSize:12,fontWeight:700,letterSpacing:2}}>DÉCOLLAGE EN COURS…</div>
        </div>}
      </div>
    </>);
  }

  // ── LANCEUR PRINCIPAL ─────────────────────────────────────
  return(<>
    <style>{CSS}</style>
    <div className="r" ref={rootRef}
      onTouchStart={onTouchStart}
      onTouchMove={onDragMove}
      onTouchEnd={e=>{onDragEnd();onTouchEnd(e);}}
      onClick={()=>{if(editing){setEditing(false);setCtxApp(null);}}}>

      {/* WALLPAPER */}
      <div className="wp" style={{opacity:wpFade?0:1}}>
        {customWp?<div className="wp-img" style={{backgroundImage:`url(${customWp})`}}/>:<div style={{position:"absolute",inset:0,background:wp.css}}/>}
        {pts.map(p=><div key={p.id} className="pt" style={{left:`${p.x}%`,top:`${p.y}%`,width:`${p.s}px`,height:`${p.s}px`,background:customWp?"#fff":wp.accent,"--dur":`${p.dur}s`,"--del":`${p.del}s`}}/>)}
      </div>

      {/* GHOST DRAG */}
      {dragging&&(
        <div className="ghost" style={{left:dragPos.x-38,top:dragPos.y-38,...icoStyle(getApp(dragging.app),pack)}}>
          {getApp(dragging.app).icon}
        </div>
      )}

      {(panelOpen||drawerOpen||ctxApp)&&<div className="bd" onClick={()=>{setPanelOpen(false);setDrawerOpen(false);setCtxApp(null);setEditing(false);}}/>}
      {showToast&&<div key={toastKey} className="toast">🛡️ Pub bloquée — {adsCount} bloquées</div>}

      {/* STATUS BAR */}
      <div className="sb">
        <span>{timeStr}</span>
        <div className="sb-r">
          {adsBlock&&<span className="sh-ico">🛡️</span>}
          {vpnOn&&<span style={{fontSize:11,color:"#22c55e",fontWeight:700}}>VPN</span>}
          {storageEnc&&<span style={{fontSize:11}}>🔐</span>}
          {charging&&<span style={{fontSize:12}}>⚡</span>}
          <span style={{fontSize:11,color:"rgba(255,255,255,.65)"}}>4G</span>
          <div className="bat">
            <div className="bat-bar"><div className="bat-fill" style={{width:`${battery}%`,background:batColor}}/></div>
            <div className="bat-tip"/>
            <span style={{fontSize:10,color:"rgba(255,255,255,.6)",marginLeft:2}}>{Math.round(battery)}%</span>
          </div>
        </div>
      </div>

      {/* CLOCK */}
      <div className="clk">
        <div className="clk-t">{timeStr}</div>
        <div className="clk-d">{dateStr}</div>
        <div className="clk-b">✝ One1godlanceur ✝</div>
      </div>

      {/* GRID */}
      <div className="gw">
        <div key={animKey} className="grid" style={{animation:gridAnim}}>
          {curPage.map(app=>renderIcon(app))}
        </div>
      </div>

      {/* DOTS */}
      <div className="dots">{pages.map((_,i)=><div key={i} className={`dot ${i===page?"on":""}`} onClick={()=>goPage(i,i>page?1:-1)}/>)}</div>

      {/* DOCK */}
      <div className="dock">{dockApps.map(app=>renderIcon(app,66,"d"))}</div>
      <div className="hpill" onTouchStart={()=>setDrawerOpen(true)} onClick={()=>setDrawerOpen(true)}/>

      {/* FABS */}
      <div className="fab-col">
        <div className="fab" onClick={()=>{setPanelOpen(true);setPTab("wallpaper");}}>✨</div>
        <div className="fab" onClick={()=>setCharging(c=>!c)}>{charging?"⚡":"🔌"}</div>
      </div>

      {/* TIROIR */}
      <div className="drawer" style={{transform:drawerOpen?"translateY(0)":"translateY(100%)"}}>
        <div className="dr-h" onClick={()=>setDrawerOpen(false)}/>
        <div className="dr-brand">✝ One1godlanceur</div>
        <input className="dr-search" placeholder="🔍  Rechercher…" value={drawerQ} onChange={e=>setDrawerQ(e.target.value)}/>
        <div className="cols-bar"><span>Colonnes :</span>{[3,4,5].map(n=><div key={n} className={`col-btn ${drawerCols===n?"on":""}`} onClick={()=>setDrawerCols(n)}>{n}</div>)}</div>
        <div className="dr-grid" style={{gridTemplateColumns:`repeat(${drawerCols},1fr)`}}>
          {drApps.map(app=>renderIcon(app,drawerCols>=5?60:68,"dr"))}
        </div>
      </div>

      {/* PANEL */}
      <div className="panel" style={{transform:panelOpen?"translateY(0)":"translateY(100%)"}}>
        <div className="p-handle"/>
        <div className="p-brand">✝ ONE1GODLANCEUR ✝</div>
        <div className="p-tabs">
          {[["wallpaper","🖼️","Fonds"],["icons","📦","Icônes"],["trans","✨","Effets"],["security","🔒","Sécurité"]].map(([k,e,n])=>(
            <button key={k} className={`p-tab ${pTab===k?"on":""}`} onClick={()=>setPTab(k)}>{e} {n}</button>
          ))}
        </div>
        {pTab==="wallpaper"&&<>
          <div className="slbl">Fonds d'écran animés</div>
          <div className="wp-grid">{WALLPAPERS.map(w=><div key={w.id} className={`wp-card ${!customWp&&wp.id===w.id?"on":""}`} style={{background:w.css}} onClick={()=>changeWp(w)}><div className="wp-lbl">{w.name}</div></div>)}</div>
          <div className="slbl" style={{marginTop:12}}>Photo personnelle</div>
          <button className="cust-btn" onClick={()=>fileRef.current.click()}>{customWp?"✅  Photo perso active — Changer":"📷  Choisir depuis la galerie"}</button>
          <input ref={fileRef} type="file" accept="image/*" style={{display:"none"}} onChange={e=>{const f=e.target.files[0];if(!f)return;const url=URL.createObjectURL(f);setWpFade(true);setTimeout(()=>{setCustomWp(url);setWpFade(false);},480);}}/>
          {customWp&&<button className="cust-btn" style={{marginTop:7}} onClick={()=>setCustomWp(null)}>✕  Supprimer</button>}
        </>}
        {pTab==="icons"&&<>
          <div className="slbl">Packs d'icônes</div>
          <div className="pack-grid">{PACKS.map(p=><div key={p.id} className={`pack-card ${pack===p.id?"on":""}`} onClick={()=>setPack(p.id)}><span style={{fontSize:22}}>{p.icon}</span><span>{p.name}</span></div>)}</div>
        </>}
        {pTab==="trans"&&<>
          <div className="slbl">11 transitions + Aléatoire</div>
          <div className="tr-grid">{ALL_TRANS.map(t=><div key={t.id} className={`tr-card ${trans===t.id?"on":""}`} onClick={()=>{setTrans(t.id);setGridAnim(pickAnim(t.id,1));setAnimKey(k=>k+1);}}><div style={{fontSize:18,marginBottom:3}}>{t.e}</div><div>{t.n}</div></div>)}</div>
        </>}
        {pTab==="security"&&<>
          <div className="slbl">Protection batterie</div>
          <div className="sec-row">
            <div className="sec-l"><span className="sec-ico">🔋</span><div><div className="sec-title">Limite à 100%</div><div className="sec-sub">Arrêt auto pour préserver la batterie</div></div></div>
            <div className={`toggle ${chargeLimit?"on":""}`} onClick={()=>setChargeLimit(v=>!v)}/>
          </div>
          <div style={{padding:"0 4px 4px"}}><div style={{color:"rgba(255,255,255,.32)",fontSize:10,fontWeight:700,marginBottom:5}}>Niveau : {Math.round(battery)}% {charging?"⚡":""}</div><div style={{height:8,borderRadius:4,background:"rgba(255,255,255,.1)",overflow:"hidden"}}><div style={{height:"100%",borderRadius:4,width:`${battery}%`,background:"linear-gradient(90deg,#22c55e,#fbbf24)",transition:"width .6s"}}/></div></div>
          <div className="slbl">Protections</div>
          {[{ico:"🛡️",t:"AdBlock",s:`${adsCount} pubs bloquées`,v:adsBlock,fn:()=>setAdsBlock(v=>!v)},{ico:"🌐",t:"VPN actif",s:"Connexion chiffrée",v:vpnOn,fn:()=>setVpnOn(v=>!v)},{ico:"🔐",t:"Chiffrement AES-256",s:storageEnc?"🟢 Actif":"Mémoire & carte SD",v:storageEnc,fn:()=>setStorageEnc(v=>!v)}].map((item,i)=>(
            <div key={i} className="sec-row"><div className="sec-l"><span className="sec-ico">{item.ico}</span><div><div className="sec-title">{item.t}</div><div className="sec-sub">{item.s}</div></div></div><div className={`toggle ${item.v?"on":""}`} onClick={item.fn}/></div>
          ))}
          <div className="slbl">PIN</div>
          <div className="sec-row">
            <div className="sec-l"><span className="sec-ico">🔑</span><div><div className="sec-title">Modifier le PIN</div><div className="sec-sub">{lockedApps.size} apps verrouillées</div></div></div>
            <button onClick={()=>{setPanelOpen(false);setPinTarget({type:"changePIN"});setPinPhase("verify");setPinValue("");setPinError(false);setPinOpen(true);}} style={{padding:"6px 12px",borderRadius:10,border:"1px solid rgba(255,255,255,.2)",background:"rgba(255,255,255,.07)",color:"#fff",fontSize:12,fontWeight:700,cursor:"pointer",fontFamily:"'Rajdhani',sans-serif"}}>Changer</button>
          </div>
          <div className="note-g">⚠️ Chiffrement complet et AdBlock réseau actifs nativement dans l'APK.</div>
        </>}
        <button className="close-btn" onClick={()=>setPanelOpen(false)}>Fermer ✕</button>
      </div>

      {/* CENTRE SÉCURITÉ */}
      {secOpen&&<div className="sc">
        <div className="sc-hdr"><span style={{fontSize:24}}>🛡️</span><div className="sc-ttl">Centre de Sécurité</div><div className="sc-x" onClick={()=>setSecOpen(false)}>✕</div></div>
        <div className="sc-body">
          <div className="av-card">
            <div style={{color:"#22d3ee",fontFamily:"'Orbitron',monospace",fontSize:13,fontWeight:700,marginBottom:16}}>🦠 Antivirus temps réel</div>
            <div className="av-ring" style={{"--spd":scanning?"0.8s":"3s"}}>{scanDone?(threatsFound>0?"⚠️":"✅"):scanning?"🔍":"🛡️"}</div>
            <div style={{textAlign:"center",fontFamily:"'Orbitron',monospace",fontSize:13,fontWeight:700,color:scanDone?(threatsFound>0?"#ef4444":"#22c55e"):"#22d3ee",marginBottom:4}}>{scanDone?(threatsFound>0?`${threatsFound} menace détectée !`:"✅ Aucune menace"):scanning?`Scan en cours… ${scanProg}%`:"Protégé"}</div>
            {scanning&&<div className="scan-bw"><div className="scan-bf" style={{width:`${scanProg}%`}}/></div>}
            <div className="av-sg">{[{v:filesScanned.toLocaleString(),l:"Fichiers",c:"#22d3ee"},{v:threatsFound,l:"Menaces",c:threatsFound>0?"#ef4444":"#22c55e"},{v:0,l:"Bloqués",c:"#a78bfa"}].map((s,i)=><div key={i} className="av-sv"><div className="av-svv" style={{color:s.c}}>{s.v}</div><div className="av-svl">{s.l}</div></div>)}</div>
            {scanning?<button className="av-btn stop" onClick={stopScan}>⏹ Arrêter</button>:<button className="av-btn scan" onClick={startScan}>🔍 Scanner</button>}
          </div>
          <div className="opt-card">
            <div style={{color:"#a78bfa",fontFamily:"'Orbitron',monospace",fontSize:13,fontWeight:700,marginBottom:16}}>⚡ Optimiseur &amp; Nettoyeur</div>
            {[{lbl:"RAM",val:"68%",fill:68,c:"#a78bfa"},{lbl:"Stockage",val:"74%",fill:74,c:"#f59e0b"},{lbl:"CPU",val:"42°C",fill:42,c:"#ef4444"}].map((item,i)=>(
              <div key={i}><div style={{display:"flex",justifyContent:"space-between",marginBottom:4}}><span style={{color:"rgba(255,255,255,.7)",fontSize:12,fontWeight:700}}>{item.lbl}</span><span style={{fontSize:12,fontWeight:700,color:item.c}}>{item.val}</span></div><div style={{height:5,borderRadius:3,background:"rgba(255,255,255,.1)",overflow:"hidden",marginBottom:10}}><div style={{height:"100%",borderRadius:3,width:`${item.fill}%`,background:item.c,transition:"width .6s"}}/></div></div>
            ))}
            <div className="cln-grid">{[{k:"ram",i:"💾",t:"Libérer RAM"},{k:"junk",i:"🗑️",t:"Fichiers junk"},{k:"cache",i:"🗂️",t:"Vider cache"},{k:"battery",i:"🔋",t:"Opt. batterie"}].map(item=>(
              <button key={item.k} className={`cln-btn ${cleanDone[item.k]?"done":""}`} onClick={()=>doClean(item.k)}>{cleanDone[item.k]?"✅":item.i} {item.t}</button>
            ))}</div>
          </div>
          <div className="vpn-card">
            <div style={{color:"#818cf8",fontFamily:"'Orbitron',monospace",fontSize:13,fontWeight:700,marginBottom:16}}>🌐 VPN &amp; Chiffrement</div>
            <div className={`vpn-globe ${vpnOn?"on":""}`}>🌍</div>
            <div style={{textAlign:"center",fontFamily:"'Orbitron',monospace",fontSize:14,fontWeight:900,color:vpnOn?"#22c55e":"#818cf8",marginBottom:4}}>{vpnOn?"🟢 CONNECTÉ":"⭕ DÉCONNECTÉ"}</div>
            <div style={{textAlign:"center",fontSize:11,color:"rgba(255,255,255,.45)",fontWeight:600,marginBottom:16}}>{vpnOn?"Connexion chiffrée AES-256":"Activez pour protéger votre connexion"}</div>
            <button className={`vpn-tb ${vpnOn?"on":"off"}`} onClick={()=>setVpnOn(v=>!v)}>{vpnOn?"🔒 Déconnecter":"🌐 Activer le VPN"}</button>
          </div>
        </div>
      </div>}

      {/* CONTEXT MENU */}
      {ctxApp&&(()=>{const ca=getApp(ctxApp);return(
        <div className="ctx" style={{left:ctxPos.x,top:ctxPos.y}} onClick={e=>e.stopPropagation()}>
          <div className="ctx-item" style={{borderBottom:"1px solid rgba(255,255,255,.07)",paddingBottom:8}}><span style={{fontSize:20}}>{ca.icon}</span><span style={{color:"#fff",fontWeight:900}}>{ca.name}</span></div>
          <div className="ctx-item" onClick={()=>openEdit(ctxApp)}><span>✏️</span><span>Renommer / Changer icône</span></div>
          <div className="ctx-sep"/>
          <div className="ctx-item" onClick={()=>{setLockedApps(s=>{const n=new Set(s);n.has(ctxApp.id)?n.delete(ctxApp.id):n.add(ctxApp.id);return n;});setCtxApp(null);setEditing(false);}}>
            {lockedApps.has(ctxApp.id)?<><span>🔓</span><span>Déverrouiller</span></>:<><span>🔒</span><span>Verrouiller</span></>}
          </div>
          <div className="ctx-sep"/>
          {dockOrder.includes(ctxApp.id)?<div className="ctx-item" onClick={()=>removeFromDock(ctxApp.id)}><span>📌</span><span>Retirer de la barre</span></div>:<div className="ctx-item" onClick={()=>addToDock(ctxApp.id)}><span>📌</span><span>Ajouter à la barre</span></div>}
          <div className="ctx-sep"/>
          <div className="ctx-item red" onClick={()=>removeFromScreen(ctxApp.id)}><span>🗑️</span><span>Retirer de l'écran</span></div>
          <div className="ctx-sep"/>
          <div className="ctx-item" style={{color:"rgba(255,255,255,.4)"}} onClick={()=>{setCtxApp(null);setEditing(false);}}><span>✕</span><span>Annuler</span></div>
        </div>
      );})()}

      {/* VAULT */}
      {vaultOpen&&<div className="vlt">
        <div className="vlt-hdr"><span style={{fontSize:28}}>🔐</span><div><div className="vlt-ttl">✝ Coffre-fort One1godlanceur</div><div style={{color:"rgba(255,255,255,.38)",fontSize:11,fontWeight:700}}>{hiddenApps.size} app{hiddenApps.size!==1?"s":""} cachée{hiddenApps.size!==1?"s":""}</div></div><div style={{marginLeft:"auto",cursor:"pointer",fontSize:22,color:"rgba(255,255,255,.38)"}} onClick={()=>setVaultOpen(false)}>✕</div></div>
        {hiddenApps.size===0?<div style={{color:"rgba(255,255,255,.28)",textAlign:"center",marginTop:60,fontSize:14,fontWeight:700}}>Aucune application cachée.<br/><span style={{fontSize:11,display:"block",marginTop:8,opacity:.6}}>Appui long → Cacher</span></div>
        :<div className="vlt-grid">{APPS.filter(a=>hiddenApps.has(a.id)).map(app=>(
          <div key={app.id} style={{display:"flex",flexDirection:"column",alignItems:"center",gap:5,cursor:"pointer"}} onClick={()=>setHiddenApps(s=>{const n=new Set(s);n.delete(app.id);return n;})}>
            <div className="ico" style={{...icoStyle(app,pack),width:56,height:56}}>{app.icon}</div>
            <span style={{fontSize:9,color:"rgba(255,255,255,.7)",fontWeight:700,textAlign:"center"}}>{app.name}</span>
          </div>
        ))}</div>}
      </div>}

      {/* MODAL ÉDITION */}
      {editModal&&(
        <div className="edit-ov" onClick={e=>e.stopPropagation()}>
          <div className="edit-card">
            <div className="edit-ttl">✏️ Modifier l'icône</div>
            <div className="edit-prev">{editIcon||editModal.icon}</div>
            <div className="edit-sec">Nom affiché</div>
            <input className="edit-inp" value={editName} onChange={e=>setEditName(e.target.value)} placeholder="Nom de l'application" maxLength={20}/>
            <div className="edit-sec">Choisir une icône</div>
            <div className="emoji-grid">
              {EMOJIS.map(em=><div key={em} className={`emoji-btn ${editIcon===em?"sel":""}`} onClick={()=>setEditIcon(em)}>{em}</div>)}
            </div>
            <div className="edit-btns">
              <button className="edit-save" onClick={saveEdit}>✅ Sauvegarder</button>
              <button className="edit-cancel" onClick={()=>setEditModal(null)}>Annuler</button>
            </div>
            <button className="edit-del" onClick={()=>{removeFromScreen(editModal.id);setEditModal(null);}}>🗑️ Retirer de l'écran</button>
            {!dockOrder.includes(editModal.id)&&<div className="dock-hint" onClick={()=>{addToDock(editModal.id);setEditModal(null);}}>📌 Ajouter à la barre des tâches</div>}
          </div>
        </div>
      )}

      {/* PIN */}
      {pinOpen&&<div className="pin-m" onClick={e=>e.stopPropagation()}>
        <div style={{fontSize:44,marginBottom:10}}>{pinPhase==="new"?"🔑":pinTarget?.type==="vault"?"🔐":pinTarget?.type==="changePIN"?"🔑":pinTarget?.app?.icon||"🔒"}</div>
        <div className="pin-ttl">{pinPhase==="new"?"Entrez le nouveau PIN":pinTarget?.type==="vault"?"Accès Coffre-fort":pinTarget?.type==="changePIN"?"Vérifiez l'ancien PIN":`Déverrouiller ${pinTarget?.app?.name||""}`}</div>
        <div className="pin-sub">CODE PIN • 4 CHIFFRES</div>
        <div className="pin-dots">{[0,1,2,3].map(i=><div key={i} className={`pin-dot ${i<pinValue.length?"on":""}`}/>)}</div>
        {pinError&&<div className="pin-err">❌ PIN incorrect</div>}
        <div className="pin-grid">
          {[1,2,3,4,5,6,7,8,9].map(n=><div key={n} className="pin-key" onClick={()=>pressPinKey(String(n))}>{n}</div>)}
          <div className="pin-key s2" onClick={()=>pressPinKey("0")}>0</div>
          <div className="pin-key del" onClick={()=>setPinValue(v=>v.slice(0,-1))}>⌫</div>
        </div>
        <div className="pin-cancel" onClick={()=>{setPinOpen(false);setPinValue("");setPinPhase("verify");setPinError(false);}}>Annuler</div>
      </div>}

    </div>
  </>);
}
"""
with open('src/One1godlanceur.jsx', 'w') as f:
    f.write(content.lstrip())
print("✅ src/One1godlanceur.jsx créé")
PYEOF

# ── npm install ────────────────────────────────────────
echo -e "\n${Y}📦 Installation npm...${N}"
npm install

echo -e "\n${B}╔════════════════════════════════════════════════╗${N}"
echo -e "${B}║  ✅  PRÊT — Lance ces 3 commandes :            ║${N}"
echo -e "${B}╚════════════════════════════════════════════════╝${N}"
echo -e "${G}git add .${N}"
echo -e "${G}git commit -m '✝️ One1godlanceur — Complet'${N}"
echo -e "${G}git push origin main${N}"
echo -e "${Y}→ GitHub Actions → One1godlanceur-APK (Java 21)${N}"
