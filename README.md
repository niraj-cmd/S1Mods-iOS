# S1Mods iOS Port

> **Unofficial iOS port** of [ola-s1-mods](https://github.com/Asjohn720/ola-s1-mods) by [@Asjohn720](https://github.com/Asjohn720).
> A native SwiftUI controller for Ola S1/S1 Pro electric scooter mods.

## 🎯 What This Does

This app controls your Ola S1/S1 Pro electric scooter via a **relay server** running on your computer. It replicates the functionality of the original Android app but runs natively on iOS.

### Features

| Feature | Description |
|---------|-------------|
| **Auto Discovery** | Finds scooter on Wi-Fi/hotspot automatically |
| **Manual IP Entry** | For link-local IPv6 addresses with scope IDs |
| **Setup Wizard** | 5-step automated: Connect → Unlock ADB → Install APKs → Permissions → Home |
| **Toolbox** | Screenshot, RAM Info, Scooter Info, Root Shell, Settings shortcuts |
| **Custom APK Install** | Pick APKs from Files app, install via ADB |
| **Terminal** | Interactive root shell with command history |

## 🏗 Architecture

```
iOS App (SwiftUI)  ←→ HTTP/JSON  →  Relay Server (Python)  ←→ gRPC/ADB  →  Ola S1 Scooter
```

- **iOS App**: Native SwiftUI, dark theme, 4 tabs
- **Relay Server**: Python asyncio + gRPC + ADB, runs on your computer
- **Communication**: HTTP/JSON between iOS and relay, gRPC/ADB between relay and scooter

## 📱 App Screens

| Tab | Features |
|-----|----------|
| **Setup** | Auto-scan, Manual IP, 5-step wizard, Progress tracking |
| **Toolbox** | Screenshot, RAM/Info, Shell, Settings shortcuts, Launch mods |
| **Custom APK** | File picker, Package manager, Install/uninstall |
| **Terminal** | Interactive shell, Command history, Log filtering |

## 🚀 Build Options (No Mac Required)

### Option 1: Codemagic (Easiest, Free)
- 500 build minutes/month free
- Manual signing with Apple ID + app-specific password
- **No Apple Developer enrollment needed**

### Option 2: GitHub Actions (Free)
- 2000 macOS minutes/month free
- Requires Apple Developer enrollment (free tier) + API key
- Fully automated on push

### Option 3: MacinCloud ($1/hr)
- Rent a Mac for 1 hour
- Build locally via Xcode

## 🛠 Quick Start

### Prerequisites
- iPhone with iOS 16+
- Windows/Linux/Mac computer for relay server
- Ola S1/S1 Pro with MoveOS 3.0+
- Same Wi-Fi network (or phone hotspot)

### 1. Start Relay Server
```bash
cd RelayServer
pip3 install -r requirements.txt
python3 relay_server.py
```
Server runs on `http://<your-ip>:8080`

### 2. Build iOS App
**Option A: Codemagic** (Recommended)
1. https://codemagic.io/ → Add app → GitHub
2. Code signing → iOS → Manual signing
3. Apple ID + App-specific password → Start build

**Option B: GitHub Actions**
1. Add 4 secrets to GitHub repo
2. Run workflow

### 3. Configure App
1. Install IPA via Sideloadly
2. Open app → Settings → Enter relay server URL
3. Tap "Auto Scan" or enter IP manually

### 4. Run Setup Wizard
1. Tap "Install Mod" → Select apps → Start
2. Wait for completion
3. Enjoy mods on your scooter!

## 📦 Bundled Mods (Credit: @Asjohn720)

| Mod | Package | Description |
|-----|---------|-------------|
| **Balls Navigation** | `com.asjohn720.ball` | Floating Back/Home/Settings buttons |
| **Music Mod** | `com.asjohn720.musicmod` | Ad-free music playback |
| **Android Auto** | `com.asjohn720.androidauto` | OpenHeadUnit projection |

> **All mod APKs are original work by [@Asjohn720](https://github.com/Asjohn720)** — included with permission from the original [ola-s1-mods](https://github.com/Asjohn720/ola-s1-mods) repository.

## ⚙️ Configuration

### Relay Server Settings
| Setting | Value |
|---------|-------|
| Host | `0.0.0.0` |
| Port | `8080` |
| gRPC Port | `50005` (to scooter) |
| ADB Port | `5555` (to scooter) |

### App Settings
- **Relay Server URL**: `http://<your-computer-ip>:8080`
- **Bundle ID**: `com.nirajashtaputre.s1mods`

## 🔐 Security Notes

- Relay server provides **root access** to scooter
- Only run on **trusted private networks**
- ADB unlock uses **in-memory bind mount** (reversible on reboot)
- Development builds expire in **7 days** (free tier)

## 📚 Project Structure

```
S1Mods-iOS/
├── S1Mods/                 # SwiftUI iOS App
│   ├── S1Mods/             # App source
│   │   ├── Models/         # Data models
│   │   ├── Views/          # SwiftUI views
│   │   ├── ViewModels/     # Business logic
│   │   ├── Network/        # Relay client
│   │   └── Resources/      # Colors, APKs, Assets
│   └── S1Mods.xcodeproj
├── RelayServer/            # Python Relay Server
│   ├── relay_server.py     # Main server
│   ├── requirements.txt
│   └── start_relay.sh
├── .github/workflows/      # GitHub Actions CI/CD
│   └── build-ipa.yml
├── codemagic.yaml          # Codemagic CI/CD config
└── README.md
```

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| "No matching profiles" | Register bundle ID in Apple Portal, register device UDID |
| "API key invalid" | Check secrets, ensure no extra spaces |
| "Certificate not found" | Register bundle ID in Apple Portal |
| "TEAM_ID not found" | Add TEAM_ID secret from Apple Developer |

## 📄 License

MIT License — Same as original [ola-s1-mods](https://github.com/Asjohn720/ola-s1-mods).

## ⚠️ Disclaimer

**Unofficial port.** Not affiliated with, endorsed by, or supported by Ola Electric.  
'Ola', 'MoveOS', 'S1' are trademarks of Ola Electric.  
Modifying your scooter may void its warranty. **Use at your own risk.**

## 🙏 Credits

- **Original Android App**: [@Asjohn720](https://github.com/Asjohn720) — [ola-s1-mods](https://github.com/Asjohn720/ola-s1-mods)
- **Mod APKs**: All by @Asjohn720
- **iOS Port**: Community port

---

**Star ⭐ this repo if it helped you mod your Ola S1!**
