import UIKit

final class LevelSelectViewController: UIViewController {
    private let viewModel = LevelSelectViewModel()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "SELECT LEVEL"
        label.font = UIFont.systemFont(ofSize: 28, weight: .black)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let starsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("← BACK", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupActions()
        viewModel.delegate = self
        updateStarsLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refreshData()
        collectionView.reloadData()
        updateStarsLabel()
    }
    
    private func setupUI() {
        view.backgroundColor = ThemeManager.shared.backgroundColor
        
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(starsLabel)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            starsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            starsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: starsLabel.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(LevelCell.self, forCellWithReuseIdentifier: "LevelCell")
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }
    
    private func updateStarsLabel() {
        starsLabel.text = "★ \(viewModel.totalStars) / \(viewModel.maxStars)"
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension LevelSelectViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.levels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LevelCell", for: indexPath) as? LevelCell,
              let level = viewModel.levelAt(index: indexPath.item) else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: level)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 56) / 2
        return CGSize(width: width, height: 140)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectLevel(at: indexPath.item)
    }
}

extension LevelSelectViewController: LevelSelectViewModelDelegate {
    func didSelectLevel(_ level: LevelModel) {
        HapticsManager.shared.mediumImpact()
        let gameVC = GameViewController()
        gameVC.selectedLevel = level
        navigationController?.pushViewController(gameVC, animated: true)
    }
    
    func levelsDidUpdate() {
        collectionView.reloadData()
        updateStarsLabel()
    }
}

final class LevelCell: UICollectionViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let levelNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .black)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let levelNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let starsContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let lockIcon: UILabel = {
        let label = UILabel()
        label.text = "🔒"
        label.font = UIFont.systemFont(ofSize: 40)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private let bestScoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
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
        contentView.addSubview(containerView)
        containerView.addSubview(levelNumberLabel)
        containerView.addSubview(levelNameLabel)
        containerView.addSubview(starsContainer)
        containerView.addSubview(lockIcon)
        containerView.addSubview(bestScoreLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            levelNumberLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            levelNumberLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            levelNameLabel.topAnchor.constraint(equalTo: levelNumberLabel.bottomAnchor, constant: 4),
            levelNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            levelNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            
            starsContainer.topAnchor.constraint(equalTo: levelNameLabel.bottomAnchor, constant: 8),
            starsContainer.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            bestScoreLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            bestScoreLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            lockIcon.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            lockIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    func configure(with level: LevelModel) {
        levelNumberLabel.text = "\(level.id)"
        levelNameLabel.text = level.name
        
        starsContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if level.isUnlocked {
            lockIcon.isHidden = true
            levelNumberLabel.isHidden = false
            levelNameLabel.isHidden = false
            starsContainer.isHidden = false
            bestScoreLabel.isHidden = false
            containerView.alpha = 1.0
            
            for i in 0..<3 {
                let star = UILabel()
                star.text = "★"
                star.font = UIFont.systemFont(ofSize: 16)
                star.textColor = i < level.starsEarned ? 
                    UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0) : 
                    UIColor.gray.withAlphaComponent(0.3)
                starsContainer.addArrangedSubview(star)
            }
            
            if level.bestScore > 0 {
                bestScoreLabel.text = "Best: \(level.bestScore)"
            } else {
                bestScoreLabel.text = "Not played"
            }
            
            containerView.layer.borderWidth = 2
            containerView.layer.borderColor = ThemeManager.shared.primaryColor.withAlphaComponent(0.5).cgColor
        } else {
            lockIcon.isHidden = false
            levelNumberLabel.isHidden = true
            levelNameLabel.isHidden = true
            starsContainer.isHidden = true
            bestScoreLabel.isHidden = true
            containerView.alpha = 0.5
            containerView.layer.borderWidth = 0
        }
    }
}
