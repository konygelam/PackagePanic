import UIKit

final class MenuViewController: UIViewController {
    private let viewModel = MenuViewModel()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "PACKAGE\nPANIC"
        label.font = UIFont.systemFont(ofSize: 48, weight: .black)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sort fast. Ship faster."
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SELECT LEVEL", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let statisticsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("STATISTICS", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SETTINGS", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let privacyPolicyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Privacy Policy", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let conveyorAnimationView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var boxViews: [UIView] = []
    private var animationTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        startConveyorAnimation()
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .themeDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        applyTheme()
    }
    
    private func setupUI() {
        view.backgroundColor = ThemeManager.shared.backgroundColor
        
        view.addSubview(conveyorAnimationView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(playButton)
        view.addSubview(statisticsButton)
        view.addSubview(settingsButton)
        view.addSubview(privacyPolicyButton)
        
        NSLayoutConstraint.activate([
            conveyorAnimationView.topAnchor.constraint(equalTo: view.topAnchor),
            conveyorAnimationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            conveyorAnimationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            conveyorAnimationView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.35),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: conveyorAnimationView.bottomAnchor, constant: 30),
            
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.bottomAnchor.constraint(equalTo: statisticsButton.topAnchor, constant: -16),
            playButton.widthAnchor.constraint(equalToConstant: 220),
            playButton.heightAnchor.constraint(equalToConstant: 50),
            
            statisticsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statisticsButton.bottomAnchor.constraint(equalTo: settingsButton.topAnchor, constant: -12),
            statisticsButton.widthAnchor.constraint(equalToConstant: 180),
            statisticsButton.heightAnchor.constraint(equalToConstant: 40),
            
            settingsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            settingsButton.bottomAnchor.constraint(equalTo: privacyPolicyButton.topAnchor, constant: -20),
            settingsButton.widthAnchor.constraint(equalToConstant: 180),
            settingsButton.heightAnchor.constraint(equalToConstant: 40),
            
            privacyPolicyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            privacyPolicyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -22)
        ])
        
        addConveyorLines()
        applyTheme()
    }
    
    private func applyTheme() {
        view.backgroundColor = ThemeManager.shared.backgroundColor
        playButton.backgroundColor = ThemeManager.shared.primaryColor
    }
    
    private func addConveyorLines() {
        for i in 0..<10 {
            let line = UIView()
            line.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            line.translatesAutoresizingMaskIntoConstraints = false
            conveyorAnimationView.addSubview(line)
            
            NSLayoutConstraint.activate([
                line.leadingAnchor.constraint(equalTo: conveyorAnimationView.leadingAnchor, constant: 40),
                line.trailingAnchor.constraint(equalTo: conveyorAnimationView.trailingAnchor, constant: -40),
                line.heightAnchor.constraint(equalToConstant: 2),
                line.topAnchor.constraint(equalTo: conveyorAnimationView.topAnchor, constant: CGFloat(i * 40) + 20)
            ])
        }
    }
    
    private func setupActions() {
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        statisticsButton.addTarget(self, action: #selector(statisticsTapped), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        privacyPolicyButton.addTarget(self, action: #selector(privacyPolicyTapped), for: .touchUpInside)
    }
    
    @objc private func playTapped() {
        HapticsManager.shared.mediumImpact()
        let levelSelectVC = LevelSelectViewController()
        navigationController?.pushViewController(levelSelectVC, animated: true)
    }
    
    @objc private func statisticsTapped() {
        HapticsManager.shared.lightImpact()
        let statsVC = DetailedStatisticsViewController()
        navigationController?.pushViewController(statsVC, animated: true)
    }
    
    @objc private func settingsTapped() {
        HapticsManager.shared.lightImpact()
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @objc private func privacyPolicyTapped() {
        HapticsManager.shared.selection()
        let privacyVC = PrivacyPolicyViewController(addressString: AppConstants.privacyPolicyAddress)
        let navController = UINavigationController(rootViewController: privacyVC)
        present(navController, animated: true)
    }
    
    @objc private func themeDidChange() {
        applyTheme()
    }
    
    private func startConveyorAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            self?.spawnAnimatedBox()
        }
        spawnAnimatedBox()
    }
    
    private func spawnAnimatedBox() {
        let colors: [UIColor] = [
            UIColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1.0),
            UIColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1.0),
            UIColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1.0),
            UIColor(red: 0.95, green: 0.8, blue: 0.1, alpha: 1.0),
            UIColor(red: 0.6, green: 0.2, blue: 0.8, alpha: 1.0)
        ]
        
        let boxSize = CGFloat.random(in: 40...60)
        let box = UIView(frame: CGRect(
            x: CGFloat.random(in: 60...(view.bounds.width - 100)),
            y: -boxSize,
            width: boxSize,
            height: boxSize
        ))
        box.backgroundColor = colors.randomElement()
        box.layer.cornerRadius = 8
        box.layer.shadowColor = UIColor.black.cgColor
        box.layer.shadowOffset = CGSize(width: 2, height: 2)
        box.layer.shadowOpacity = 0.3
        box.layer.shadowRadius = 4
        
        conveyorAnimationView.addSubview(box)
        boxViews.append(box)
        
        UIView.animate(withDuration: 4.0, delay: 0, options: .curveLinear) {
            box.frame.origin.y = self.conveyorAnimationView.bounds.height + boxSize
        } completion: { _ in
            box.removeFromSuperview()
            self.boxViews.removeAll { $0 == box }
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        animationTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
}
