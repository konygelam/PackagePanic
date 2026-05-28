import UIKit

final class StatisticsViewController: UIViewController {
    private let viewModel: StatisticsViewModel
    var onDismiss: (() -> Void)?
    
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
        label.text = "SHIFT COMPLETE"
        label.font = UIFont.systemFont(ofSize: 28, weight: .black)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let starsContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let statsContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let playAgainButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("NEW SHIFT", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = UIColor(red: 0.3, green: 0.85, blue: 0.4, alpha: 1.0)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let mainMenuButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("CLOCK OUT", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(statistics: GameStatistics) {
        self.viewModel = StatisticsViewModel(statistics: statistics)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        displayStatistics()
        setupActions()
        animateAppearance()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(ratingLabel)
        contentView.addSubview(starsContainer)
        contentView.addSubview(statsContainer)
        contentView.addSubview(playAgainButton)
        contentView.addSubview(mainMenuButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            ratingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            ratingLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            starsContainer.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 16),
            starsContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            statsContainer.topAnchor.constraint(equalTo: starsContainer.bottomAnchor, constant: 40),
            statsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            statsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            
            playAgainButton.topAnchor.constraint(equalTo: statsContainer.bottomAnchor, constant: 40),
            playAgainButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            playAgainButton.widthAnchor.constraint(equalToConstant: 200),
            playAgainButton.heightAnchor.constraint(equalToConstant: 50),
            
            mainMenuButton.topAnchor.constraint(equalTo: playAgainButton.bottomAnchor, constant: 16),
            mainMenuButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            mainMenuButton.widthAnchor.constraint(equalToConstant: 160),
            mainMenuButton.heightAnchor.constraint(equalToConstant: 40),
            mainMenuButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func displayStatistics() {
        ratingLabel.text = viewModel.workerRating
        ratingLabel.textColor = viewModel.ratingColor
        
        for i in 0..<5 {
            let star = UILabel()
            star.text = "★"
            star.font = UIFont.systemFont(ofSize: 32)
            star.textColor = i < viewModel.stars ? viewModel.ratingColor : UIColor.gray.withAlphaComponent(0.3)
            starsContainer.addArrangedSubview(star)
        }
        
        addStatRow(title: "PACKAGES DELIVERED", value: viewModel.deliveredCount)
        addStatRow(title: "PACKAGES LOST", value: viewModel.lostCount)
        addStatRow(title: "WRONG CONTAINER", value: viewModel.wrongContainerCount)
        addStatRow(title: "ACCURACY", value: viewModel.accuracy)
        addStatRow(title: "MAX COMBO", value: viewModel.maxCombo)
        addStatRow(title: "VIP DELIVERED", value: viewModel.vipDelivered)
        addStatRow(title: "QR SCANNED", value: viewModel.qrScanned)
        addStatRow(title: "SHIFT DURATION", value: viewModel.shiftDuration)
        addStatRow(title: "TOTAL SCORE", value: viewModel.totalScore, highlight: true)
    }
    
    private func addStatRow(title: String, value: String, highlight: Bool = false) {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: highlight ? 24 : 18, weight: .bold)
        valueLabel.textColor = highlight ? UIColor(red: 0.3, green: 0.85, blue: 0.4, alpha: 1.0) : .white
        valueLabel.textAlignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        row.addSubview(titleLabel)
        row.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            
            row.heightAnchor.constraint(equalToConstant: highlight ? 40 : 30)
        ])
        
        statsContainer.addArrangedSubview(row)
    }
    
    private func setupActions() {
        playAgainButton.addTarget(self, action: #selector(playAgainTapped), for: .touchUpInside)
        mainMenuButton.addTarget(self, action: #selector(mainMenuTapped), for: .touchUpInside)
    }
    
    @objc private func playAgainTapped() {
        dismiss(animated: true) { [weak self] in
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let navController = window.rootViewController as? UINavigationController else { return }
            
            let gameVC = GameViewController()
            navController.pushViewController(gameVC, animated: true)
            self?.onDismiss?()
        }
    }
    
    @objc private func mainMenuTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onDismiss?()
        }
    }
    
    private func animateAppearance() {
        titleLabel.alpha = 0
        ratingLabel.alpha = 0
        starsContainer.alpha = 0
        statsContainer.alpha = 0
        playAgainButton.alpha = 0
        mainMenuButton.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0.1) {
            self.titleLabel.alpha = 1
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.3) {
            self.ratingLabel.alpha = 1
            self.starsContainer.alpha = 1
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.5) {
            self.statsContainer.alpha = 1
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.7) {
            self.playAgainButton.alpha = 1
            self.mainMenuButton.alpha = 1
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
