#!/bin/bash
# ╔══════════════════════════════════════════════════════════╗
# ║   ONE1GODLANCEUR — KOTLIN NATIF — Setup Complet         ║
# ║   Lance dans Codespaces : chmod +x setup_kotlin.sh      ║
# ║   puis ./setup_kotlin.sh                                ║
# ╚══════════════════════════════════════════════════════════╝
set -e
G='\033[0;32m'; B='\033[0;34m'; Y='\033[1;33m'; N='\033[0m'
echo -e "${B}╔══════════════════════════════════════════════╗${N}"
echo -e "${B}║  🚀 ONE1GODLANCEUR — KOTLIN NATIF           ║${N}"
echo -e "${B}╚══════════════════════════════════════════════╝${N}"

mkdir -p .github/workflows
mkdir -p app/src/main/java/com/one1god/lanceur
mkdir -p app/src/main/res/{layout,drawable,values,font}
mkdir -p gradle/wrapper

# ── settings.gradle.kts ───────────────────────────────────
cat > settings.gradle.kts << 'EOF'
pluginManagement {
    repositories { google(); mavenCentral(); gradlePluginPortal() }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories { google(); mavenCentral() }
}
rootProject.name = "One1godlanceur"
include(":app")
EOF
echo -e "${G}✅ settings.gradle.kts${N}"

# ── build.gradle.kts (root) ───────────────────────────────
cat > build.gradle.kts << 'EOF'
plugins {
    id("com.android.application") version "8.3.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
}
EOF
echo -e "${G}✅ build.gradle.kts${N}"

# ── app/build.gradle.kts ──────────────────────────────────
cat > app/build.gradle.kts << 'EOF'
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}
android {
    namespace = "com.one1god.lanceur"
    compileSdk = 34
    defaultConfig {
        applicationId = "com.one1god.lanceur"
        minSdk = 26
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }
    buildTypes { release { isMinifyEnabled = false } }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }
    buildFeatures { viewBinding = true }
}
dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("com.google.android.material:material:1.12.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    implementation("androidx.viewpager2:viewpager2:1.1.0")
    implementation("androidx.recyclerview:recyclerview:1.3.2")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.6")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")
    implementation("com.google.code.gson:gson:2.10.1")
}
EOF
echo -e "${G}✅ app/build.gradle.kts${N}"

# ── gradle wrapper ─────────────────────────────────────────
cat > gradle/wrapper/gradle-wrapper.properties << 'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.4-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF
echo -e "${G}✅ gradle-wrapper.properties${N}"

# ── .gitignore ─────────────────────────────────────────────
cat > .gitignore << 'EOF'
*.iml
.gradle
/local.properties
/.idea
.DS_Store
/build
/captures
.externalNativeBuild
.cxx
local.properties
EOF
echo -e "${G}✅ .gitignore${N}"

# ── AndroidManifest.xml ────────────────────────────────────
cat > app/src/main/AndroidManifest.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.SET_WALLPAPER"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.CALL_PHONE"/>
    <uses-permission android:name="android.permission.SEND_SMS"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.QUERY_ALL_PACKAGES"
        tools:ignore="QueryAllPackagesPermission"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>

    <queries>
        <intent>
            <action android:name="android.intent.action.MAIN"/>
            <category android:name="android.intent.category.LAUNCHER"/>
        </intent>
    </queries>

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:theme="@style/Theme.One1godlanceur">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTask"
            android:stateNotNeeded="true"
            android:screenOrientation="portrait">
            <intent-filter android:priority="1">
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.HOME"/>
                <category android:name="android.intent.category.DEFAULT"/>
            </intent-filter>
        </activity>

        <activity
            android:name=".OnboardingActivity"
            android:exported="false"
            android:screenOrientation="portrait"/>

    </application>
</manifest>
EOF
echo -e "${G}✅ AndroidManifest.xml${N}"

# ── Kotlin source files via Python ─────────────────────────
echo -e "${Y}📝 Création des fichiers Kotlin...${N}"
python3 << 'PYEOF'
import os

SRC = "app/src/main/java/com/one1god/lanceur"
RES = "app/src/main/res"

# ══ AppInfo.kt ══════════════════════════════════════════════
with open(f"{SRC}/AppInfo.kt", "w") as f:
    f.write("""package com.one1god.lanceur
import android.graphics.drawable.Drawable
data class AppInfo(
    val packageName: String,
    val appName: String,
    var customName: String = appName,
    val icon: Drawable,
    var isLocked: Boolean = false,
    var isHidden: Boolean = false
)
""")
print("✅ AppInfo.kt")

# ══ PrefsHelper.kt ══════════════════════════════════════════
with open(f"{SRC}/PrefsHelper.kt", "w") as f:
    f.write("""package com.one1god.lanceur
import android.content.Context
import android.content.SharedPreferences
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

class PrefsHelper(context: Context) {
    private val p: SharedPreferences =
        context.getSharedPreferences("o1g", Context.MODE_PRIVATE)
    private val g = Gson()

    var transitionType: String
        get() = p.getString("trans","cube") ?: "cube"
        set(v) = p.edit().putString("trans",v).apply()

    var storedPin: String
        get() = p.getString("pin","") ?: ""
        set(v) = p.edit().putString("pin",v).apply()

    var onboardingDone: Boolean
        get() = p.getBoolean("ob",false)
        set(v) = p.edit().putBoolean("ob",v).apply()

    var adsBlockEnabled: Boolean
        get() = p.getBoolean("ads",true)
        set(v) = p.edit().putBoolean("ads",v).apply()

    var chargeLimitEnabled: Boolean
        get() = p.getBoolean("charge",true)
        set(v) = p.edit().putBoolean("charge",v).apply()

    var gridCols: Int
        get() = p.getInt("cols",4)
        set(v) = p.edit().putInt("cols",v).apply()

    var lockedApps: Set<String>
        get() = p.getStringSet("locked", emptySet()) ?: emptySet()
        set(v) = p.edit().putStringSet("locked",v).apply()

    var hiddenApps: Set<String>
        get() = p.getStringSet("hidden", emptySet()) ?: emptySet()
        set(v) = p.edit().putStringSet("hidden",v).apply()

    var customNames: Map<String,String>
        get() {
            val json = p.getString("names","{}") ?: "{}"
            return g.fromJson(json, object : TypeToken<Map<String,String>>(){}.type)
        }
        set(v) = p.edit().putString("names",g.toJson(v)).apply()

    var dockPackages: List<String>
        get() {
            val json = p.getString("dock",null) ?: return listOf(
                "com.android.dialer","com.android.messaging",
                "com.android.chrome","com.android.camera2")
            return g.fromJson(json, object : TypeToken<List<String>>(){}.type)
        }
        set(v) = p.edit().putString("dock",g.toJson(v)).apply()

    var appOrder: List<String>
        get() {
            val json = p.getString("order",null) ?: return emptyList()
            return g.fromJson(json, object : TypeToken<List<String>>(){}.type)
        }
        set(v) = p.edit().putString("order",g.toJson(v)).apply()
}
""")
print("✅ PrefsHelper.kt")

# ══ AppLoader.kt ════════════════════════════════════════════
with open(f"{SRC}/AppLoader.kt", "w") as f:
    f.write("""package com.one1god.lanceur
import android.content.Context
import android.content.Intent
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

object AppLoader {
    suspend fun loadApps(ctx: Context, prefs: PrefsHelper): List<AppInfo> =
        withContext(Dispatchers.IO) {
            val pm = ctx.packageManager
            val intent = Intent(Intent.ACTION_MAIN,null).apply {
                addCategory(Intent.CATEGORY_LAUNCHER)
            }
            val list = pm.queryIntentActivities(intent,0)
            val locked  = prefs.lockedApps
            val hidden  = prefs.hiddenApps
            val names   = prefs.customNames
            val order   = prefs.appOrder
            val apps = list
                .filter { it.activityInfo.packageName != ctx.packageName }
                .map { ri ->
                    AppInfo(
                        packageName = ri.activityInfo.packageName,
                        appName     = ri.loadLabel(pm).toString(),
                        customName  = names[ri.activityInfo.packageName]
                            ?: ri.loadLabel(pm).toString(),
                        icon        = ri.loadIcon(pm),
                        isLocked    = ri.activityInfo.packageName in locked,
                        isHidden    = ri.activityInfo.packageName in hidden
                    )
                }
                .sortedBy { it.customName.lowercase() }
            if (order.isEmpty()) return@withContext apps
            val orderMap = order.withIndex().associate { it.value to it.index }
            apps.sortedBy { orderMap[it.packageName] ?: Int.MAX_VALUE }
        }

    fun launch(ctx: Context, pkg: String) {
        ctx.packageManager.getLaunchIntentForPackage(pkg)?.let {
            it.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            ctx.startActivity(it)
        }
    }
}
""")
print("✅ AppLoader.kt")

# ══ Transformers.kt ═════════════════════════════════════════
with open(f"{SRC}/Transformers.kt", "w") as f:
    f.write("""package com.one1god.lanceur
import android.view.View
import androidx.viewpager2.widget.ViewPager2
import kotlin.math.abs

class SlideTransformer : ViewPager2.PageTransformer {
    override fun transformPage(v: View, p: Float) {}
}

class CubeTransformer : ViewPager2.PageTransformer {
    override fun transformPage(v: View, p: Float) {
        v.cameraDistance = v.width * 20f
        v.pivotY = v.height / 2f
        when {
            p < -1 -> v.alpha = 0f
            p <= 0 -> { v.alpha=1f; v.pivotX=v.width.toFloat(); v.rotationY=90f*p }
            p <= 1 -> { v.alpha=1f; v.pivotX=0f; v.rotationY=90f*p }
            else   -> v.alpha = 0f
        }
    }
}

class OrbitalTransformer : ViewPager2.PageTransformer {
    override fun transformPage(v: View, p: Float) {
        val a = abs(p)
        v.alpha    = 1f - a
        v.scaleX   = maxOf(0.05f, 1f - a)
        v.scaleY   = v.scaleX
        v.rotation = p * -360f
    }
}

class FlipTransformer : ViewPager2.PageTransformer {
    override fun transformPage(v: View, p: Float) {
        v.cameraDistance = v.width * 15f
        v.pivotX = v.width / 2f; v.pivotY = v.height / 2f
        when {
            p < -1 -> v.alpha = 0f
            p <= 0 -> { v.alpha=1f+p*2; v.rotationX=-180f*p }
            p <= 1 -> { v.alpha=1f-p*2; v.rotationX=-180f*p }
            else   -> v.alpha = 0f
        }
    }
}

class VortexTransformer : ViewPager2.PageTransformer {
    override fun transformPage(v: View, p: Float) {
        val a=abs(p); v.pivotX=v.width/2f; v.pivotY=v.height/2f
        v.alpha=1f-a; v.rotation=p*-270f
        v.scaleX=maxOf(0.05f,1f-a); v.scaleY=v.scaleX
    }
}

class PortalTransformer : ViewPager2.PageTransformer {
    override fun transformPage(v: View, p: Float) {
        val a=abs(p); v.pivotX=v.width/2f; v.pivotY=v.height/2f
        v.alpha=1f-a; v.scaleX=maxOf(0.05f,1f-a); v.scaleY=v.scaleX
        v.translationX=-p*v.width
    }
}

class ShatterTransformer : ViewPager2.PageTransformer {
    override fun transformPage(v: View, p: Float) {
        val a=abs(p); v.pivotX=v.width/2f; v.pivotY=v.height/2f; v.alpha=1f-a
        if(p<0){ v.scaleX=1f+a*1.5f; v.scaleY=v.scaleX }
        else { v.scaleX=maxOf(0.05f,1f-a*0.95f); v.scaleY=v.scaleX }
    }
}

class HelixTransformer : ViewPager2.PageTransformer {
    override fun transformPage(v: View, p: Float) {
        val a=abs(p); v.cameraDistance=v.width*15f
        v.pivotX=v.width/2f; v.pivotY=v.height/2f
        v.alpha=1f-a; v.rotationX=p*90f; v.scaleX=maxOf(0.3f,1f-a*0.7f)
    }
}

class GlitchTransformer : ViewPager2.PageTransformer {
    private var s=0
    override fun transformPage(v: View, p: Float) {
        val a=abs(p); if(a<0.01f){v.translationX=0f;v.alpha=1f;return}
        s=(s+1)%6
        v.translationX = when(s){0->-24f*a;1->20f*a;2->-12f*a;3->8f*a;4->-4f*a;else->0f}
        v.alpha=1f-a*0.5f
    }
}

class RippleTransformer : ViewPager2.PageTransformer {
    override fun transformPage(v: View, p: Float) {
        val a=abs(p); v.pivotX=v.width/2f; v.pivotY=v.height/2f; v.alpha=1f-a
        if(p<0){v.scaleX=1f+a*0.5f;v.scaleY=v.scaleX}
        else{v.scaleX=maxOf(0.1f,1f-a*0.9f);v.scaleY=v.scaleX}
    }
}

class FoldTransformer : ViewPager2.PageTransformer {
    override fun transformPage(v: View, p: Float) {
        v.cameraDistance=v.width*25f; val a=abs(p); v.alpha=1f-a
        if(p<=0){v.pivotX=v.width.toFloat();v.pivotY=v.height/2f;v.rotationY=90f*a;v.translationX=-v.width*a}
        else    {v.pivotX=0f;v.pivotY=v.height/2f;v.rotationY=-90f*a;v.translationX=v.width*a}
    }
}

// ══ FEUILLETAGE — Effet livre physique avant/arrière ═══════
class BookTransformer : ViewPager2.PageTransformer {
    override fun transformPage(v: View, p: Float) {
        v.cameraDistance = v.width * 30f
        val a = abs(p)
        when {
            p < -1 || p > 1 -> v.alpha = 0f
            p <= 0 -> {
                // Page qui part — tourne comme une page de livre
                v.alpha = 1f - a * 0.6f
                v.pivotX = v.width.toFloat()
                v.pivotY = v.height / 2f
                v.rotationY = 80f * a
                v.scaleX = 1f - a * 0.15f
                v.scaleY = 1f - a * 0.05f
                v.translationX = -v.width * a * 0.25f
            }
            else -> {
                // Nouvelle page — arrive depuis la reliure
                v.alpha = 1f - a * 0.4f
                v.pivotX = 0f
                v.pivotY = v.height / 2f
                v.rotationY = -80f * a
                v.scaleX = 1f - a * 0.15f
                v.scaleY = 1f - a * 0.05f
                v.translationX = v.width * a * 0.25f
            }
        }
    }
}

object TransitionFactory {
    val ALL = listOf(
        "slide" to "Glissement",   "cube"    to "Cube 3D",
        "orbital" to "Orbital",    "flip"    to "Flip",
        "vortex" to "Vortex",      "portal"  to "Portail",
        "shatter" to "Fracas",     "helix"   to "Hélix",
        "glitch" to "Glitch",      "ripple"  to "Vague",
        "fold" to "Pliage",        "book"    to "Feuilletage",
        "random" to "Aléatoire"
    )
    fun get(id: String): ViewPager2.PageTransformer {
        val t = if(id=="random") ALL.filter{it.first!="random"}.random().first else id
        return when(t){
            "slide"   -> SlideTransformer()
            "cube"    -> CubeTransformer()
            "orbital" -> OrbitalTransformer()
            "flip"    -> FlipTransformer()
            "vortex"  -> VortexTransformer()
            "portal"  -> PortalTransformer()
            "shatter" -> ShatterTransformer()
            "helix"   -> HelixTransformer()
            "glitch"  -> GlitchTransformer()
            "ripple"  -> RippleTransformer()
            "fold"    -> FoldTransformer()
            "book"    -> BookTransformer()
            else      -> CubeTransformer()
        }
    }
}
""")
print("✅ Transformers.kt (12 transitions + Feuilletage)")

# ══ IconAdapter.kt ══════════════════════════════════════════
with open(f"{SRC}/IconAdapter.kt", "w") as f:
    f.write("""package com.one1god.lanceur
import android.view.*
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView

class IconAdapter(
    private var apps: MutableList<AppInfo>,
    private val onClick: (AppInfo) -> Unit,
    private val onLongClick: (AppInfo, View) -> Unit
) : RecyclerView.Adapter<IconAdapter.VH>() {

    inner class VH(v: View) : RecyclerView.ViewHolder(v) {
        val icon: ImageView = v.findViewById(R.id.app_icon)
        val name: TextView  = v.findViewById(R.id.app_name)
    }

    override fun onCreateViewHolder(p: ViewGroup, vt: Int): VH {
        return VH(LayoutInflater.from(p.context).inflate(R.layout.item_app_icon,p,false))
    }

    override fun onBindViewHolder(h: VH, pos: Int) {
        val app = apps[pos]
        h.icon.setImageDrawable(app.icon)
        h.name.text = app.customName
        h.itemView.setOnClickListener { onClick(app) }
        h.itemView.setOnLongClickListener { onLongClick(app,it); true }
        h.itemView.setOnTouchListener { v, e ->
            when(e.action) {
                MotionEvent.ACTION_DOWN -> v.animate().scaleX(.85f).scaleY(.85f).setDuration(80).start()
                MotionEvent.ACTION_UP,
                MotionEvent.ACTION_CANCEL -> v.animate().scaleX(1f).scaleY(1f).setDuration(120).start()
            }
            false
        }
    }

    override fun getItemCount() = apps.size

    fun setApps(list: List<AppInfo>) { apps.clear(); apps.addAll(list); notifyDataSetChanged() }
    fun moveItem(from: Int, to: Int) {
        val item = apps.removeAt(from); apps.add(to,item); notifyItemMoved(from,to)
    }
}
""")
print("✅ IconAdapter.kt")

# ══ DrawerAdapter.kt ════════════════════════════════════════
with open(f"{SRC}/DrawerAdapter.kt", "w") as f:
    f.write("""package com.one1god.lanceur
import android.view.*
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView

class DrawerAdapter(
    private var apps: List<AppInfo>,
    private val onClick: (AppInfo) -> Unit,
    private val onLongClick: (AppInfo, View) -> Unit
) : RecyclerView.Adapter<DrawerAdapter.VH>() {

    inner class VH(v: View) : RecyclerView.ViewHolder(v) {
        val icon: ImageView = v.findViewById(R.id.app_icon)
        val name: TextView  = v.findViewById(R.id.app_name)
    }

    override fun onCreateViewHolder(p: ViewGroup, vt: Int): VH {
        return VH(LayoutInflater.from(p.context).inflate(R.layout.item_app_icon,p,false))
    }

    override fun onBindViewHolder(h: VH, pos: Int) {
        val app = apps[pos]
        h.icon.setImageDrawable(app.icon)
        h.name.text = app.customName
        h.itemView.setOnClickListener { onClick(app) }
        h.itemView.setOnLongClickListener { onLongClick(app,it); true }
        h.itemView.setOnTouchListener { v, e ->
            when(e.action) {
                MotionEvent.ACTION_DOWN -> v.animate().scaleX(.85f).scaleY(.85f).setDuration(80).start()
                MotionEvent.ACTION_UP,
                MotionEvent.ACTION_CANCEL -> v.animate().scaleX(1f).scaleY(1f).setDuration(120).start()
            }
            false
        }
    }

    override fun getItemCount() = apps.size
    fun setApps(list: List<AppInfo>) { apps = list; notifyDataSetChanged() }
}
""")
print("✅ DrawerAdapter.kt")

# ══ MainActivity.kt ═════════════════════════════════════════
with open(f"{SRC}/MainActivity.kt", "w") as f:
    f.write("""package com.one1god.lanceur

import android.content.*
import android.os.*
import android.text.Editable
import android.text.TextWatcher
import android.view.*
import android.widget.*
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.WindowCompat
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.*
import androidx.viewpager2.widget.ViewPager2
import com.google.android.material.bottomsheet.BottomSheetBehavior
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.google.android.material.snackbar.Snackbar
import kotlinx.coroutines.launch

class MainActivity : AppCompatActivity() {

    private lateinit var prefs: PrefsHelper
    private var allApps = mutableListOf<AppInfo>()

    private lateinit var rootView: FrameLayout
    private lateinit var viewPager: ViewPager2
    private lateinit var dotsContainer: LinearLayout
    private lateinit var dockContainer: LinearLayout
    private lateinit var clockText: TextView
    private lateinit var dateText: TextView
    private lateinit var brandText: TextView

    private val clockHandler = Handler(Looper.getMainLooper())
    private var clockRunnable: Runnable? = null
    private val PAGE_SIZE = 20

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        prefs = PrefsHelper(this)
        WindowCompat.setDecorFitsSystemWindows(window, false)
        window.statusBarColor = android.graphics.Color.TRANSPARENT
        window.navigationBarColor = android.graphics.Color.TRANSPARENT
        setContentView(R.layout.activity_main)

        if (!prefs.onboardingDone) {
            startActivity(Intent(this, OnboardingActivity::class.java))
        }

        initViews()
        startClock()
        loadApps()

        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_PACKAGE_ADDED)
            addAction(Intent.ACTION_PACKAGE_REMOVED)
            addDataScheme("package")
        }
        registerReceiver(packageReceiver, filter)
    }

    private fun initViews() {
        rootView      = findViewById(R.id.root_view)
        viewPager     = findViewById(R.id.view_pager)
        dotsContainer = findViewById(R.id.dots_container)
        dockContainer = findViewById(R.id.dock_container)
        clockText     = findViewById(R.id.clock_text)
        dateText      = findViewById(R.id.date_text)
        brandText     = findViewById(R.id.brand_text)
        brandText.text = "✝ ONE1GODLANCEUR ✝"

        findViewById<View>(R.id.home_pill).setOnClickListener { openDrawer() }
        findViewById<View>(R.id.fab_settings).setOnClickListener { openSettings() }
    }

    private fun startClock() {
        clockRunnable = object : Runnable {
            override fun run() {
                val now = java.util.Calendar.getInstance()
                val h = String.format("%02d", now.get(java.util.Calendar.HOUR_OF_DAY))
                val m = String.format("%02d", now.get(java.util.Calendar.MINUTE))
                clockText.text = "$h:$m"
                try {
                    val fmt = android.icu.text.SimpleDateFormat("EEEE d MMMM", java.util.Locale.FRENCH)
                    dateText.text = fmt.format(now.time).uppercase()
                } catch (e: Exception) { dateText.text = "" }
                clockHandler.postDelayed(this, 1000)
            }
        }
        clockHandler.post(clockRunnable!!)
    }

    private fun loadApps() {
        lifecycleScope.launch {
            allApps.clear()
            allApps.addAll(AppLoader.loadApps(applicationContext, prefs))
            setupViewPager()
            setupDock()
        }
    }

    // ══ VIEWPAGER2 ═══════════════════════════════════════════
    private fun setupViewPager() {
        val visible = allApps.filter { !it.isHidden }
        val pages   = visible.chunked(PAGE_SIZE)
        if (pages.isEmpty()) return

        val pageAdapters = pages.map { pageApps ->
            IconAdapter(
                pageApps.toMutableList(),
                onClick      = { app -> handleAppClick(app) },
                onLongClick  = { app, view -> showContextMenu(app, view) }
            )
        }

        val pagerAdapter = object : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
            override fun getItemCount() = pages.size
            override fun onCreateViewHolder(parent: ViewGroup, vt: Int): RecyclerView.ViewHolder {
                val rv = RecyclerView(parent.context).apply {
                    layoutManager = GridLayoutManager(parent.context, prefs.gridCols)
                    clipToPadding = false
                    setPadding(12, 8, 12, 8)
                }
                return object : RecyclerView.ViewHolder(rv) {}
            }
            override fun onBindViewHolder(h: RecyclerView.ViewHolder, pos: Int) {
                (h.itemView as RecyclerView).adapter = pageAdapters[pos]
            }
        }

        viewPager.adapter = pagerAdapter
        viewPager.setPageTransformer(TransitionFactory.get(prefs.transitionType))

        setupDots(pages.size)
        viewPager.registerOnPageChangeCallback(object : ViewPager2.OnPageChangeCallback() {
            override fun onPageSelected(position: Int) = updateDots(position)
        })
    }

    private fun setupDots(count: Int) {
        dotsContainer.removeAllViews()
        if (count <= 1) return
        repeat(count) { i ->
            val dot = View(this).apply {
                layoutParams = LinearLayout.LayoutParams(
                    if(i==0) 56 else 20, 20
                ).also { it.setMargins(6,0,6,0) }
                setBackgroundResource(if(i==0) R.drawable.dot_active else R.drawable.dot_inactive)
            }
            dotsContainer.addView(dot)
        }
    }

    private fun updateDots(sel: Int) {
        for (i in 0 until dotsContainer.childCount) {
            val dot = dotsContainer.getChildAt(i)
            val lp  = dot.layoutParams as LinearLayout.LayoutParams
            lp.width = if(i==sel) 56 else 20
            dot.layoutParams = lp
            dot.setBackgroundResource(if(i==sel) R.drawable.dot_active else R.drawable.dot_inactive)
        }
    }

    // ══ DOCK ═════════════════════════════════════════════════
    private fun setupDock() {
        dockContainer.removeAllViews()
        prefs.dockPackages
            .mapNotNull { pkg -> allApps.find { it.packageName == pkg } }
            .take(5)
            .forEach { app ->
                val v = layoutInflater.inflate(R.layout.item_app_icon, dockContainer, false)
                v.findViewById<ImageView>(R.id.app_icon).setImageDrawable(app.icon)
                v.findViewById<TextView>(R.id.app_name).text = app.customName
                v.setOnClickListener { handleAppClick(app) }
                v.setOnLongClickListener { showContextMenu(app, it); true }
                v.setOnTouchListener { view, e ->
                    when(e.action) {
                        MotionEvent.ACTION_DOWN -> view.animate().scaleX(.82f).scaleY(.82f).setDuration(80).start()
                        MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL ->
                            view.animate().scaleX(1f).scaleY(1f).setDuration(120).start()
                    }
                    false
                }
                val lp = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
                dockContainer.addView(v, lp)
            }
    }

    // ══ APP CLICK ════════════════════════════════════════════
    private fun handleAppClick(app: AppInfo) {
        if (app.isLocked && prefs.storedPin.isNotEmpty()) {
            showPinDialog { AppLoader.launch(this, app.packageName) }
        } else {
            AppLoader.launch(this, app.packageName)
        }
    }

    // ══ CONTEXT MENU (appui long) ════════════════════════════
    private fun showContextMenu(app: AppInfo, anchor: View) {
        vibrate()
        val sheet = BottomSheetDialog(this, R.style.BottomSheetStyle)
        val v = layoutInflater.inflate(R.layout.sheet_context, null)
        sheet.setContentView(v)
        try { v.findViewById<ImageView>(R.id.ctx_icon).setImageDrawable(app.icon) } catch(_:Exception){}
        v.findViewById<TextView>(R.id.ctx_name).text = app.customName
        v.findViewById<TextView>(R.id.ctx_lock_lbl).text =
            if(app.isLocked) "🔓  Déverrouiller" else "🔒  Verrouiller"

        v.findViewById<View>(R.id.ctx_rename).setOnClickListener  { sheet.dismiss(); showRename(app) }
        v.findViewById<View>(R.id.ctx_lock).setOnClickListener    { sheet.dismiss(); toggleLock(app) }
        v.findViewById<View>(R.id.ctx_hide).setOnClickListener    { sheet.dismiss(); hideApp(app) }
        v.findViewById<View>(R.id.ctx_dock).setOnClickListener    { sheet.dismiss(); addToDock(app) }
        v.findViewById<View>(R.id.ctx_cancel).setOnClickListener  { sheet.dismiss() }
        sheet.show()
    }

    private fun toggleLock(app: AppInfo) {
        app.isLocked = !app.isLocked
        val s = prefs.lockedApps.toMutableSet()
        if(app.isLocked) s.add(app.packageName) else s.remove(app.packageName)
        prefs.lockedApps = s
        Snackbar.make(rootView, if(app.isLocked) "🔒 ${app.customName} verrouillée" else "🔓 Déverrouillée", 2000).show()
    }

    private fun hideApp(app: AppInfo) {
        app.isHidden = true
        val s = prefs.hiddenApps.toMutableSet(); s.add(app.packageName); prefs.hiddenApps = s
        loadApps()
        Snackbar.make(rootView,"👁️ ${app.customName} cachée dans le Vault",3000)
            .setAction("Annuler"){
                app.isHidden=false; val ns=prefs.hiddenApps.toMutableSet()
                ns.remove(app.packageName); prefs.hiddenApps=ns; loadApps()
            }.show()
    }

    private fun addToDock(app: AppInfo) {
        val d = prefs.dockPackages.toMutableList()
        if (!d.contains(app.packageName) && d.size < 5) {
            d.add(app.packageName); prefs.dockPackages = d; setupDock()
            Snackbar.make(rootView,"📌 ${app.customName} ajoutée à la barre",2000).show()
        }
    }

    private fun showRename(app: AppInfo) {
        val input = EditText(this).apply {
            setText(app.customName); selectAll()
            setTextColor(0xFFFFFFFF.toInt())
            setHintTextColor(0x66FFFFFF.toInt())
            setPadding(32,24,32,24)
        }
        AlertDialog.Builder(this, R.style.DarkDialog)
            .setTitle("✏️ Renommer")
            .setView(input)
            .setPositiveButton("Sauvegarder") { _,_ ->
                val n = input.text.toString().trim()
                if (n.isNotEmpty()) {
                    app.customName = n
                    val m = prefs.customNames.toMutableMap(); m[app.packageName]=n; prefs.customNames=m
                    loadApps()
                }
            }
            .setNegativeButton("Annuler", null).show()
    }

    // ══ APP DRAWER ═══════════════════════════════════════════
    private fun openDrawer() {
        val sheet = BottomSheetDialog(this, R.style.BottomSheetStyle)
        val v = layoutInflater.inflate(R.layout.sheet_drawer, null)
        sheet.setContentView(v)
        sheet.behavior.state = BottomSheetBehavior.STATE_EXPANDED

        val recycler = v.findViewById<RecyclerView>(R.id.drawer_recycler)
        val search   = v.findViewById<EditText>(R.id.drawer_search)
        var cols = prefs.gridCols
        val lm = GridLayoutManager(this, cols)
        recycler.layoutManager = lm

        val fullList = allApps.toList()
        var filtered = fullList

        val adapter = DrawerAdapter(
            filtered,
            onClick     = { app -> sheet.dismiss(); handleAppClick(app) },
            onLongClick = { app, av -> sheet.dismiss(); showContextMenu(app, av) }
        )
        recycler.adapter = adapter

        listOf(R.id.col3 to 3, R.id.col4 to 4, R.id.col5 to 5).forEach { (id, n) ->
            v.findViewById<View>(id).setOnClickListener {
                cols = n; lm.spanCount = n; adapter.notifyDataSetChanged()
            }
        }

        search.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {
                val q = s?.toString() ?: ""
                filtered = if(q.isEmpty()) fullList else fullList.filter{it.customName.contains(q,true)}
                adapter.setApps(filtered)
            }
            override fun beforeTextChanged(s: CharSequence?,start:Int,count:Int,after:Int){}
            override fun onTextChanged(s: CharSequence?,start:Int,before:Int,count:Int){}
        })

        v.findViewById<View>(R.id.vault_btn).setOnClickListener {
            sheet.dismiss()
            if(prefs.storedPin.isNotEmpty()) showPinDialog { openVault() } else openVault()
        }
        sheet.show()
    }

    // ══ VAULT ════════════════════════════════════════════════
    private fun openVault() {
        val sheet = BottomSheetDialog(this, R.style.BottomSheetStyle)
        val v = layoutInflater.inflate(R.layout.sheet_vault, null)
        sheet.setContentView(v)
        val rv = v.findViewById<RecyclerView>(R.id.vault_recycler)
        rv.layoutManager = GridLayoutManager(this, 4)
        val hidden = allApps.filter { it.isHidden }
        rv.adapter = DrawerAdapter(
            hidden,
            onClick = { app ->
                app.isHidden=false
                val s=prefs.hiddenApps.toMutableSet(); s.remove(app.packageName); prefs.hiddenApps=s
                sheet.dismiss(); loadApps()
                Snackbar.make(rootView,"✅ ${app.customName} restaurée",2000).show()
            },
            onLongClick = { _,_ -> }
        )
        sheet.show()
    }

    // ══ SETTINGS ═════════════════════════════════════════════
    private fun openSettings() {
        val sheet = BottomSheetDialog(this, R.style.BottomSheetStyle)
        val v = layoutInflater.inflate(R.layout.sheet_settings, null)
        sheet.setContentView(v)

        v.findViewById<View>(R.id.setting_wallpaper).setOnClickListener {
            startActivity(Intent.createChooser(Intent(Intent.ACTION_SET_WALLPAPER), "Fond d'écran"))
        }

        val group = v.findViewById<RadioGroup>(R.id.transition_group)
        TransitionFactory.ALL.forEach { (id, name) ->
            val rb = RadioButton(this).apply {
                text=name; tag=id
                setTextColor(0xFFFFFFFF.toInt())
                buttonTintList = android.content.res.ColorStateList.valueOf(0xFFD4AF37.toInt())
                if(id==prefs.transitionType) isChecked=true
            }
            group.addView(rb)
        }
        group.setOnCheckedChangeListener { g, cid ->
            g.findViewById<RadioButton>(cid)?.tag?.let {
                prefs.transitionType = it as String
                viewPager.setPageTransformer(TransitionFactory.get(it))
            }
        }

        val gridSp = v.findViewById<Spinner>(R.id.grid_cols_spinner)
        val opts = arrayOf("3 colonnes","4 colonnes","5 colonnes")
        gridSp.adapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, opts)
        gridSp.setSelection(prefs.gridCols-3)
        gridSp.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(p: AdapterView<*>?,v2: View?,pos: Int,id: Long) {
                prefs.gridCols=pos+3; loadApps()
            }
            override fun onNothingSelected(p: AdapterView<*>?){}
        }

        v.findViewById<View>(R.id.setting_pin).setOnClickListener { sheet.dismiss(); setupPin() }

        val adsSwitch = v.findViewById<Switch>(R.id.ads_switch)
        adsSwitch.isChecked = prefs.adsBlockEnabled
        adsSwitch.setOnCheckedChangeListener { _,c -> prefs.adsBlockEnabled=c }

        val chSwitch = v.findViewById<Switch>(R.id.charge_switch)
        chSwitch.isChecked = prefs.chargeLimitEnabled
        chSwitch.setOnCheckedChangeListener { _,c -> prefs.chargeLimitEnabled=c }

        sheet.show()
    }

    // ══ PIN ══════════════════════════════════════════════════
    private fun showPinDialog(onOk: () -> Unit) {
        val dialog = AlertDialog.Builder(this, R.style.DarkDialog)
        val v = layoutInflater.inflate(R.layout.dialog_pin, null)
        dialog.setView(v); val d = dialog.create(); d.show()
        val dots = listOf<View>(v.findViewById(R.id.dot1),v.findViewById(R.id.dot2),
            v.findViewById(R.id.dot3),v.findViewById(R.id.dot4))
        val err = v.findViewById<TextView>(R.id.pin_error)
        var pin = ""
        fun upd() { dots.forEachIndexed { i,dot -> dot.isSelected = i < pin.length } }
        listOf(R.id.k1,R.id.k2,R.id.k3,R.id.k4,R.id.k5,R.id.k6,R.id.k7,R.id.k8,R.id.k9,R.id.k0)
            .forEachIndexed { i, id ->
                val digit = if(i<9) (i+1).toString() else "0"
                v.findViewById<View>(id).setOnClickListener {
                    if(pin.length<4){ pin+=digit; upd()
                        if(pin.length==4) {
                            if(pin==prefs.storedPin){ d.dismiss(); onOk() }
                            else { err.text="❌ PIN incorrect"; pin=""; upd(); vibrate() }
                        }
                    }
                }
            }
        v.findViewById<View>(R.id.k_del).setOnClickListener { if(pin.isNotEmpty()){pin=pin.dropLast(1);upd()} }
        v.findViewById<View>(R.id.k_cancel).setOnClickListener { d.dismiss() }
    }

    private fun setupPin() {
        val d = AlertDialog.Builder(this,R.style.DarkDialog)
        val v = layoutInflater.inflate(R.layout.dialog_pin, null)
        d.setView(v); val dlg = d.create(); dlg.show()
        val dots = listOf<View>(v.findViewById(R.id.dot1),v.findViewById(R.id.dot2),
            v.findViewById(R.id.dot3),v.findViewById(R.id.dot4))
        val err = v.findViewById<TextView>(R.id.pin_error)
        err.text = "Entrez votre nouveau PIN"
        var pin=""; var phase="new"; var first=""
        fun upd() { dots.forEachIndexed{i,dot->dot.isSelected=i<pin.length} }
        listOf(R.id.k1,R.id.k2,R.id.k3,R.id.k4,R.id.k5,R.id.k6,R.id.k7,R.id.k8,R.id.k9,R.id.k0)
            .forEachIndexed { i,id ->
                val digit = if(i<9) (i+1).toString() else "0"
                v.findViewById<View>(id).setOnClickListener {
                    if(pin.length<4){ pin+=digit; upd()
                        if(pin.length==4){
                            if(phase=="new"){ first=pin;pin="";phase="confirm";err.text="Confirmez votre PIN";upd() }
                            else {
                                if(pin==first){ prefs.storedPin=pin;dlg.dismiss()
                                    Snackbar.make(rootView,"🔒 PIN configuré",2000).show()
                                } else { err.text="❌ PIN différent";pin="";phase="new";first="";upd();vibrate() }
                            }
                        }
                    }
                }
            }
        v.findViewById<View>(R.id.k_del).setOnClickListener{if(pin.isNotEmpty()){pin=pin.dropLast(1);upd()}}
        v.findViewById<View>(R.id.k_cancel).setOnClickListener{dlg.dismiss()}
    }

    // ══ UTILS ════════════════════════════════════════════════
    private fun vibrate() {
        (getSystemService(VIBRATOR_SERVICE) as? Vibrator)
            ?.vibrate(VibrationEffect.createOneShot(40,VibrationEffect.DEFAULT_AMPLITUDE))
    }

    private val packageReceiver = object : BroadcastReceiver() {
        override fun onReceive(ctx: Context?,i: Intent?) { loadApps() }
    }

    override fun onResume() { super.onResume(); loadApps() }
    override fun onBackPressed() { viewPager.currentItem = 0 }
    override fun onDestroy() {
        super.onDestroy()
        clockHandler.removeCallbacksAndMessages(null)
        unregisterReceiver(packageReceiver)
    }
}
""")
print("✅ MainActivity.kt")

# ══ OnboardingActivity.kt ═══════════════════════════════════
with open(f"{SRC}/OnboardingActivity.kt", "w") as f:
    f.write("""package com.one1god.lanceur
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.RecyclerView
import androidx.viewpager2.widget.ViewPager2

class OnboardingActivity : AppCompatActivity() {
    private lateinit var prefs: PrefsHelper
    data class Slide(val emoji:String,val title:String,val desc:String,val bg:Int)

    private val slides = listOf(
        Slide("🚀","One1godlanceur",
            "Le lanceur qui porte le nom de Dieu.\\nPuissant. Sécurisé. Époustouflant.\\n\\n✝ Jean 14:6",
            0xFF0F0C29.toInt()),
        Slide("📖","Feuilletage de Livre",
            "Parcourez vos pages d'applications\\ncomme un livre physique.\\n12 transitions époustouflantes\\ndont l'effet de feuilletage.",
            0xFF0A0A1A.toInt()),
        Slide("🛡️","Ta Sécurité",
            "Vault pour cacher des applications.\\nPIN pour les apps sensibles.\\nProtection batterie intégrée.",
            0xFF031A0F.toInt()),
        Slide("✝","Pour la Gloire de Dieu",
            "Ce lanceur est créé pour Sa gloire.\\nAlpha et Oméga.\\n\\n« Tout ce que vous faites,\\nfaites-le pour le Seigneur. »\\n— Colossiens 3:23",
            0xFF0C0A00.toInt()),
    )

    override fun onCreate(sb: Bundle?) {
        super.onCreate(sb)
        prefs = PrefsHelper(this)
        setContentView(R.layout.activity_onboarding)
        val vp    = findViewById<ViewPager2>(R.id.ob_pager)
        val next  = findViewById<Button>(R.id.btn_next)
        val skip  = findViewById<TextView>(R.id.btn_skip)
        val dots  = findViewById<LinearLayout>(R.id.ob_dots)

        vp.adapter = object : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
            override fun getItemCount() = slides.size
            override fun onCreateViewHolder(p: ViewGroup, vt: Int): RecyclerView.ViewHolder {
                val v = layoutInflater.inflate(R.layout.item_onboard_slide, p, false)
                return object : RecyclerView.ViewHolder(v) {}
            }
            override fun onBindViewHolder(h: RecyclerView.ViewHolder, pos: Int) {
                val s = slides[pos]
                h.itemView.setBackgroundColor(s.bg)
                h.itemView.findViewById<TextView>(R.id.ob_emoji).text = s.emoji
                h.itemView.findViewById<TextView>(R.id.ob_title).text = s.title
                h.itemView.findViewById<TextView>(R.id.ob_desc).text  = s.desc
            }
        }

        fun setupDots(sel:Int=0) {
            dots.removeAllViews()
            slides.forEachIndexed { i,_ ->
                val dot = View(this).apply {
                    layoutParams = LinearLayout.LayoutParams(if(i==sel)56 else 20,20).also{it.setMargins(6,0,6,0)}
                    setBackgroundResource(if(i==sel)R.drawable.dot_active else R.drawable.dot_inactive)
                }
                dots.addView(dot)
            }
        }
        setupDots()

        vp.registerOnPageChangeCallback(object : ViewPager2.OnPageChangeCallback() {
            override fun onPageSelected(pos: Int) {
                setupDots(pos)
                next.text = if(pos==slides.size-1) "🚀 Lancer One1godlanceur" else "Suivant →"
            }
        })
        next.setOnClickListener {
            if(vp.currentItem < slides.size-1) vp.currentItem++
            else { prefs.onboardingDone=true; finish() }
        }
        skip.setOnClickListener { prefs.onboardingDone=true; finish() }
    }
}
""")
print("✅ OnboardingActivity.kt")

print("\\n✅ Tous les fichiers Kotlin créés !")
PYEOF
echo -e "${G}✅ Fichiers Kotlin créés${N}"

# ── XML Layouts via Python ─────────────────────────────────
python3 << 'PYEOF'
RES = "app/src/main/res"

layouts = {}

layouts[f"{RES}/layout/activity_main.xml"] = '''<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/root_view"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="#000000">

    <androidx.viewpager2.widget.ViewPager2
        android:id="@+id/view_pager"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:layout_marginBottom="158dp"/>

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="52dp"
        android:orientation="vertical"
        android:gravity="center">
        <TextView android:id="@+id/clock_text"
            android:layout_width="wrap_content" android:layout_height="wrap_content"
            android:text="00:00" android:textSize="62sp" android:textColor="#FFFFFF"
            android:textStyle="bold" android:letterSpacing="-0.04"/>
        <TextView android:id="@+id/date_text"
            android:layout_width="wrap_content" android:layout_height="wrap_content"
            android:textSize="11sp" android:textColor="#99FFFFFF"
            android:textStyle="bold" android:letterSpacing="0.12"
            android:layout_marginTop="4dp"/>
        <TextView android:id="@+id/brand_text"
            android:layout_width="wrap_content" android:layout_height="wrap_content"
            android:textSize="9sp" android:textColor="#88D4AF37"
            android:textStyle="bold" android:letterSpacing="0.22"
            android:layout_marginTop="6dp"/>
    </LinearLayout>

    <LinearLayout android:id="@+id/dots_container"
        android:layout_width="wrap_content" android:layout_height="wrap_content"
        android:layout_gravity="bottom|center_horizontal"
        android:layout_marginBottom="164dp"
        android:orientation="horizontal" android:gravity="center"/>

    <LinearLayout
        android:layout_width="match_parent" android:layout_height="76dp"
        android:layout_gravity="bottom"
        android:layout_marginBottom="58dp"
        android:layout_marginHorizontal="14dp"
        android:background="@drawable/dock_background"
        android:orientation="horizontal"
        android:gravity="center_vertical" android:padding="6dp">
        <LinearLayout android:id="@+id/dock_container"
            android:layout_width="match_parent" android:layout_height="match_parent"
            android:orientation="horizontal" android:gravity="center"/>
    </LinearLayout>

    <View android:id="@+id/home_pill"
        android:layout_width="40dp" android:layout_height="5dp"
        android:layout_gravity="bottom|center_horizontal"
        android:layout_marginBottom="14dp"
        android:background="@drawable/pill_background"
        android:clickable="true" android:focusable="true"/>

    <ImageView android:id="@+id/fab_settings"
        android:layout_width="44dp" android:layout_height="44dp"
        android:layout_gravity="bottom|end"
        android:layout_marginEnd="14dp"
        android:layout_marginBottom="158dp"
        android:background="@drawable/fab_background"
        android:src="@drawable/ic_settings"
        android:padding="10dp"
        android:clickable="true" android:focusable="true"
        android:tint="#FFFFFF"/>
</FrameLayout>'''

layouts[f"{RES}/layout/item_app_icon.xml"] = '''<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:orientation="vertical"
    android:gravity="center"
    android:padding="6dp">
    <ImageView android:id="@+id/app_icon"
        android:layout_width="68dp" android:layout_height="68dp"
        android:scaleType="fitCenter"/>
    <TextView android:id="@+id/app_name"
        android:layout_width="wrap_content" android:layout_height="wrap_content"
        android:textSize="11sp" android:textColor="#FFFFFF"
        android:textStyle="bold" android:maxLines="1"
        android:ellipsize="end" android:maxWidth="76dp"
        android:layout_marginTop="4dp"
        android:shadowColor="#000000" android:shadowDx="0"
        android:shadowDy="1" android:shadowRadius="6"/>
</LinearLayout>'''

layouts[f"{RES}/layout/activity_onboarding.xml"] = '''<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:background="#000000">
    <androidx.viewpager2.widget.ViewPager2 android:id="@+id/ob_pager"
        android:layout_width="match_parent" android:layout_height="match_parent"/>
    <TextView android:id="@+id/btn_skip"
        android:layout_width="wrap_content" android:layout_height="wrap_content"
        android:text="Passer" android:textColor="#66FFFFFF"
        android:textSize="14sp" android:textStyle="bold"
        android:padding="16dp"
        android:layout_alignParentTop="true" android:layout_alignParentEnd="true"/>
    <LinearLayout android:id="@+id/ob_dots"
        android:layout_width="wrap_content" android:layout_height="wrap_content"
        android:layout_above="@+id/btn_next"
        android:layout_centerHorizontal="true"
        android:orientation="horizontal" android:layout_marginBottom="24dp"/>
    <Button android:id="@+id/btn_next"
        android:layout_width="match_parent" android:layout_height="56dp"
        android:layout_alignParentBottom="true"
        android:layout_marginHorizontal="28dp" android:layout_marginBottom="40dp"
        android:text="Suivant →" android:textSize="16sp"
        android:textStyle="bold" android:textColor="#000000"
        android:backgroundTint="#D4AF37" android:letterSpacing="0.05"/>
</RelativeLayout>'''

layouts[f"{RES}/layout/item_onboard_slide.xml"] = '''<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:orientation="vertical" android:gravity="center" android:padding="40dp">
    <TextView android:id="@+id/ob_emoji"
        android:layout_width="wrap_content" android:layout_height="wrap_content"
        android:textSize="72sp" android:layout_marginBottom="24dp"/>
    <TextView android:id="@+id/ob_title"
        android:layout_width="wrap_content" android:layout_height="wrap_content"
        android:textSize="26sp" android:textColor="#D4AF37"
        android:textStyle="bold" android:gravity="center"
        android:layout_marginBottom="16dp"/>
    <TextView android:id="@+id/ob_desc"
        android:layout_width="wrap_content" android:layout_height="wrap_content"
        android:textSize="14sp" android:textColor="#AAFFFFFF"
        android:gravity="center" android:lineSpacingMultiplier="1.65"/>
</LinearLayout>'''

layouts[f"{RES}/layout/sheet_drawer.xml"] = '''<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:orientation="vertical" android:background="#F5050516"
    android:paddingTop="12dp">
    <View android:layout_width="40dp" android:layout_height="4dp"
        android:layout_gravity="center" android:layout_marginBottom="12dp"
        android:background="@drawable/pill_background"/>
    <TextView android:layout_width="wrap_content" android:layout_height="wrap_content"
        android:layout_gravity="center"
        android:text="✝ ONE1GODLANCEUR"
        android:textColor="#66D4AF37" android:textStyle="bold"
        android:textSize="10sp" android:letterSpacing="0.2"
        android:layout_marginBottom="12dp"/>
    <EditText android:id="@+id/drawer_search"
        android:layout_width="match_parent" android:layout_height="48dp"
        android:layout_marginHorizontal="14dp" android:layout_marginBottom="10dp"
        android:hint="🔍  Rechercher..." android:textColor="#FFFFFF"
        android:textColorHint="#55FFFFFF" android:background="@drawable/search_background"
        android:paddingHorizontal="16dp" android:textSize="14sp" android:inputType="text"/>
    <LinearLayout android:layout_width="wrap_content" android:layout_height="wrap_content"
        android:layout_gravity="center" android:orientation="horizontal"
        android:layout_marginBottom="10dp">
        <Button android:id="@+id/col3"
            android:layout_width="56dp" android:layout_height="36dp"
            android:text="3" android:textColor="#FFFFFF" android:textSize="13sp"
            android:textStyle="bold" android:backgroundTint="#22FFFFFF"
            android:layout_marginHorizontal="4dp"/>
        <Button android:id="@+id/col4"
            android:layout_width="56dp" android:layout_height="36dp"
            android:text="4" android:textColor="#FFFFFF" android:textSize="13sp"
            android:textStyle="bold" android:backgroundTint="#22FFFFFF"
            android:layout_marginHorizontal="4dp"/>
        <Button android:id="@+id/col5"
            android:layout_width="56dp" android:layout_height="36dp"
            android:text="5" android:textColor="#FFFFFF" android:textSize="13sp"
            android:textStyle="bold" android:backgroundTint="#22FFFFFF"
            android:layout_marginHorizontal="4dp"/>
        <Button android:id="@+id/vault_btn"
            android:layout_width="wrap_content" android:layout_height="36dp"
            android:text="🔐 Vault" android:textColor="#D4AF37" android:textSize="13sp"
            android:textStyle="bold" android:backgroundTint="#22D4AF37"
            android:layout_marginStart="12dp"/>
    </LinearLayout>
    <androidx.recyclerview.widget.RecyclerView android:id="@+id/drawer_recycler"
        android:layout_width="match_parent" android:layout_height="0dp"
        android:layout_weight="1" android:paddingBottom="32dp" android:clipToPadding="false"/>
</LinearLayout>'''

layouts[f"{RES}/layout/sheet_context.xml"] = '''<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="wrap_content"
    android:orientation="vertical" android:background="#F0050516" android:padding="20dp">
    <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content"
        android:orientation="horizontal" android:gravity="center_vertical"
        android:layout_marginBottom="20dp">
        <ImageView android:id="@+id/ctx_icon"
            android:layout_width="48dp" android:layout_height="48dp"
            android:layout_marginEnd="14dp"/>
        <TextView android:id="@+id/ctx_name"
            android:layout_width="wrap_content" android:layout_height="wrap_content"
            android:textSize="18sp" android:textColor="#FFFFFF" android:textStyle="bold"/>
    </LinearLayout>
    <Button android:id="@+id/ctx_rename"
        android:layout_width="match_parent" android:layout_height="52dp"
        android:layout_marginBottom="8dp" android:text="✏️  Renommer"
        android:textColor="#FFFFFF" android:textStyle="bold"
        android:backgroundTint="#1AFFFFFF" android:gravity="start|center_vertical"
        android:paddingStart="16dp"/>
    <Button android:id="@+id/ctx_lock"
        android:layout_width="match_parent" android:layout_height="52dp"
        android:layout_marginBottom="8dp"
        android:textStyle="bold" android:backgroundTint="#1AFFFFFF"
        android:gravity="start|center_vertical" android:paddingStart="16dp">
        <TextView android:id="@+id/ctx_lock_lbl"
            android:layout_width="wrap_content" android:layout_height="wrap_content"
            android:textColor="#FFFFFF" android:textSize="14sp" android:textStyle="bold"/>
    </Button>
    <Button android:id="@+id/ctx_hide"
        android:layout_width="match_parent" android:layout_height="52dp"
        android:layout_marginBottom="8dp" android:text="👁️  Cacher dans le Vault"
        android:textColor="#FFFFFF" android:textStyle="bold"
        android:backgroundTint="#1AFFFFFF" android:gravity="start|center_vertical"
        android:paddingStart="16dp"/>
    <Button android:id="@+id/ctx_dock"
        android:layout_width="match_parent" android:layout_height="52dp"
        android:layout_marginBottom="8dp" android:text="📌  Ajouter à la barre"
        android:textColor="#FFFFFF" android:textStyle="bold"
        android:backgroundTint="#1AFFFFFF" android:gravity="start|center_vertical"
        android:paddingStart="16dp"/>
    <Button android:id="@+id/ctx_cancel"
        android:layout_width="match_parent" android:layout_height="52dp"
        android:text="✕  Annuler" android:textColor="#F87171"
        android:textStyle="bold" android:backgroundTint="#22EF4444"
        android:gravity="start|center_vertical" android:paddingStart="16dp"/>
</LinearLayout>'''

layouts[f"{RES}/layout/sheet_settings.xml"] = '''<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:background="#F0050516">
    <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content"
        android:orientation="vertical" android:padding="20dp">
        <TextView android:layout_width="wrap_content" android:layout_height="wrap_content"
            android:text="✝ ONE1GODLANCEUR — RÉGLAGES"
            android:textSize="12sp" android:textColor="#D4AF37" android:textStyle="bold"
            android:letterSpacing="0.2" android:layout_gravity="center"
            android:layout_marginBottom="20dp"/>

        <TextView android:layout_width="wrap_content" android:layout_height="wrap_content"
            android:text="🖼️  FOND D'ÉCRAN" android:textSize="10sp"
            android:textColor="#44FFFFFF" android:textStyle="bold"
            android:letterSpacing="0.15" android:layout_marginBottom="6dp"/>
        <Button android:id="@+id/setting_wallpaper"
            android:layout_width="match_parent" android:layout_height="48dp"
            android:layout_marginBottom="12dp" android:text="Changer le fond d'écran"
            android:textColor="#FFFFFF" android:textStyle="bold"
            android:backgroundTint="#1AFFFFFF"/>

        <TextView android:layout_width="wrap_content" android:layout_height="wrap_content"
            android:text="✨  TRANSITIONS (12 disponibles)"
            android:textSize="10sp" android:textColor="#44FFFFFF" android:textStyle="bold"
            android:letterSpacing="0.15" android:layout_marginBottom="6dp"/>
        <RadioGroup android:id="@+id/transition_group"
            android:layout_width="match_parent" android:layout_height="wrap_content"
            android:layout_marginBottom="12dp"/>

        <TextView android:layout_width="wrap_content" android:layout_height="wrap_content"
            android:text="📱  COLONNES" android:textSize="10sp"
            android:textColor="#44FFFFFF" android:textStyle="bold"
            android:letterSpacing="0.15" android:layout_marginBottom="6dp"/>
        <Spinner android:id="@+id/grid_cols_spinner"
            android:layout_width="match_parent" android:layout_height="48dp"
            android:layout_marginBottom="12dp"
            android:background="@drawable/search_background"
            android:popupBackground="#1A050516"/>

        <TextView android:layout_width="wrap_content" android:layout_height="wrap_content"
            android:text="🔒  SÉCURITÉ" android:textSize="10sp"
            android:textColor="#44FFFFFF" android:textStyle="bold"
            android:letterSpacing="0.15" android:layout_marginBottom="6dp"/>
        <Button android:id="@+id/setting_pin"
            android:layout_width="match_parent" android:layout_height="48dp"
            android:layout_marginBottom="12dp" android:text="🔑  Configurer le code PIN"
            android:textColor="#FFFFFF" android:textStyle="bold"
            android:backgroundTint="#1AFFFFFF"/>

        <TextView android:layout_width="wrap_content" android:layout_height="wrap_content"
            android:text="🛡️  PROTECTIONS" android:textSize="10sp"
            android:textColor="#44FFFFFF" android:textStyle="bold"
            android:letterSpacing="0.15" android:layout_marginBottom="8dp"/>
        <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content"
            android:orientation="horizontal" android:gravity="center_vertical"
            android:layout_marginBottom="10dp">
            <TextView android:layout_width="0dp" android:layout_height="wrap_content"
                android:layout_weight="1" android:text="Bloquer les publicités"
                android:textColor="#FFFFFF" android:textSize="14sp" android:textStyle="bold"/>
            <Switch android:id="@+id/ads_switch"
                android:layout_width="wrap_content" android:layout_height="wrap_content"
                android:thumbTint="#D4AF37" android:trackTint="#33D4AF37"/>
        </LinearLayout>
        <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content"
            android:orientation="horizontal" android:gravity="center_vertical">
            <TextView android:layout_width="0dp" android:layout_height="wrap_content"
                android:layout_weight="1" android:text="Limiter la charge à 100%"
                android:textColor="#FFFFFF" android:textSize="14sp" android:textStyle="bold"/>
            <Switch android:id="@+id/charge_switch"
                android:layout_width="wrap_content" android:layout_height="wrap_content"
                android:thumbTint="#22C55E" android:trackTint="#3322C55E"/>
        </LinearLayout>
    </LinearLayout>
</ScrollView>'''

layouts[f"{RES}/layout/sheet_vault.xml"] = '''<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:orientation="vertical" android:background="#F0050516" android:padding="20dp">
    <TextView android:layout_width="wrap_content" android:layout_height="wrap_content"
        android:text="🔐 Coffre-fort One1godlanceur"
        android:textSize="18sp" android:textColor="#D4AF37"
        android:textStyle="bold" android:layout_marginBottom="8dp"/>
    <TextView android:layout_width="wrap_content" android:layout_height="wrap_content"
        android:text="Appuyez sur une app pour la restaurer"
        android:textSize="12sp" android:textColor="#66FFFFFF"
        android:layout_marginBottom="16dp"/>
    <androidx.recyclerview.widget.RecyclerView android:id="@+id/vault_recycler"
        android:layout_width="match_parent" android:layout_height="match_parent"/>
</LinearLayout>'''

layouts[f"{RES}/layout/dialog_pin.xml"] = '''<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="wrap_content"
    android:orientation="vertical" android:gravity="center"
    android:background="#EE050516" android:padding="28dp">
    <TextView android:text="🔐" android:textSize="48sp" android:gravity="center"
        android:layout_marginBottom="12dp"
        android:layout_width="wrap_content" android:layout_height="wrap_content"/>
    <TextView android:text="CODE PIN • 4 CHIFFRES"
        android:textSize="11sp" android:textColor="#66FFFFFF"
        android:textStyle="bold" android:letterSpacing="0.1"
        android:gravity="center" android:layout_marginBottom="24dp"
        android:layout_width="wrap_content" android:layout_height="wrap_content"/>
    <LinearLayout android:layout_width="wrap_content" android:layout_height="wrap_content"
        android:orientation="horizontal" android:gravity="center"
        android:layout_marginBottom="28dp">
        <View android:id="@+id/dot1" android:layout_width="16dp" android:layout_height="16dp"
            android:layout_margin="8dp" android:background="@drawable/pin_dot"/>
        <View android:id="@+id/dot2" android:layout_width="16dp" android:layout_height="16dp"
            android:layout_margin="8dp" android:background="@drawable/pin_dot"/>
        <View android:id="@+id/dot3" android:layout_width="16dp" android:layout_height="16dp"
            android:layout_margin="8dp" android:background="@drawable/pin_dot"/>
        <View android:id="@+id/dot4" android:layout_width="16dp" android:layout_height="16dp"
            android:layout_margin="8dp" android:background="@drawable/pin_dot"/>
    </LinearLayout>
    <TextView android:id="@+id/pin_error"
        android:layout_width="wrap_content" android:layout_height="wrap_content"
        android:textColor="#EF4444" android:textSize="12sp" android:textStyle="bold"
        android:gravity="center" android:layout_marginBottom="12dp"/>
    <GridLayout android:layout_width="wrap_content" android:layout_height="wrap_content"
        android:columnCount="3" android:rowCount="4" android:layout_gravity="center">
        <Button android:id="@+id/k1" android:layout_width="72dp" android:layout_height="60dp"
            android:layout_margin="6dp" android:text="1" android:textSize="22sp"
            android:textColor="#FFFFFF" android:backgroundTint="#22FFFFFF" android:textStyle="bold"/>
        <Button android:id="@+id/k2" android:layout_width="72dp" android:layout_height="60dp"
            android:layout_margin="6dp" android:text="2" android:textSize="22sp"
            android:textColor="#FFFFFF" android:backgroundTint="#22FFFFFF" android:textStyle="bold"/>
        <Button android:id="@+id/k3" android:layout_width="72dp" android:layout_height="60dp"
            android:layout_margin="6dp" android:text="3" android:textSize="22sp"
            android:textColor="#FFFFFF" android:backgroundTint="#22FFFFFF" android:textStyle="bold"/>
        <Button android:id="@+id/k4" android:layout_width="72dp" android:layout_height="60dp"
            android:layout_margin="6dp" android:text="4" android:textSize="22sp"
            android:textColor="#FFFFFF" android:backgroundTint="#22FFFFFF" android:textStyle="bold"/>
        <Button android:id="@+id/k5" android:layout_width="72dp" android:layout_height="60dp"
            android:layout_margin="6dp" android:text="5" android:textSize="22sp"
            android:textColor="#FFFFFF" android:backgroundTint="#22FFFFFF" android:textStyle="bold"/>
        <Button android:id="@+id/k6" android:layout_width="72dp" android:layout_height="60dp"
            android:layout_margin="6dp" android:text="6" android:textSize="22sp"
            android:textColor="#FFFFFF" android:backgroundTint="#22FFFFFF" android:textStyle="bold"/>
        <Button android:id="@+id/k7" android:layout_width="72dp" android:layout_height="60dp"
            android:layout_margin="6dp" android:text="7" android:textSize="22sp"
            android:textColor="#FFFFFF" android:backgroundTint="#22FFFFFF" android:textStyle="bold"/>
        <Button android:id="@+id/k8" android:layout_width="72dp" android:layout_height="60dp"
            android:layout_margin="6dp" android:text="8" android:textSize="22sp"
            android:textColor="#FFFFFF" android:backgroundTint="#22FFFFFF" android:textStyle="bold"/>
        <Button android:id="@+id/k9" android:layout_width="72dp" android:layout_height="60dp"
            android:layout_margin="6dp" android:text="9" android:textSize="22sp"
            android:textColor="#FFFFFF" android:backgroundTint="#22FFFFFF" android:textStyle="bold"/>
        <Button android:id="@+id/k_cancel" android:layout_width="72dp" android:layout_height="60dp"
            android:layout_margin="6dp" android:text="✕" android:textSize="22sp"
            android:textColor="#EF4444" android:backgroundTint="#22EF4444" android:textStyle="bold"/>
        <Button android:id="@+id/k0" android:layout_width="72dp" android:layout_height="60dp"
            android:layout_margin="6dp" android:text="0" android:textSize="22sp"
            android:textColor="#FFFFFF" android:backgroundTint="#22FFFFFF" android:textStyle="bold"/>
        <Button android:id="@+id/k_del" android:layout_width="72dp" android:layout_height="60dp"
            android:layout_margin="6dp" android:text="⌫" android:textSize="22sp"
            android:textColor="#FFFFFF" android:backgroundTint="#22FFFFFF" android:textStyle="bold"/>
    </GridLayout>
</LinearLayout>'''

for path, content in layouts.items():
    with open(path, 'w') as f:
        f.write(content)
    print(f"✅ {path.split('/')[-1]}")
print("✅ Tous les layouts XML créés!")
PYEOF
echo -e "${G}✅ XML layouts créés${N}"

# ── Resources values & drawables ──────────────────────────
python3 << 'PYEOF'
RES = "app/src/main/res"

# colors.xml
with open(f"{RES}/values/colors.xml","w") as f:
    f.write("""<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="black">#000000</color>
    <color name="white">#FFFFFF</color>
    <color name="gold">#D4AF37</color>
    <color name="background">#050508</color>
</resources>
""")

# strings.xml
with open(f"{RES}/values/strings.xml","w") as f:
    f.write("""<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">One1godlanceur</string>
</resources>
""")

# themes.xml
with open(f"{RES}/values/themes.xml","w") as f:
    f.write("""<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.One1godlanceur" parent="Theme.MaterialComponents.DayNight.NoActionBar">
        <item name="colorPrimary">#D4AF37</item>
        <item name="colorOnPrimary">#000000</item>
        <item name="android:windowBackground">#000000</item>
        <item name="android:statusBarColor">@android:color/transparent</item>
        <item name="android:navigationBarColor">@android:color/transparent</item>
    </style>
    <style name="BottomSheetStyle" parent="Theme.MaterialComponents.BottomSheetDialog">
        <item name="android:windowBackground">@android:color/transparent</item>
        <item name="colorSurface">#F0050516</item>
    </style>
    <style name="DarkDialog" parent="Theme.MaterialComponents.Dialog">
        <item name="colorSurface">#EE050516</item>
        <item name="colorOnSurface">#FFFFFF</item>
    </style>
</resources>
""")

# drawables
drawables = {
    "dock_background.xml": """<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#CC1E1E32"/>
    <corners android:radius="26dp"/>
    <stroke android:color="#33FFFFFF" android:width="1dp"/>
</shape>""",
    "pill_background.xml": """<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#66FFFFFF"/>
    <corners android:radius="3dp"/>
</shape>""",
    "fab_background.xml": """<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="oval">
    <solid android:color="#CC1E1E32"/>
    <stroke android:color="#33FFFFFF" android:width="1dp"/>
</shape>""",
    "search_background.xml": """<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#1AFFFFFF"/>
    <corners android:radius="14dp"/>
</shape>""",
    "dot_active.xml": """<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#FFFFFFFF"/>
    <corners android:radius="3dp"/>
</shape>""",
    "dot_inactive.xml": """<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#44FFFFFF"/>
    <corners android:radius="3dp"/>
</shape>""",
    "pin_dot.xml": """<?xml version="1.0" encoding="utf-8"?>
<selector xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:state_selected="true">
        <shape android:shape="oval"><solid android:color="#D4AF37"/></shape>
    </item>
    <item>
        <shape android:shape="oval">
            <solid android:color="#00000000"/>
            <stroke android:color="#66FFFFFF" android:width="2dp"/>
        </shape>
    </item>
</selector>""",
    "ic_settings.xml": """<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp"
    android:viewportWidth="24" android:viewportHeight="24">
    <path android:fillColor="#FFFFFFFF"
        android:pathData="M12,15.5A3.5,3.5 0 0,1 8.5,12A3.5,3.5 0 0,1 12,8.5A3.5,3.5 0 0,1 15.5,12A3.5,3.5 0 0,1 12,15.5M19.43,12.97C19.47,12.65 19.5,12.33 19.5,12C19.5,11.67 19.47,11.34 19.43,11L21.54,9.37C21.73,9.22 21.78,8.95 21.66,8.73L19.66,5.27C19.54,5.05 19.27,4.96 19.05,5.05L16.56,6.05C16.04,5.66 15.5,5.32 14.87,5.07L14.5,2.42C14.46,2.18 14.25,2 14,2H10C9.75,2 9.54,2.18 9.5,2.42L9.13,5.07C8.5,5.32 7.96,5.66 7.44,6.05L4.95,5.05C4.73,4.96 4.46,5.05 4.34,5.27L2.34,8.73C2.21,8.95 2.27,9.22 2.46,9.37L4.57,11C4.53,11.34 4.5,11.67 4.5,12C4.5,12.33 4.53,12.65 4.57,12.97L2.46,14.63C2.27,14.78 2.21,15.05 2.34,15.27L4.34,18.73C4.46,18.95 4.73,19.03 4.95,18.95L7.44,17.94C7.96,18.34 8.5,18.68 9.13,18.93L9.5,21.58C9.54,21.82 9.75,22 10,22H14C14.25,22 14.46,21.82 14.5,21.58L14.87,18.93C15.5,18.67 16.04,18.34 16.56,17.94L19.05,18.95C19.27,19.03 19.54,18.95 19.66,18.73L21.66,15.27C21.78,15.05 21.73,14.78 21.54,14.63L19.43,12.97Z"/>
</vector>""",
}

for name, content in drawables.items():
    with open(f"{RES}/drawable/{name}", "w") as f:
        f.write(content)
    print(f"✅ {name}")

# Font placeholders
import os
os.makedirs(f"{RES}/font", exist_ok=True)
for fn in ["rajdhani.xml", "orbitron.xml"]:
    with open(f"{RES}/font/{fn}", "w") as f:
        f.write('<font-family xmlns:android="http://schemas.android.com/apk/res/android"/>')
    print(f"✅ {fn}")

# Mipmap ic_launcher placeholder
for mipmap in ["mipmap-mdpi","mipmap-hdpi","mipmap-xhdpi","mipmap-xxhdpi","mipmap-xxxhdpi"]:
    os.makedirs(f"{RES}/{mipmap}", exist_ok=True)
    with open(f"{RES}/{mipmap}/ic_launcher.xml", "w") as f:
        f.write("""<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/black"/>
    <foreground>
        <inset xmlns:android="http://schemas.android.com/apk/res/android"
            android:drawable="@drawable/ic_settings"
            android:inset="18%"/>
    </foreground>
</adaptive-icon>""")

print("✅ Resources complètes!")
PYEOF
echo -e "${G}✅ Resources créées${N}"

# ── GitHub Actions ─────────────────────────────────────────
cat > .github/workflows/build-apk.yml << 'EOF'
name: 🚀 Build One1godlanceur APK (Kotlin Natif)

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

      - name: ☕ Setup Java 21
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: 21

      - name: 🤖 Setup Android SDK
        uses: android-actions/setup-android@v3

      - name: 🔧 Gradle wrapper
        run: |
          gradle wrapper --gradle-version 8.4 2>/dev/null || true
          chmod +x gradlew 2>/dev/null || true
          # Si pas de gradlew, le télécharger
          if [ ! -f gradlew ]; then
            wget -q https://raw.githubusercontent.com/gradle/gradle/master/gradlew
            chmod +x gradlew
          fi

      - name: 📦 Build Debug APK
        run: ./gradlew assembleDebug --no-daemon --stacktrace

      - name: 📤 Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: One1godlanceur-Kotlin-APK
          path: app/build/outputs/apk/debug/app-debug.apk
          retention-days: 30
EOF
echo -e "${G}✅ GitHub Actions workflow (Java 21)${N}"

# ── npm install ─────────────────────────────────────────────
echo -e "\n${B}╔══════════════════════════════════════════════════════╗${N}"
echo -e "${B}║  ✅  PROJET KOTLIN CRÉÉ — Prochaines étapes :       ║${N}"
echo -e "${B}╚══════════════════════════════════════════════════════╝${N}"
echo -e "${G}git add .${N}"
echo -e "${G}git commit -m '✝️ One1godlanceur — Kotlin Natif'${N}"
echo -e "${G}git push origin main${N}"
echo -e ""
echo -e "${Y}→ GitHub Actions compile le Kotlin${N}"
echo -e "${Y}→ APK téléchargeable dans onglet Actions${N}"
echo -e "${Y}→ Ce launcher utilise les VRAIES icônes Android${N}"
echo -e "${Y}→ 12 transitions dont le Feuilletage de livre 📖${N}"
