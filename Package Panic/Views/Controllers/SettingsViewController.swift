import UIKit

final class SettingsViewController: UIViewController {
    private let viewModel = SettingsViewModel()
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "SETTINGS"
        label.font = UIFont.systemFont(ofSize: 28, weight: .black)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("← BACK", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let themeLabel: UILabel = {
        let label = UILabel()
        label.text = "COLOR THEME"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let themeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.itemSize = CGSize(width: 60, height: 80)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let hapticsToggle: SettingsToggleView = {
        let toggle = SettingsToggleView()
        toggle.configure(title: "Haptic Feedback", icon: "📳")
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("RESET ALL DATA", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let resetWarningLabel: UILabel = {
        let label = UILabel()
        label.text = "This will delete all progress, statistics, and settings."
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupCollectionView()
        updateToggles()
        viewModel.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .themeDidChange, object: nil)
    }
    
    private func setupUI() {
        view.backgroundColor = ThemeManager.shared.backgroundColor
        
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(themeLabel)
        contentView.addSubview(themeCollectionView)
        contentView.addSubview(hapticsToggle)
        contentView.addSubview(resetButton)
        contentView.addSubview(resetWarningLabel)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            themeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            themeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            themeCollectionView.topAnchor.constraint(equalTo: themeLabel.bottomAnchor, constant: 12),
            themeCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            themeCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            themeCollectionView.heightAnchor.constraint(equalToConstant: 90),
            
            hapticsToggle.topAnchor.constraint(equalTo: themeCollectionView.bottomAnchor, constant: 30),
            hapticsToggle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            hapticsToggle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            hapticsToggle.heightAnchor.constraint(equalToConstant: 60),
            
            resetButton.topAnchor.constraint(equalTo: hapticsToggle.bottomAnchor, constant: 50),
            resetButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            resetButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            resetButton.heightAnchor.constraint(equalToConstant: 50),
            
            resetWarningLabel.topAnchor.constraint(equalTo: resetButton.bottomAnchor, constant: 12),
            resetWarningLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            resetWarningLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            resetWarningLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        
        hapticsToggle.onToggle = { [weak self] in
            self?.viewModel.toggleHaptics()
        }
    }
    
    private func setupCollectionView() {
        themeCollectionView.delegate = self
        themeCollectionView.dataSource = self
        themeCollectionView.register(ThemeCell.self, forCellWithReuseIdentifier: "ThemeCell")
    }
    
    private func updateToggles() {
        hapticsToggle.setOn(viewModel.isHapticsEnabled)
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func resetTapped() {
        viewModel.requestReset()
    }
    
    @objc private func themeDidChange() {
        view.backgroundColor = ThemeManager.shared.backgroundColor
        themeCollectionView.reloadData()
    }
    
    private func showResetConfirmation() {
        let alert = UIAlertController(
            title: "Reset All Data?",
            message: "This action cannot be undone. All your progress, statistics, and settings will be deleted.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            self?.viewModel.confirmReset()
        })
        
        present(alert, animated: true)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension SettingsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.allThemes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThemeCell", for: indexPath) as? ThemeCell else {
            return UICollectionViewCell()
        }
        
        let theme = viewModel.allThemes[indexPath.item]
        cell.configure(with: theme, isSelected: theme == viewModel.currentTheme)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let theme = viewModel.allThemes[indexPath.item]
        viewModel.setColorTheme(theme)
        HapticsManager.shared.lightImpact()
    }
}

extension SettingsViewController: SettingsViewModelDelegate {
    func settingsDidChange() {
        updateToggles()
        themeCollectionView.reloadData()
    }
    
    func didRequestResetConfirmation() {
        showResetConfirmation()
    }
    
    func didCompleteReset() {
        updateToggles()
        themeCollectionView.reloadData()
        
        let alert = UIAlertController(
            title: "Data Reset",
            message: "All data has been reset successfully.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

final class ThemeCell: UICollectionViewCell {
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 25
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let checkmark: UILabel = {
        let label = UILabel()
        label.text = "✓"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.addSubview(colorView)
        contentView.addSubview(nameLabel)
        colorView.addSubview(checkmark)
        
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 50),
            colorView.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 6),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            checkmark.centerXAnchor.constraint(equalTo: colorView.centerXAnchor),
            checkmark.centerYAnchor.constraint(equalTo: colorView.centerYAnchor)
        ])
    }
    
    func configure(with theme: AppColorTheme, isSelected: Bool) {
        colorView.backgroundColor = theme.primaryColor
        nameLabel.text = theme.rawValue.capitalized
        checkmark.isHidden = !isSelected
        
        if isSelected {
            colorView.layer.borderWidth = 3
            colorView.layer.borderColor = UIColor.white.cgColor
        } else {
            colorView.layer.borderWidth = 0
        }
    }
}

final class SettingsToggleView: UIView {
    var onToggle: (() -> Void)?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let toggle: UISwitch = {
        let s = UISwitch()
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(containerView)
        containerView.addSubview(iconLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(toggle)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            iconLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            toggle.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            toggle.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        toggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
    }
    
    func configure(title: String, icon: String) {
        titleLabel.text = title
        iconLabel.text = icon
    }
    
    func setOn(_ isOn: Bool) {
        toggle.isOn = isOn
        toggle.onTintColor = ThemeManager.shared.primaryColor
    }
    
    @objc private func toggleChanged() {
        onToggle?()
    }
}
