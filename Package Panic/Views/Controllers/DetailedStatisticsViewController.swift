import UIKit

final class DetailedStatisticsViewController: UIViewController {
    private let viewModel = DetailedStatisticsViewModel()
    
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
        label.text = "STATISTICS"
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
    
    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Overall", "By Level"])
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    private let overallStatsContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let levelStatsContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isHidden = true
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        displayOverallStats()
        displayLevelStats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refresh()
        refreshDisplay()
    }
    
    private func setupUI() {
        view.backgroundColor = ThemeManager.shared.backgroundColor
        
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(segmentedControl)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(overallStatsContainer)
        contentView.addSubview(levelStatsContainer)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            segmentedControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            scrollView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            overallStatsContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            overallStatsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            overallStatsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            levelStatsContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            levelStatsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            levelStatsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            levelStatsContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    private func displayOverallStats() {
        overallStatsContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        addStatCard(to: overallStatsContainer, title: "PACKAGES DELIVERED", value: viewModel.totalPackagesDelivered, icon: "📦")
        addStatCard(to: overallStatsContainer, title: "PACKAGES LOST", value: viewModel.totalPackagesLost, icon: "❌")
        addStatCard(to: overallStatsContainer, title: "WRONG CONTAINER", value: viewModel.totalWrongContainer, icon: "🔄")
        addStatCard(to: overallStatsContainer, title: "OVERALL ACCURACY", value: viewModel.overallAccuracy, icon: "🎯")
        addStatCard(to: overallStatsContainer, title: "VIP DELIVERED", value: viewModel.totalVIPDelivered, icon: "⭐")
        addStatCard(to: overallStatsContainer, title: "QR SCANNED", value: viewModel.totalQRScanned, icon: "📱")
        addStatCard(to: overallStatsContainer, title: "HIGHEST COMBO", value: viewModel.highestCombo, icon: "🔥")
        addStatCard(to: overallStatsContainer, title: "TOTAL PLAY TIME", value: viewModel.totalPlayTime, icon: "⏱")
        addStatCard(to: overallStatsContainer, title: "GAMES PLAYED", value: viewModel.totalGamesPlayed, icon: "🎮")
        addStatCard(to: overallStatsContainer, title: "GAMES COMPLETED", value: viewModel.totalGamesCompleted, icon: "✅")
        addStatCard(to: overallStatsContainer, title: "COMPLETION RATE", value: viewModel.completionRate, icon: "📊")
        
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 20).isActive = true
        overallStatsContainer.addArrangedSubview(spacer)
    }
    
    private func displayLevelStats() {
        levelStatsContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for i in 0..<viewModel.levels.count {
            guard let level = viewModel.levelAt(index: i) else { continue }
            addLevelStatCard(level: level)
        }
    }
    
    private func addStatCard(to container: UIStackView, title: String, value: String, icon: String) {
        let card = UIView()
        card.backgroundColor = ThemeManager.shared.cardBackgroundColor
        card.layer.cornerRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = UIFont.systemFont(ofSize: 24)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        valueLabel.textColor = ThemeManager.shared.primaryColor
        valueLabel.textAlignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(iconLabel)
        card.addSubview(titleLabel)
        card.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 60),
            
            iconLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
        
        container.addArrangedSubview(card)
    }
    
    private func addLevelStatCard(level: LevelModel) {
        let card = UIView()
        card.backgroundColor = ThemeManager.shared.cardBackgroundColor
        card.layer.cornerRadius = 16
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        let levelLabel = UILabel()
        levelLabel.text = "Level \(level.id): \(level.name)"
        levelLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        levelLabel.textColor = .white
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let starsLabel = UILabel()
        var starsText = ""
        for i in 0..<3 {
            starsText += i < level.starsEarned ? "★" : "☆"
        }
        starsLabel.text = starsText
        starsLabel.font = UIFont.systemFont(ofSize: 16)
        starsLabel.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        starsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let statsStack = UIStackView()
        statsStack.axis = .vertical
        statsStack.spacing = 8
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(headerView)
        headerView.addSubview(levelLabel)
        headerView.addSubview(starsLabel)
        card.addSubview(statsStack)
        
        if level.isUnlocked {
            let stats = viewModel.statisticsForLevel(level.id)
            
            addMiniStat(to: statsStack, label: "Best Score", value: "\(level.bestScore)")
            addMiniStat(to: statsStack, label: "Best Accuracy", value: String(format: "%.1f%%", level.bestAccuracy))
            addMiniStat(to: statsStack, label: "Times Played", value: "\(level.timesPlayed)")
            addMiniStat(to: statsStack, label: "Times Completed", value: "\(level.timesCompleted)")
            
            if let s = stats {
                addMiniStat(to: statsStack, label: "Total Delivered", value: "\(s.totalDelivered)")
                addMiniStat(to: statsStack, label: "Play Time", value: viewModel.formattedPlayTime(for: level.id))
            }
        } else {
            let lockedLabel = UILabel()
            lockedLabel.text = "🔒 Locked"
            lockedLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            lockedLabel.textColor = UIColor.white.withAlphaComponent(0.5)
            lockedLabel.translatesAutoresizingMaskIntoConstraints = false
            statsStack.addArrangedSubview(lockedLabel)
        }
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            headerView.heightAnchor.constraint(equalToConstant: 24),
            
            levelLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            levelLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            starsLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            starsLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            statsStack.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12),
            statsStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            statsStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            statsStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        
        levelStatsContainer.addArrangedSubview(card)
    }
    
    private func addMiniStat(to stack: UIStackView, label: String, value: String) {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        
        let labelView = UILabel()
        labelView.text = label
        labelView.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        labelView.textColor = UIColor.white.withAlphaComponent(0.6)
        labelView.translatesAutoresizingMaskIntoConstraints = false
        
        let valueView = UILabel()
        valueView.text = value
        valueView.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        valueView.textColor = .white
        valueView.textAlignment = .right
        valueView.translatesAutoresizingMaskIntoConstraints = false
        
        row.addSubview(labelView)
        row.addSubview(valueView)
        
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: 20),
            labelView.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            labelView.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            valueView.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            valueView.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])
        
        stack.addArrangedSubview(row)
    }
    
    private func refreshDisplay() {
        displayOverallStats()
        displayLevelStats()
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func segmentChanged() {
        let showOverall = segmentedControl.selectedSegmentIndex == 0
        overallStatsContainer.isHidden = !showOverall
        levelStatsContainer.isHidden = showOverall
        
        if showOverall {
            overallStatsContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
