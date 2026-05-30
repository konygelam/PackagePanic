import UIKit
import SpriteKit
import GameplayKit

final class GameViewController: UIViewController {
    var selectedLevel: LevelModel?
    private var gameScene: GameScene?
    private var skView: SKView!
    private var hasSetupScene = false
    
    override func loadView() {
        skView = SKView()
        skView.backgroundColor = .black
        view = skView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !hasSetupScene && skView.bounds.size.width > 0 && skView.bounds.size.height > 0 {
            hasSetupScene = true
            setupGameView()
        }
    }
    
    private func setupGameView() {
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        scene.gameDelegate = self
        scene.selectedLevel = selectedLevel
        gameScene = scene
        
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.presentScene(scene)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension GameViewController: GameSceneDelegate {
    func gameSceneDidRequestPause() {
    }
    
    func gameSceneDidEnd(statistics: GameStatistics, levelId: Int, completed: Bool) {
        if let level = selectedLevel {
            DataManager.shared.updateLevelProgress(
                levelId: level.id,
                score: statistics.totalScore,
                accuracy: statistics.accuracy,
                completed: completed
            )
            DataManager.shared.updateLevelStatistics(levelId: level.id, gameStats: statistics)
        }
        
        let statisticsVC = StatisticsViewController(statistics: statistics)
        statisticsVC.modalPresentationStyle = .fullScreen
        statisticsVC.onDismiss = { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
        present(statisticsVC, animated: true)
    }
}
