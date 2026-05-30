import UIKit

final class NotificationPermissionViewController: UIViewController {
    var onAccept: (() -> Void)?
    var onSkip: (() -> Void)?
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "NotificationPermissionBackground")
        return imageView
    }()
    
    private let gradientView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let buttonsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()
    
    private let acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("YES, I WANT BONUSES!", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .black)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        return button
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("SKIP", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 21, weight: .heavy)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.38), for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        button.layer.cornerRadius = 24
        return button
    }()
    
    private var gradientLayer: CAGradientLayer?
    private var acceptGradientLayer: CAGradientLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupGradients()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(backgroundImageView)
        view.addSubview(gradientView)
        view.addSubview(buttonsContainer)
        buttonsContainer.addSubview(acceptButton)
        buttonsContainer.addSubview(skipButton)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            buttonsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 38),
            buttonsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -38),
            buttonsContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -42),
            
            acceptButton.topAnchor.constraint(equalTo: buttonsContainer.topAnchor),
            acceptButton.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor),
            acceptButton.trailingAnchor.constraint(equalTo: buttonsContainer.trailingAnchor),
            acceptButton.heightAnchor.constraint(equalToConstant: 56),
            
            skipButton.topAnchor.constraint(equalTo: acceptButton.bottomAnchor, constant: 14),
            skipButton.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor),
            skipButton.trailingAnchor.constraint(equalTo: buttonsContainer.trailingAnchor),
            skipButton.heightAnchor.constraint(equalToConstant: 52),
            skipButton.bottomAnchor.constraint(equalTo: buttonsContainer.bottomAnchor)
        ])
    }
    
    private func setupGradients() {
        if gradientLayer == nil {
            let gradient = CAGradientLayer()
            gradient.colors = [
                UIColor.black.withAlphaComponent(0.03).cgColor,
                UIColor.black.withAlphaComponent(0.03).cgColor,
                UIColor.black.withAlphaComponent(0.08).cgColor,
                UIColor(red: 0.05, green: 0.05, blue: 0.13, alpha: 0.22).cgColor,
                UIColor(red: 0.05, green: 0.05, blue: 0.13, alpha: 0.82).cgColor
            ]
            gradient.locations = [0, 0.25, 0.5, 0.75, 1.0]
            gradient.frame = gradientView.bounds
            gradientView.layer.insertSublayer(gradient, at: 0)
            gradientLayer = gradient
        } else {
            gradientLayer?.frame = gradientView.bounds
        }
        
        if acceptGradientLayer == nil {
            let acceptGradient = CAGradientLayer()
            acceptGradient.colors = [
                UIColor(red: 1.0, green: 0.74, blue: 0.17, alpha: 1.0).cgColor,
                UIColor(red: 1.0, green: 0.42, blue: 0.02, alpha: 1.0).cgColor
            ]
            acceptGradient.startPoint = CGPoint(x: 0.5, y: 0)
            acceptGradient.endPoint = CGPoint(x: 0.5, y: 1)
            acceptGradient.frame = acceptButton.bounds
            acceptGradient.cornerRadius = 12
            acceptButton.layer.insertSublayer(acceptGradient, at: 0)
            acceptGradientLayer = acceptGradient
            
            acceptButton.layer.borderWidth = 3
            acceptButton.layer.borderColor = UIColor(red: 0.63, green: 0.19, blue: 0.02, alpha: 1.0).cgColor
            acceptButton.layer.shadowColor = UIColor(red: 1.0, green: 0.55, blue: 0.0, alpha: 0.35).cgColor
            acceptButton.layer.shadowRadius = 10
            acceptButton.layer.shadowOffset = CGSize(width: 0, height: 4)
            acceptButton.layer.shadowOpacity = 1.0
        } else {
            acceptGradientLayer?.frame = acceptButton.bounds
        }
    }
    
    private func setupActions() {
        acceptButton.addTarget(self, action: #selector(acceptTapped), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
    }
    
    private func animateIn() {
        buttonsContainer.transform = CGAffineTransform(translationX: 0, y: 20)
        UIView.animate(withDuration: 0.55, delay: 0, options: .curveEaseOut) {
            self.buttonsContainer.alpha = 1.0
            self.buttonsContainer.transform = .identity
        }
    }
    
    @objc private func acceptTapped() {
        onAccept?()
    }
    
    @objc private func skipTapped() {
        onSkip?()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
