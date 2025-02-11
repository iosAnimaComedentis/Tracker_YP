import UIKit

final class TypeScreenViewController: UIViewController {
    
    
    //MARK: - Prorerties
    weak var delegate: SetupDescriptionDelegate?
    
    private lazy var habitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlack
        button.titleLabel?.textColor = .ypWhite
        button.setTitle("Привычка", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        
        button.addTarget(self, action: #selector(tapHabitButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var eventButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlack
        button.titleLabel?.textColor = .ypWhite
        button.setTitle("Нерегулярное событие", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        
        button.addTarget(self, action: #selector(tapEventButton), for: .touchUpInside)
        return button
    }()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupContraint()
    }
    
    //MARK: - Methods
    private func setupView(){
        view.backgroundColor = .ypWhite
        navigationController?.navigationBar.topItem?.title = "Создание трекера"
        view.addSubview(habitButton)
        view.addSubview(eventButton)
    }
    
    private func setupContraint() {
        [
            habitButton,
            eventButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            eventButton.heightAnchor.constraint(equalToConstant: 60),
            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            eventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            eventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            eventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    //MARK: - Actions
    @objc
    private func tapHabitButton() {
        let vc = SetupDescriptionViewController(isForHabits: true)
        vc.delegate = delegate
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
    @objc
    private func tapEventButton() {
        let vc = SetupDescriptionViewController(isForHabits: false)
        vc.delegate = delegate
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
}
