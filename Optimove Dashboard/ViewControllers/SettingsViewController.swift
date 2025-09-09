import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let usernameTextField = UITextField()
    private let passwordTextField = UITextField()
    private let siteUrlTextField = UITextField()
    private let eyeButton = UIButton()
    private let saveButton = UIButton()
    private let cancelButton = UIButton()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let successOverlay = UIView()
    private let successMessageView = UIView()
    private let successIconImageView = UIImageView()
    private let successTitleLabel = UILabel()
    private let successSubtitleLabel = UILabel()
    
    // MARK: - Properties
    private var isFirstLaunch = false
    private var isPasswordVisible = false
    private var isSaving = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadExistingSettings()
        
        // Check if this is first launch
        isFirstLaunch = !StorageManager.shared.hasSettings()
        updateUIForLaunchType()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
        
        // Configure scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Configure title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Configure subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)
        
        // Configure text fields
        setupTextField(usernameTextField, placeholder: "Enter your username")
        setupTextField(passwordTextField, placeholder: "Enter your password")
        setupTextField(siteUrlTextField, placeholder: "e.g., mycompany.optimove.net")
        
        passwordTextField.isSecureTextEntry = true
        siteUrlTextField.keyboardType = .URL
        siteUrlTextField.autocapitalizationType = .none
        
        // Add text fields to content view
        contentView.addSubview(usernameTextField)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(siteUrlTextField)
        
        // Configure eye button
        eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        eyeButton.tintColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
        eyeButton.translatesAutoresizingMaskIntoConstraints = false
        eyeButton.addTarget(self, action: #selector(eyeButtonTapped), for: .touchUpInside)
        contentView.addSubview(eyeButton)
        
        // Configure save button
        saveButton.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        saveButton.layer.cornerRadius = 10
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        contentView.addSubview(saveButton)
        
        // Configure cancel button
        cancelButton.backgroundColor = .clear
        cancelButton.layer.cornerRadius = 10
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        cancelButton.setTitleColor(UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0), for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        contentView.addSubview(cancelButton)
        
        // Configure loading indicator
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(loadingIndicator)
        
        // Configure success overlay
        successOverlay.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        successOverlay.isHidden = true
        successOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(successOverlay)
        
        // Configure success message view
        successMessageView.backgroundColor = .white
        successMessageView.layer.cornerRadius = 15
        successMessageView.translatesAutoresizingMaskIntoConstraints = false
        successOverlay.addSubview(successMessageView)
        
        // Configure success icon
        successIconImageView.image = UIImage(systemName: "checkmark.circle.fill")
        successIconImageView.tintColor = UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 1.0)
        successIconImageView.translatesAutoresizingMaskIntoConstraints = false
        successMessageView.addSubview(successIconImageView)
        
        // Configure success labels
        successTitleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        successTitleLabel.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        successTitleLabel.textAlignment = .center
        successTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        successMessageView.addSubview(successTitleLabel)
        
        successSubtitleLabel.font = UIFont.systemFont(ofSize: 16)
        successSubtitleLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
        successSubtitleLabel.textAlignment = .center
        successSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        successMessageView.addSubview(successSubtitleLabel)
    }
    
    private func setupTextField(_ textField: UITextField, placeholder: String) {
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1.0).cgColor
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.placeholder = placeholder
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        // Add padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 50))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        if textField != passwordTextField {
            let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 50))
            textField.rightView = rightPaddingView
            textField.rightViewMode = .always
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 100),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Username field
            usernameTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            usernameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            usernameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Password field
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: eyeButton.leadingAnchor, constant: -10),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Eye button
            eyeButton.centerYAnchor.constraint(equalTo: passwordTextField.centerYAnchor),
            eyeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            eyeButton.widthAnchor.constraint(equalToConstant: 50),
            eyeButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Site URL field
            siteUrlTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            siteUrlTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            siteUrlTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            siteUrlTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Save button
            saveButton.topAnchor.constraint(equalTo: siteUrlTextField.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Cancel button
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 10),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Loading indicator
            loadingIndicator.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),
            loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingIndicator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // Success overlay
            successOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            successOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            successOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            successOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Success message view
            successMessageView.centerXAnchor.constraint(equalTo: successOverlay.centerXAnchor),
            successMessageView.centerYAnchor.constraint(equalTo: successOverlay.centerYAnchor),
            successMessageView.widthAnchor.constraint(equalToConstant: 250),
            successMessageView.heightAnchor.constraint(equalToConstant: 150),
            
            // Success icon
            successIconImageView.topAnchor.constraint(equalTo: successMessageView.topAnchor, constant: 20),
            successIconImageView.centerXAnchor.constraint(equalTo: successMessageView.centerXAnchor),
            successIconImageView.widthAnchor.constraint(equalToConstant: 50),
            successIconImageView.heightAnchor.constraint(equalToConstant: 50),
            
            // Success title
            successTitleLabel.topAnchor.constraint(equalTo: successIconImageView.bottomAnchor, constant: 15),
            successTitleLabel.leadingAnchor.constraint(equalTo: successMessageView.leadingAnchor, constant: 20),
            successTitleLabel.trailingAnchor.constraint(equalTo: successMessageView.trailingAnchor, constant: -20),
            
            // Success subtitle
            successSubtitleLabel.topAnchor.constraint(equalTo: successTitleLabel.bottomAnchor, constant: 10),
            successSubtitleLabel.leadingAnchor.constraint(equalTo: successMessageView.leadingAnchor, constant: 20),
            successSubtitleLabel.trailingAnchor.constraint(equalTo: successMessageView.trailingAnchor, constant: -20),
        ])
    }
    
    private func updateUIForLaunchType() {
        if isFirstLaunch {
            titleLabel.text = "Welcome to Optimove Dashboard"
            subtitleLabel.text = "Please enter your credentials to get started"
            saveButton.setTitle("Get Started", for: .normal)
            cancelButton.isHidden = true
            successTitleLabel.text = "Settings Saved!"
            successSubtitleLabel.text = "Taking you to your dashboard..."
        } else {
            titleLabel.text = "Settings"
            subtitleLabel.text = "Update your dashboard credentials"
            saveButton.setTitle("Save Settings", for: .normal)
            cancelButton.setTitle("Back to Dashboard", for: .normal)
            cancelButton.isHidden = false
            successTitleLabel.text = "Settings Updated!"
            successSubtitleLabel.text = "Returning to dashboard..."
        }
    }
    
    private func loadExistingSettings() {
        loadingIndicator.startAnimating()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let settings = StorageManager.shared.loadSettings()
            
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                
                if let settings = settings {
                    self?.usernameTextField.text = settings.username
                    self?.passwordTextField.text = settings.password
                    self?.siteUrlTextField.text = settings.siteUrl
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc private func eyeButtonTapped() {
        isPasswordVisible.toggle()
        passwordTextField.isSecureTextEntry = !isPasswordVisible
        
        let imageName = isPasswordVisible ? "eye.slash" : "eye"
        eyeButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @objc private func saveButtonTapped() {
        guard !isSaving else { return }
        
        // Validate inputs
        guard let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let siteUrl = siteUrlTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !username.isEmpty, !password.isEmpty, !siteUrl.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields")
            return
        }
        
        // Basic URL validation
        let urlPattern = "^[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
        let urlTest = NSPredicate(format: "SELF MATCHES %@", urlPattern)
        guard urlTest.evaluate(with: siteUrl) else {
            showAlert(title: "Error", message: "Please enter a valid site URL (e.g., mycompany.optimove.net)")
            return
        }
        
        // Start saving
        isSaving = true
        updateSaveButtonState()
        
        let settings = UserSettings(username: username, password: password, siteUrl: siteUrl)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            StorageManager.shared.saveSettings(settings)
            
            DispatchQueue.main.async {
                self?.isSaving = false
                self?.updateSaveButtonState()
                self?.showSuccessMessage()
            }
        }
    }
    
    @objc private func cancelButtonTapped() {
        print("🔄 Cancel button tapped - navigating back without saving changes")
        
        // Check if we have existing settings to navigate back to dashboard
        if StorageManager.shared.hasSettings() {
            // Navigate back to dashboard without saving changes
            navigateBackToDashboard()
        } else {
            // If no settings exist, we can't navigate to dashboard, so just pop
            print("⚠️ No existing settings found, popping view controller")
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func updateSaveButtonState() {
        if isSaving {
            saveButton.isEnabled = false
            saveButton.alpha = 0.6
            loadingIndicator.startAnimating()
        } else {
            saveButton.isEnabled = true
            saveButton.alpha = 1.0
            loadingIndicator.stopAnimating()
        }
        
        usernameTextField.isEnabled = !isSaving
        passwordTextField.isEnabled = !isSaving
        siteUrlTextField.isEnabled = !isSaving
        eyeButton.isEnabled = !isSaving
    }
    
    private func showSuccessMessage() {
        successOverlay.isHidden = false
        successOverlay.alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            self.successOverlay.alpha = 1
        }
        
        // Auto-navigate to dashboard after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.navigateToDashboard()
        }
    }
    
    private func navigateToDashboard() {
        let dashboardVC = DashboardViewController()
        
        if isFirstLaunch {
            // Replace the entire navigation stack
            navigationController?.setViewControllers([dashboardVC], animated: true)
        } else {
            // Navigate back to dashboard
            navigationController?.pushViewController(dashboardVC, animated: true)
        }
    }
    
    private func navigateBackToDashboard() {
        guard let navController = navigationController else {
            print("❌ No navigation controller found")
            return
        }
        
        print("🔍 Current navigation stack has \(navController.viewControllers.count) view controllers:")
        for (index, vc) in navController.viewControllers.enumerated() {
            print("  [\(index)]: \(type(of: vc))")
        }
        
        // The most common case: Dashboard -> Settings -> Cancel
        // In this case, we just pop back to the previous view controller (which should be the dashboard)
        if navController.viewControllers.count >= 2 {
            let previousVC = navController.viewControllers[navController.viewControllers.count - 2]
            if previousVC is DashboardViewController {
                print("✅ Found dashboard as previous view controller - popping back")
                navigationController?.popViewController(animated: true)
                return
            }
        }
        
        // Fallback: Look for any DashboardViewController in the stack
        if let dashboardVC = navController.viewControllers.first(where: { $0 is DashboardViewController }) {
            print("✅ Found existing dashboard in stack - popping to it")
            navigationController?.popToViewController(dashboardVC, animated: true)
            return
        }
        
        // This should not happen in normal flow, but handle it gracefully
        print("⚠️ No existing dashboard found - this shouldn't happen in normal flow")
        if navController.viewControllers.count > 1 {
            print("🔄 Popping back as fallback")
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
