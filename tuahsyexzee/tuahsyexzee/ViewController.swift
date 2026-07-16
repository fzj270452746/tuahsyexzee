import UIKit

// MARK: - Core State Model
class ChthonicRealmState {
    static let shared = ChthonicRealmState()
    
    var gloomCounter: Int = 0               // current day (0..400)
    var vigorPool: Int = 100                // health/stamina
    var hoardCache: [String: Int] = ["provisions": 10, "goldNuggets": 0, "mysticShard": 0]
    var baneAffliction: String?             // negative status
    var boonBlessing: String?               // positive status
    var isKingAwake: Bool { gloomCounter >= 400 }
    
    func advanceDay() -> Bool {
        guard !isKingAwake && vigorPool > 0 else { return false }
        gloomCounter += 1
        // daily consumption
        consumeProvision()
        // random events may happen
        return true
    }
    
    private func consumeProvision() {
        if let provisions = hoardCache["provisions"], provisions > 0 {
            hoardCache["provisions"] = provisions - 1
        } else {
            vigorPool -= 5  // starvation
        }
    }
    
    func reset() {
        gloomCounter = 0
        vigorPool = 100
        hoardCache = ["provisions": 10, "goldNuggets": 0, "mysticShard": 0]
        baneAffliction = nil
        boonBlessing = nil
    }
}

// MARK: - Event Engine
class MurmurEventOrchestrator {
    static let shared = MurmurEventOrchestrator()
    
    func generateRandomEncounter() -> (title: String, description: String, effects: (ChthonicRealmState) -> Void) {
        let seed = Int.random(in: 0...9)
        switch seed {
        case 0:
            return ("Glimmering Vein", "You stumble upon a vein of glow-stones. Gain 3 gold nuggets.", { state in
                state.hoardCache["goldNuggets"] = (state.hoardCache["goldNuggets"] ?? 0) + 3
            })
        case 1:
            return ("Shadow Leech", "A parasitic shadow drains your vigor. Lose 10 health.", { state in
                state.vigorPool = max(0, state.vigorPool - 10)
            })
        case 2:
            return ("Fungal Cache", "Edible fungi found! Provisions +5.", { state in
                state.hoardCache["provisions"] = (state.hoardCache["provisions"] ?? 0) + 5
            })
        case 3:
            return ("Whispering Echo", "An echo reveals a hidden passage. You feel refreshed. Vigor +10.", { state in
                state.vigorPool = min(100, state.vigorPool + 10)
            })
        case 4:
            return ("Cave-in", "Rocks block your path. You lose 1 day escaping.", { state in
                // just a narrative, no real loss except time
            })
        case 5:
            return ("Mystic Shard", "A shard of ancient power. +1 mystic shard.", { state in
                state.hoardCache["mysticShard"] = (state.hoardCache["mysticShard"] ?? 0) + 1
            })
        case 6:
            return ("Bane of Despair", "A curse weakens you. Vigor -5 each day for 3 days.", { state in
                state.baneAffliction = "despair"
                state.vigorPool = max(0, state.vigorPool - 5)
            })
        case 7:
            return ("Boon of Light", "A ray of light blesses you. Vigor +15 and provisions +2.", { state in
                state.vigorPool = min(100, state.vigorPool + 15)
                state.hoardCache["provisions"] = (state.hoardCache["provisions"] ?? 0) + 2
            })
        case 8:
            return ("Lost Memories", "You recall a fragment of the king's lore. No immediate effect.", { _ in })
        default:
            return ("Empty Corridor", "Nothing but dust and silence.", { _ in })
        }
    }
}

// MARK: - Alert View (added as subview, not on window)
class VignetteAlertView: UIView {
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemBackground
        v.layer.cornerRadius = 16
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.3
        v.layer.shadowRadius = 8
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.boldSystemFont(ofSize: 20)
        l.textAlignment = .center
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let descLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 16)
        l.textAlignment = .center
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let actionButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Acknowledge", for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    var onDismiss: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descLabel)
        containerView.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            descLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            actionButton.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 24),
            actionButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24),
            actionButton.widthAnchor.constraint(equalToConstant: 120),
            actionButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        actionButton.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
    }
    
    func configure(title: String, description: String) {
        titleLabel.text = title
        descLabel.text = description
    }
    
    @objc private func dismissAlert() {
        removeFromSuperview()
        onDismiss?()
    }
}

// MARK: - Main Game View (all UI and core logic)
class PenumbraGameView: UIView {
    private let state = ChthonicRealmState.shared
    private let eventEngine = MurmurEventOrchestrator.shared
    
    // UI elements
    private let dayCounterLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.monospacedDigitSystemFont(ofSize: 18, weight: .medium)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let progressView: UIProgressView = {
        let p = UIProgressView(progressViewStyle: .default)
        p.trackTintColor = .systemGray5
        p.progressTintColor = .systemIndigo
        p.translatesAutoresizingMaskIntoConstraints = false
        return p
    }()
    
    private let vigorLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 16)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let provisionsLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 16)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let statusLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14)
        l.textAlignment = .center
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let exploreButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Initiate Foray", for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        b.backgroundColor = .systemBlue
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let restButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Repose Awhile", for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        b.backgroundColor = .systemGreen
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let consumeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Partake Sustenance", for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        b.backgroundColor = .systemOrange
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let resetButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Reset Chronicle", for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        b.setTitleColor(.systemRed, for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private var alertView: VignetteAlertView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        updateUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        let stack = UIStackView(arrangedSubviews: [dayCounterLabel, progressView, vigorLabel, provisionsLabel, statusLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        addSubview(exploreButton)
        addSubview(restButton)
        addSubview(consumeButton)
        addSubview(resetButton)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            exploreButton.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 30),
            exploreButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            exploreButton.widthAnchor.constraint(equalToConstant: 200),
            exploreButton.heightAnchor.constraint(equalToConstant: 50),
            
            restButton.topAnchor.constraint(equalTo: exploreButton.bottomAnchor, constant: 16),
            restButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            restButton.widthAnchor.constraint(equalToConstant: 200),
            restButton.heightAnchor.constraint(equalToConstant: 50),
            
            consumeButton.topAnchor.constraint(equalTo: restButton.bottomAnchor, constant: 16),
            consumeButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            consumeButton.widthAnchor.constraint(equalToConstant: 200),
            consumeButton.heightAnchor.constraint(equalToConstant: 50),
            
            resetButton.topAnchor.constraint(equalTo: consumeButton.bottomAnchor, constant: 30),
            resetButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            resetButton.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        exploreButton.addTarget(self, action: #selector(initiateForay), for: .touchUpInside)
        restButton.addTarget(self, action: #selector(reposeAwhile), for: .touchUpInside)
        consumeButton.addTarget(self, action: #selector(partakeSustenance), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetChronicle), for: .touchUpInside)
    }
    
    private func updateUI() {
        let day = state.gloomCounter
        let total = 400
        let progress = Float(day) / Float(total)
        dayCounterLabel.text = "Day \(day) of \(total)"
        progressView.progress = progress
        
        vigorLabel.text = "Vigor: \(state.vigorPool)"
        provisionsLabel.text = "Provisions: \(state.hoardCache["provisions"] ?? 0)  |  Gold: \(state.hoardCache["goldNuggets"] ?? 0)  |  Shard: \(state.hoardCache["mysticShard"] ?? 0)"
        
        var status = ""
        if let bane = state.baneAffliction { status += "Bane: \(bane)  " }
        if let boon = state.boonBlessing { status += "Boon: \(boon)  " }
        if state.isKingAwake {
            status = "👑 The King Awakens! You have fulfilled your vigil."
        } else if state.vigorPool <= 0 {
            status = "💀 You have perished in the dark..."
        } else {
            status = status.isEmpty ? "All is quiet..." : status
        }
        statusLabel.text = status
        
        // disable buttons if game over
        let gameOver = state.isKingAwake || state.vigorPool <= 0
        exploreButton.isEnabled = !gameOver
        restButton.isEnabled = !gameOver
        consumeButton.isEnabled = !gameOver
    }
    
    // MARK: - Actions
    @objc private func initiateForay() {
        guard state.vigorPool > 0 && !state.isKingAwake else { return }
        // consume some vigor for exploration
        state.vigorPool = max(0, state.vigorPool - 5)
        // advance day
        let success = state.advanceDay()
        if success {
            // generate event
            let event = eventEngine.generateRandomEncounter()
            event.effects(state)
            showAlert(title: event.title, description: event.description)
        } else {
            // game over
            updateUI()
        }
        updateUI()
    }
    
    @objc private func reposeAwhile() {
        guard state.vigorPool > 0 && !state.isKingAwake else { return }
        // rest restores vigor but consumes provisions
        if (state.hoardCache["provisions"] ?? 0) >= 1 {
            state.hoardCache["provisions"] = (state.hoardCache["provisions"] ?? 0) - 1
            state.vigorPool = min(100, state.vigorPool + 15)
            // advance day
            _ = state.advanceDay()
            showAlert(title: "Tranquil Slumber", description: "You rested and regained 15 vigor.")
        } else {
            showAlert(title: "No Provisions", description: "You cannot rest without food.")
        }
        updateUI()
    }
    
    @objc private func partakeSustenance() {
        guard state.vigorPool > 0 && !state.isKingAwake else { return }
        if (state.hoardCache["provisions"] ?? 0) >= 1 {
            state.hoardCache["provisions"] = (state.hoardCache["provisions"] ?? 0) - 1
            state.vigorPool = min(100, state.vigorPool + 8)
            // does not advance day
            showAlert(title: "Nourishment", description: "You ate and regained 8 vigor.")
        } else {
            showAlert(title: "Empty Stores", description: "You have no provisions left.")
        }
        updateUI()
    }
    
    @objc private func resetChronicle() {
        state.reset()
        // remove any alert
        alertView?.removeFromSuperview()
        alertView = nil
        updateUI()
    }
    
    // MARK: - Alert presentation
    private func showAlert(title: String, description: String) {
        // remove existing
        alertView?.removeFromSuperview()
        let alert = VignetteAlertView()
        alert.configure(title: title, description: description)
        alert.translatesAutoresizingMaskIntoConstraints = false
        alert.onDismiss = { [weak self] in
            self?.alertView = nil
            self?.updateUI()
        }
        addSubview(alert)
        NSLayoutConstraint.activate([
            alert.topAnchor.constraint(equalTo: topAnchor),
            alert.leadingAnchor.constraint(equalTo: leadingAnchor),
            alert.trailingAnchor.constraint(equalTo: trailingAnchor),
            alert.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        self.alertView = alert
    }
}

// MARK: - View Controller
class ViewController: UIViewController {
    override func loadView() {
        view = PenumbraGameView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "The Lingering Vigil"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

// MARK: - App Entry (for storyboard-free project)
// In AppDelegate or SceneDelegate, set rootViewController to TwilightSovereignController()
