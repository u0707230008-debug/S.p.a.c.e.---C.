import SwiftUI
import SpriteKit
import CoreImage
class GameScene: SKScene {
    var player: SKSpriteNode!
    var enemies: [SKNode] = []
    var scoreLabel: SKLabelNode!
    var timerLabel: SKLabelNode!
    var score = 0
    var gameOver = false
    var level = 2000
    var enemySpawnRate: TimeInterval = 2.0
    var levelDuration: TimeInterval = 30.0
    var levelTimer: Timer?
    var timeRemaining: TimeInterval = 30.0
    
    override func didMove(to view: SKView) {
        
        
        // Créer le vaisseau spatial
        player = createRocket()
        player.position = CGPoint(x: size.width / 2, y: 100)
        addChild(player)
        // Créer le label de score
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 50)
        scoreLabel.fontColor = .white
        addChild(scoreLabel)
        
        // Créer le label de timer
        timerLabel = SKLabelNode(text: "Time: \(Int(timeRemaining))")
        timerLabel.position = CGPoint(x: size.width / 2, y: size.height - 100)
        timerLabel.fontColor = .white
        addChild(timerLabel)
        
        // Démarrer le niveau
        startLevel()
    }
    
    func createRocket() -> SKSpriteNode {
        let IsTurquoise = Bool.random()
        let rocketTexture = SKTexture(imageNamed: IsTurquoise ? "RocketImageName" : "RocketImageName2") // Replace with your image name
        let rocket = SKSpriteNode(texture: rocketTexture)
        
        // Set the size of the rocket if needed
        rocket.size = CGSize(width: 40, height: 120) // Adjust size as necessary
        
        // Rotate the rocket to point upwards
        return rocket
    }

    func createOvni() -> SKSpriteNode {
        let ovniTexture = SKTexture(imageNamed: "OvniTexture") // Replace with your image name
        let ovni = SKSpriteNode(texture: ovniTexture)
        
        // Set the size of the rocket if needed
        ovni.size = CGSize(width: 30, height: 60) // Adjust size as necessary
        
        return ovni
    }
    func createEnemy() -> SKSpriteNode {
        let IsSpeedy = Bool.random()
        let enemyTexture = SKTexture(imageNamed: IsSpeedy ? "EnemyTexture" : "EnemyTexture2") // Replace with your image name
        let enemy = SKSpriteNode(texture: enemyTexture)
        
        // Set the size of the rocket if needed
        enemy.size = CGSize(width: 30, height: 60) // Adjust size as necessary
        
        return enemy
    }
    
    
 
    func createAsteroid() -> SKSpriteNode {
        let IsBlue = Bool.random()
        let asteroidTexture = SKTexture(imageNamed: IsBlue ? "PlanetTexture" : "PlanetTexture2") // Replace with your image name
        let asteroid = SKSpriteNode(texture: asteroidTexture)
        
        // Set the size of the rocket if needed
        asteroid.size = CGSize(width: 60, height: 60) // Adjust size as necessary
        
        return asteroid
    }
    
    func startLevel() {
        // Réinitialiser les ennemis et le score
        enemies.forEach { $0.removeFromParent() }
        enemies.removeAll()
         
        scoreLabel.text = "Score: \(score)"
        
        // Réinitialiser le temps restant
        timeRemaining = levelDuration
        timerLabel.text = "Time: \(Int(timeRemaining))"
        
        // Augmenter le taux de génération d'ennemis
        enemySpawnRate = max(1.1, enemySpawnRate * 0.01) // Réduit le temps d'attente entre les ennemis
        spawnEnemies()
        
        // Démarrer le timer pour le niveau
        levelTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        timeRemaining -= 1
        timerLabel.text = "Time: \(Int(timeRemaining))"
        
        if timeRemaining <= 0 {
            levelTimer?.invalidate()
            nextLevel()
        }
    }
    
    @objc func nextLevel() {
        level += 1
        score += 10
        print("Niveau \(level) commencé!")
        startLevel()
    }
    
    func spawnEnemies() {
        let spawnAction = SKAction.run {
            // Créer un ennemi ou un astéroïde aléatoirement
            let isAsteroid = Bool.random() // 50% de chance de générer un astéroïde
            let node = isAsteroid ? self.createAsteroid() : self.createEnemy()
            let isOvni = Bool.random()
            let xPosition = CGFloat.random(in: 0...self.size.width)
            node.position = CGPoint(x: xPosition, y: self.size.height)
            self.addChild(node)
            self.enemies.append(node)
            
            // Définir la vitesse de déplacement
            let moveDuration: TimeInterval = isAsteroid ? 3.0 : 1.5 // Astéroïdes plus lents
            let moveAction = SKAction.moveTo(y: -40, duration: moveDuration)
            node.run(moveAction) {
                node.removeFromParent()
                self.enemies.removeAll { $0 == node }
            }
        }
        let waitAction = SKAction.wait(forDuration: enemySpawnRate)
        let sequence = SKAction.sequence([spawnAction, waitAction])
        run(SKAction.repeatForever(sequence))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        player.position.x = max(min(touchLocation.x, size.width), 0)
    }
    
     override func update(_ currentTime: TimeInterval) {
        if gameOver { return }
        
        for enemy in enemies {
            if enemy.parent != nil && enemy.frame.intersects(player.frame) {
                gameOver = true
                levelTimer?.invalidate()
                print("Game Over! Final Score: \(score)")
                showRestartButton()
            }
        }
    }

    
    func showRestartButton() {
        let restartLabel = SKLabelNode(text: "Recommencer")
        restartLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        restartLabel.fontColor = .white
        restartLabel.name = "restart"
        addChild(restartLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        // Vérifier si le bouton "Recommencer" a été touché
        if let node = self.atPoint(touchLocation) as? SKLabelNode, node.name == "restart" {
            restartGame()
        }
    }
    
    func restartGame() {
        gameOver = false
        level = 1
        score = 0
        enemies.forEach { $0.removeFromParent() }
        enemies.removeAll()
        let newScene = GameScene(size: CGSize(width: 900, height: 600))
        newScene.scaleMode = .aspectFill
        self.view?.presentScene(newScene)
    }
}

struct GameView: UIViewRepresentable {
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        let scene = GameScene(size: CGSize(width: 900, height: 600))
        scene.scaleMode = .aspectFit
        skView.presentScene(scene)
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        // Mettre à jour la vue si nécessaire
    }
}

struct ContentView: View {
    var body: some View {
        GameView()
            .frame(width: 900, height: 600)
    }
}

