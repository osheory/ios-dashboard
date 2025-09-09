import UIKit
import WebKit

class DashboardViewController: UIViewController {
    
    // MARK: - UI Elements
    private let headerView = UIView()
    private let headerTitleLabel = UILabel()
    private let refreshButton = UIButton()
    private let settingsButton = UIButton()
    private let webViewContainer = UIView()
    private let loadingOverlay = UIView()
    private let loadingContentView = UIView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let loadingMessageLabel = UILabel()
    private let loadingSubtextLabel = UILabel()
    
    // MARK: - Properties
    private var webView: WKWebView!
    private var settings: UserSettings?
    private var isWebViewVisible = false
    private var loginAttempts = 0
    private let maxLoginAttempts = 3
    private var fallbackTimer: Timer?
    private var isJavaScriptComplete = false
    private var isDashboardReady = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupWebView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        loadUserSettings()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        
        // Configure header
        headerView.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        headerTitleLabel.text = "Optimove Dashboard"
        headerTitleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        headerTitleLabel.textColor = .white
        headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(headerTitleLabel)
        
        // Configure header buttons
        refreshButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        refreshButton.tintColor = .white
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
        headerView.addSubview(refreshButton)
        
        settingsButton.setImage(UIImage(systemName: "gearshape"), for: .normal)
        settingsButton.tintColor = .white
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        headerView.addSubview(settingsButton)
        
        // Configure web view container
        webViewContainer.backgroundColor = .white
        webViewContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webViewContainer)
        
        // Configure loading overlay
        loadingOverlay.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.95)
        loadingOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingOverlay)
        
        loadingContentView.backgroundColor = .white
        loadingContentView.layer.cornerRadius = 15
        loadingContentView.translatesAutoresizingMaskIntoConstraints = false
        loadingOverlay.addSubview(loadingContentView)
        
        loadingIndicator.color = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingContentView.addSubview(loadingIndicator)
        
        loadingMessageLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        loadingMessageLabel.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        loadingMessageLabel.textAlignment = .center
        loadingMessageLabel.text = "📸 Loading dashboard..."
        loadingMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingContentView.addSubview(loadingMessageLabel)
        
        loadingSubtextLabel.font = UIFont.systemFont(ofSize: 14)
        loadingSubtextLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
        loadingSubtextLabel.textAlignment = .center
        loadingSubtextLabel.text = "Setting up your dashboard experience..."
        loadingSubtextLabel.numberOfLines = 0
        loadingSubtextLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingContentView.addSubview(loadingSubtextLabel)
        
        // Initially show loading
        showLoadingOverlay(true)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header view
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100),
            
            // Header title
            headerTitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            headerTitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -17),
            
            // Settings button
            settingsButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            settingsButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -17),
            settingsButton.widthAnchor.constraint(equalToConstant: 24),
            settingsButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Refresh button
            refreshButton.trailingAnchor.constraint(equalTo: settingsButton.leadingAnchor, constant: -15),
            refreshButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -17),
            refreshButton.widthAnchor.constraint(equalToConstant: 24),
            refreshButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Web view container
            webViewContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            webViewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webViewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webViewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Loading overlay
            loadingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Loading content view
            loadingContentView.centerXAnchor.constraint(equalTo: loadingOverlay.centerXAnchor),
            loadingContentView.centerYAnchor.constraint(equalTo: loadingOverlay.centerYAnchor),
            loadingContentView.widthAnchor.constraint(equalToConstant: 250),
            loadingContentView.heightAnchor.constraint(equalToConstant: 150),
            
            // Loading indicator
            loadingIndicator.topAnchor.constraint(equalTo: loadingContentView.topAnchor, constant: 20),
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingContentView.centerXAnchor),
            
            // Loading message
            loadingMessageLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 20),
            loadingMessageLabel.leadingAnchor.constraint(equalTo: loadingContentView.leadingAnchor, constant: 20),
            loadingMessageLabel.trailingAnchor.constraint(equalTo: loadingContentView.trailingAnchor, constant: -20),
            
            // Loading subtext
            loadingSubtextLabel.topAnchor.constraint(equalTo: loadingMessageLabel.bottomAnchor, constant: 10),
            loadingSubtextLabel.leadingAnchor.constraint(equalTo: loadingContentView.leadingAnchor, constant: 20),
            loadingSubtextLabel.trailingAnchor.constraint(equalTo: loadingContentView.trailingAnchor, constant: -20),
        ])
    }
    
    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = WKUserContentController()
        
        // Add message handler for JavaScript communication
        configuration.userContentController.add(self, name: "nativeApp")
        
        webView = WKWebView(frame: webViewContainer.bounds, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.customUserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        webViewContainer.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: webViewContainer.topAnchor),
            webView.leadingAnchor.constraint(equalTo: webViewContainer.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: webViewContainer.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor)
        ])
        
        // Initially hide webview
        webView.alpha = 0
    }
    
    private func loadUserSettings() {
        guard let userSettings = StorageManager.shared.loadSettings() else {
            showAlert(title: "No Settings Found", message: "Please configure your settings first.") { [weak self] in
                self?.navigateToSettings()
            }
            return
        }
        
        settings = userSettings
        updateLoadingMessage("📸 Connecting to dashboard...")
        loadWebView()
    }
    
    private func loadWebView() {
        guard let settings = settings else { return }
        
        var urlString = settings.siteUrl
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            urlString = "https://"+urlString
        }
        
        guard let url = URL(string: urlString) else {
            showAlert(title: "Invalid URL", message: "Please check your site URL in settings.") { [weak self] in
                self?.navigateToSettings()
            }
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    // MARK: - Actions
    @objc private func refreshButtonTapped() {
        print("🔄 Refresh button tapped - reloading from original dashboard URL")
        
        // Reset all state
        showLoadingOverlay(true)
        updateLoadingMessage("📸 Refreshing dashboard...")
        loginAttempts = 0
        isJavaScriptComplete = false
        isDashboardReady = false
        fallbackTimer?.invalidate()
        
        // Hide WebView to show loading
        hideWebView()
        
        // Load from the original dashboard URL (not just reload current page)
        loadUserSettings()
    }
    
    @objc private func settingsButtonTapped() {
        navigateToSettings()
    }
    
    // MARK: - Navigation
    private func navigateToSettings() {
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    // MARK: - Helper Methods
    private func showLoadingOverlay(_ show: Bool) {
        loadingOverlay.isHidden = !show
        if show {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
    
    private func updateLoadingMessage(_ message: String) {
        loadingMessageLabel.text = message
    }
    
    private func showWebView() {
        print("🎯 Showing WebView - Dashboard is ready!")
        isWebViewVisible = true
        UIView.animate(withDuration: 0.3) {
            self.webView.alpha = 1.0
        }
        showLoadingOverlay(false)
        
        // Clear any fallback timers
        fallbackTimer?.invalidate()
        fallbackTimer = nil
    }
    
    private func showWebViewWhenReady() {
        print("⏳ Checking if dashboard is ready to show...")
        if isDashboardReady && isJavaScriptComplete {
            print("✅ Dashboard is ready - showing WebView immediately")
            showWebView()
        } else {
            print("⚠️ Dashboard not ready yet - showing for manual interaction")
            updateLoadingMessage("📸 Manual interaction may be needed...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showWebView()
            }
        }
    }
    
    private func hideWebView() {
        isWebViewVisible = false
        webView.alpha = 0
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    
    // MARK: - JavaScript Injection
    private func injectLoginScript() {
        guard let settings = settings else { return }
        
        // Convert credentials to base64 to avoid any escaping issues
        let usernameData = settings.username.data(using: .utf8) ?? Data()
        let passwordData = settings.password.data(using: .utf8) ?? Data()
        let usernameBase64 = usernameData.base64EncodedString()
        let passwordBase64 = passwordData.base64EncodedString()
        
        let loginScript = """
        (function() {
            // Decode credentials from base64
            var username = atob('\(usernameBase64)');
            var password = atob('\(passwordBase64)');
            var currentAttempt = \(loginAttempts + 1);
            var maxAttempts = \(maxLoginAttempts);
            
            console.log('Starting auto-login process with attempt ' + currentAttempt + '/' + maxAttempts + '...');
            
            function detectLoginFailure() {
                // Check for common error indicators
                var errorSelectors = [
                    '.error', '.alert-danger', '.login-error', '.error-message',
                    '[class*="error"]', '[class*="invalid"]', '[class*="failed"]',
                    '.text-danger', '.has-error', '.invalid-feedback'
                ];
                
                for (var i = 0; i < errorSelectors.length; i++) {
                    var errorElement = document.querySelector(errorSelectors[i]);
                    if (errorElement && errorElement.textContent.trim() !== '') {
                        return true;
                    }
                }
                
                // Check if we're still on login page by looking for login fields
                var loginFields = document.querySelector('#email, #password, input[type="email"], input[type="password"]');
                var currentUrl = window.location.href.toLowerCase();
                return loginFields && (currentUrl.includes('login') || currentUrl.includes('sign'));
            }
            
            function attemptLogin() {
                // Try primary selectors first
                var emailField = document.getElementById('email');
                var passwordField = document.getElementById('password');
                var loginButton = document.getElementById('btnLogin');
                
                if (emailField && passwordField && loginButton) {
                    console.log('Primary login fields found, filling credentials...');
                    emailField.value = username;
                    passwordField.value = password;
                    
                    // Trigger input events
                    emailField.dispatchEvent(new Event('input', { bubbles: true }));
                    passwordField.dispatchEvent(new Event('input', { bubbles: true }));
                    emailField.dispatchEvent(new Event('change', { bubbles: true }));
                    passwordField.dispatchEvent(new Event('change', { bubbles: true }));
                    
                    // Click login button after a short delay
                    setTimeout(function() {
                        console.log('Clicking primary login button...');
                        loginButton.click();
                        
                        // Check for login success/failure after submit
                        setTimeout(function() {
                            if (detectLoginFailure()) {
                                console.log('Login attempt ' + currentAttempt + ' failed - detected error or still on login page');
                                window.webkit.messageHandlers.nativeApp.postMessage({
                                    type: 'LOGIN_ATTEMPT_FAILED',
                                    attempt: currentAttempt,
                                    maxAttempts: maxAttempts,
                                    method: 'primary'
                                });
                            } else {
                                console.log('Login attempt ' + currentAttempt + ' appears successful');
                                window.webkit.messageHandlers.nativeApp.postMessage({
                                    type: 'LOGIN_ATTEMPTED',
                                    success: true,
                                    attempt: currentAttempt,
                                    method: 'primary'
                                });
                            }
                        }, 3000); // Wait 3 seconds for page to process login
                    }, 500);
                    return true;
                }
                
                // Try alternative selectors
                var altEmailField = document.querySelector('input[type="email"], input[name="email"], input[name="username"]');
                var altPasswordField = document.querySelector('input[type="password"], input[name="password"]');
                var altLoginButton = document.querySelector('button[type="submit"], input[type="submit"], .login-btn, .btn-login');
                
                if (altEmailField && altPasswordField && altLoginButton) {
                    console.log('Alternative login fields found');
                    altEmailField.value = username;
                    altPasswordField.value = password;
                    
                    altEmailField.dispatchEvent(new Event('input', { bubbles: true }));
                    altPasswordField.dispatchEvent(new Event('input', { bubbles: true }));
                    altEmailField.dispatchEvent(new Event('change', { bubbles: true }));
                    altPasswordField.dispatchEvent(new Event('change', { bubbles: true }));
                    
                    setTimeout(function() {
                        console.log('Clicking alternative login button...');
                        altLoginButton.click();
                        
                        // Check for login success/failure after submit
                        setTimeout(function() {
                            if (detectLoginFailure()) {
                                console.log('Login attempt ' + currentAttempt + ' failed - detected error or still on login page');
                                window.webkit.messageHandlers.nativeApp.postMessage({
                                    type: 'LOGIN_ATTEMPT_FAILED',
                                    attempt: currentAttempt,
                                    maxAttempts: maxAttempts,
                                    method: 'alternative'
                                });
                            } else {
                                console.log('Login attempt ' + currentAttempt + ' appears successful');
                                window.webkit.messageHandlers.nativeApp.postMessage({
                                    type: 'LOGIN_ATTEMPTED',
                                    success: true,
                                    attempt: currentAttempt,
                                    method: 'alternative'
                                });
                            }
                        }, 3000); // Wait 3 seconds for page to process login
                    }, 500);
                    return true;
                }
                
                return false; // No login fields found
            }
            
            // Start login attempt
            setTimeout(function() {
                if (!attemptLogin()) {
                    console.log('No login fields found on page');
                    window.webkit.messageHandlers.nativeApp.postMessage({
                        type: 'NO_LOGIN_FIELDS',
                        attempt: currentAttempt
                    });
                }
            }, 1000);
        })();
        """
        
        webView.evaluateJavaScript(loginScript) { [weak self] (result, error) in
            if let error = error {
                print("❌ Error injecting login script: \(error)")
                print("Error details: \(error.localizedDescription)")
                
                // If JavaScript injection fails, show the webview for manual login
                self?.updateLoadingMessage("📸 Auto-login failed, showing manual login...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self?.showWebViewWhenReady()
                }
            } else {
                print("✅ Login script injected successfully")
                
                // Set fallback timeout
                self?.fallbackTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { _ in
                    print("Auto-login timeout reached, showing webview")
                    self?.updateLoadingMessage("📸 Login may require manual action...")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self?.showWebViewWhenReady()
                    }
                }
            }
        }
    }
    
    private func injectCleanupScript() {
        let cleanupScript = """
        (function() {
            console.log('Starting comprehensive dashboard UI cleanup...');
            
            function performCleanup() {
                var elementsRemoved = 0;
                
                // Remove sidebar
                var sidebar = document.querySelector('aside');
                if (sidebar && sidebar.style.display !== 'none') {
                    sidebar.style.display = 'none';
                    elementsRemoved++;
                    console.log('Sidebar removed');
                }
                
                // Remove top navigation bars - comprehensive selectors
                var topNavSelectors = [
                    '.topnavbar', '#topnavbar', '[class*="topnavbar"]',
                    '.top-nav', '#top-nav', '[class*="top-nav"]',
                    '.header', '.header-nav', '.main-header', 
                    '.navbar', '.nav-bar', '.navigation',
                    '.toolbar', '.top-bar', '.app-header',
                    '.site-header', '.page-header', '.global-header',
                    '[class*="header"]', '[class*="navbar"]', 
                    '[class*="navigation"]', '[class*="toolbar"]'
                ];
                
                topNavSelectors.forEach(function(selector) {
                    var elements = document.querySelectorAll(selector);
                    elements.forEach(function(element) {
                        if (element && element.style.display !== 'none' && element.getBoundingClientRect().top < 200) {
                            element.style.display = 'none';
                            elementsRemoved++;
                            console.log('Top navigation element removed:', selector);
                        }
                    });
                });
                
                // Remove any fixed positioned elements at the top
                var allElements = document.querySelectorAll('*');
                allElements.forEach(function(element) {
                    var style = window.getComputedStyle(element);
                    if (style.position === 'fixed' && element.style.display !== 'none' && element.getBoundingClientRect().top < 100) {
                        element.style.display = 'none';
                        elementsRemoved++;
                        console.log('Fixed top element removed');
                    }
                });
                
                // Remove nav tags specifically
                var navElements = document.querySelectorAll('nav');
                navElements.forEach(function(nav) {
                    if (nav.style.display !== 'none') {
                        nav.style.display = 'none';
                        elementsRemoved++;
                        console.log('Nav element removed');
                    }
                });
                
                // Remove any element with common top navigation classes
                var topClasses = ['top', 'header', 'nav', 'menu', 'toolbar', 'bar'];
                topClasses.forEach(function(className) {
                    var elements = document.querySelectorAll('[class*="' + className + '"]');
                    elements.forEach(function(element) {
                        var rect = element.getBoundingClientRect();
                        if (element.style.display !== 'none' && rect.top < 150 && rect.height < 200 && rect.width > 200) {
                            element.style.display = 'none';
                            elementsRemoved++;
                            console.log('Top bar element removed by class:', className);
                        }
                    });
                });
                
                return elementsRemoved;
            }
            
            // Perform initial cleanup
            var removed = performCleanup();
            console.log('Initial cleanup completed, removed ' + removed + ' elements');
            
            // Wait and perform additional cleanup passes to catch dynamically loaded elements
            setTimeout(function() {
                var removed2 = performCleanup();
                console.log('Second cleanup pass completed, removed ' + removed2 + ' additional elements');
                
                setTimeout(function() {
                    var removed3 = performCleanup();
                    console.log('Final cleanup pass completed, removed ' + removed3 + ' additional elements');
                    
                    // Wait a bit more to ensure page is stable, then signal completion
                    setTimeout(function() {
                        console.log('Dashboard cleanup fully complete and stable');
                        
                        // Final check to ensure everything is ready
                        setTimeout(function() {
                            console.log('Dashboard is fully ready for display');
                            
                            // Signal final completion
                            window.webkit.messageHandlers.nativeApp.postMessage({
                                type: 'DASHBOARD_READY'
                            });
                        }, 1000);
                    }, 500);
                }, 1000);
            }, 1000);
        })();
        """
        
        webView.evaluateJavaScript(cleanupScript) { (result, error) in
            if let error = error {
                print("Error injecting cleanup script: \\(error)")
            }
        }
    }
}

// MARK: - WKNavigationDelegate
extension DashboardViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let currentUrl = webView.url?.absoluteString ?? "unknown"
        print("Page finished loading: \(currentUrl)")
        
        // Check if this looks like a login page
        let isLoginPage = currentUrl.lowercased().contains("login") || 
                         currentUrl.lowercased().contains("sign") ||
                         currentUrl.lowercased().contains("auth")
        
        if isLoginPage {
            updateLoadingMessage("📸 Login page loaded, attempting auto-login...")
            
            // Wait for DOM to be fully ready, then inject login script
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                print("Injecting login script after page load...")
                self.injectLoginScript()
            }
        } else {
            updateLoadingMessage("📸 Dashboard loaded, checking if login is needed...")
            
            // Check if login fields exist on this page
            let checkLoginScript = """
            var hasLoginFields = document.querySelector('#email, #password, input[type="email"], input[type="password"], .login-form, #login') !== null;
            hasLoginFields;
            """
            
            webView.evaluateJavaScript(checkLoginScript) { [weak self] (result, error) in
                if let hasLoginFields = result as? Bool, hasLoginFields {
                    print("Login fields detected on non-login URL, injecting script...")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self?.injectLoginScript()
                    }
                } else {
                    print("No login fields detected, assuming already logged in")
                    self?.updateLoadingMessage("📸 Checking dashboard content...")
                    
                    // Wait a bit then try cleanup script
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self?.injectCleanupScript()
                    }
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("WebView navigation failed: \\(error)")
        showLoadingOverlay(false)
        showAlert(title: "Error", message: "Failed to load dashboard. Please check your settings.")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url?.absoluteString ?? ""
        print("Navigation to: \\(url)")
        
        // Clear any existing fallback timer
        fallbackTimer?.invalidate()
        
        // Check if we're on the dashboard page (after login redirect)
        let isDashboard = url.contains("dashboard") ||
                         url.contains("main") ||
                         url.contains("home") ||
                         url.contains("app") ||
                         (!url.contains("login") && !url.contains("sign") && url != settings?.siteUrl)
        
        if isDashboard {
            updateLoadingMessage("📸 Setting up dashboard view...")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.injectCleanupScript()
            }
        } else if url.contains("login") {
            // We're still on a login page, keep trying auto-login
            updateLoadingMessage("📸 On login page, attempting auto-login...")
        }
        
        decisionHandler(.allow)
    }
}

// MARK: - WKUIDelegate
extension DashboardViewController: WKUIDelegate {
    // Handle JavaScript alerts, confirms, etc.
}

// MARK: - WKScriptMessageHandler
extension DashboardViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let messageBody = message.body as? [String: Any],
              let type = messageBody["type"] as? String else {
            return
        }
        
        print("WebView message: \\(messageBody)")
        
        switch type {
        case "LOGIN_ATTEMPTED":
            if let success = messageBody["success"] as? Bool, success {
                updateLoadingMessage("📸 Login submitted, waiting for redirect...")
                loginAttempts = 0 // Reset attempts on successful login
            }
            
        case "LOGIN_ATTEMPT_FAILED":
            if let attempt = messageBody["attempt"] as? Int {
                loginAttempts = attempt
                
                if loginAttempts < maxLoginAttempts {
                    updateLoadingMessage("📸 Login attempt \\(loginAttempts)/3 failed, retrying...")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.injectLoginScript()
                    }
                } else {
                    updateLoadingMessage("❌ Login failed after 3 attempts")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.showLoginFailedAlert()
                    }
                }
            }
            
        case "NO_LOGIN_FIELDS":
            updateLoadingMessage("📸 No login fields found, checking dashboard...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.injectCleanupScript()
            }
            
        case "LOGIN_FAILED":
            updateLoadingMessage("📸 Auto-login failed, showing manual login...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.showWebViewWhenReady()
            }
            
        case "DASHBOARD_READY":
            print("✅ Dashboard is fully ready - all JavaScript operations complete")
            isJavaScriptComplete = true
            isDashboardReady = true
            updateLoadingMessage("📸 Dashboard ready!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showWebView()
            }
            
        default:
            break
        }
    }
    
    private func showLoginFailedAlert() {
        let alert = UIAlertController(
            title: "Login Failed",
            message: "Unable to login after 3 attempts. Please check your username and password in settings.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Check Settings", style: .default) { [weak self] _ in
            self?.navigateToSettings()
        })
        
        alert.addAction(UIAlertAction(title: "Try Manual Login", style: .default) { [weak self] _ in
            self?.showWebViewWhenReady()
        })
        
        present(alert, animated: true)
    }
}
