# Optimove Dashboard - iOS Native App

A native iOS application that provides secure access to the Optimove Dashboard with enhanced mobile experience.

## 🚀 Features

### Core Functionality
- **Native iOS Interface** - Built with UIKit for optimal performance
- **WebKit Integration** - Seamless web dashboard rendering
- **Auto-Login** - Automatic credential injection with secure Base64 encoding
- **Smart UI Cleanup** - Removes web navigation elements for mobile-optimized view
- **Offline Settings** - Secure local storage of user credentials
- **State Preservation** - Maintains dashboard state during navigation

### User Experience
- **Settings Screen** - Clean form for credential management
- **Dashboard Screen** - Full-featured dashboard with mobile optimizations
- **Smart Navigation** - Preserves state when switching between screens
- **Loading States** - Professional loading indicators with progress messages
- **Error Handling** - Graceful error handling with user-friendly messages

### Technical Features
- **JavaScript Injection** - Custom scripts for auto-login and UI cleanup
- **WebView Delegate Handling** - Proper page load detection and timing
- **Chrome User Agent** - Optimized web compatibility
- **Memory Management** - Efficient resource handling
- **Professional Branding** - Complete app icon set with Optimove logo

## 📱 Screenshots

*Coming soon - screenshots of the app in action*

## 🛠 Technical Stack

- **Language**: Swift
- **Framework**: UIKit
- **Web Engine**: WKWebView (WebKit)
- **Storage**: UserDefaults
- **Architecture**: MVC Pattern
- **Deployment**: iOS 13.0+

## 📦 Project Structure

```
Optimove Dashboard/
├── ViewControllers/
│   ├── DashboardViewController.swift    # Main dashboard with WebView
│   └── SettingsViewController.swift     # Settings form and validation
├── Models/
│   └── UserSettings.swift              # User credential data model
├── Utils/
│   └── StorageManager.swift            # Secure local storage utilities
├── Assets.xcassets/
│   └── AppIcon.appiconset/             # Complete iOS app icon set
└── Supporting Files/
    ├── AppDelegate.swift
    ├── SceneDelegate.swift
    └── Info.plist
```

## 🔧 Installation & Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/osheory/ios-dashboard.git
   cd ios-dashboard
   ```

2. **Open in Xcode**
   ```bash
   open "Optimove Dashboard.xcodeproj"
   ```

3. **Build and Run**
   - Select your target device/simulator
   - Press `Cmd+R` to build and run

## ⚙️ Configuration

The app requires the following settings on first launch:
- **Username**: Your Optimove dashboard username
- **Password**: Your Optimove dashboard password  
- **Site URL**: Your Optimove dashboard URL

Settings are securely stored locally and persist between app launches.

## 🔒 Security Features

- **Base64 Encoding**: Credentials are Base64 encoded during JavaScript injection
- **Local Storage**: Settings stored securely in iOS UserDefaults
- **No Network Storage**: Credentials never leave the device
- **Secure WebView**: Uses system WebKit with security features enabled

## 🚀 Key Capabilities

### Auto-Login Flow
1. App loads dashboard URL
2. Detects login page automatically
3. Injects credentials securely via JavaScript
4. Handles login success/failure gracefully
5. Redirects to clean dashboard view

### UI Optimization
1. Removes web navigation bars
2. Hides sidebars for mobile view
3. Optimizes layout for mobile screens
4. Maintains responsive design

### Smart Navigation
1. Preserves WebView state during navigation
2. Intelligent back button behavior
3. No unnecessary page reloads
4. Smooth transitions between screens

## 📋 Requirements

- iOS 13.0 or later
- Xcode 12.0 or later
- Valid Optimove dashboard credentials

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Open an issue on GitHub
- Contact the development team

## 🔄 Version History

### v1.0.0 (Current)
- Initial release
- Complete native iOS implementation
- Auto-login functionality
- Professional UI with app icons
- State preservation and smart navigation

---

**Built with ❤️ for mobile-first Optimove dashboard access**
