import UIKit

protocol SetupDescriptionDelegate: AnyObject {
    func addTracker(_ tracker: Tracker, to category: TrackerCategory)
}

final class SetupDescriptionViewController: UIViewController {
    //MARK: Properties
    weak var trackerViewController: TypeScreenViewController?
    weak var delegate: SetupDescriptionDelegate?
    
    private var trackerItemsTopConstraint: NSLayoutConstraint!
    private var schedule: [WeekDay?] = []
    private let itemsForHabits = ["Категория", "Расписание"]
    private let itemsForEvents = ["Категория"]
    private var currentItems: [String] = []
    private var categoryTitle: String?
    
    private lazy var trackerName: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .ypLightGray.withAlphaComponent(0.3)
        textField.tintColor = .ypBlack
        textField.textColor =  .ypBlack
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.placeholder = "Введите название трекера"
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        textField.clipsToBounds = true
        //textField.delegate = self
        return textField
    }()
    
    private lazy var limitLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypRed
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        label.text = "Ограничение 38 символов"
        label.isHidden = true
        return label
    }()
    
    private lazy var trackerItems: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        tableView.clipsToBounds = true
        tableView.layer.masksToBounds = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypGray
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.tintColor = .ypWhite
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypWhite
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.tintColor = .ypRed
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: init
    init(isForHabits: Bool) {
        self.currentItems = isForHabits ? itemsForHabits : itemsForEvents
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        trackerItems.delegate = self
        trackerItems.dataSource = self
        
        updeteNavBarTitle(currentItems)
        addSubViews()
        setupConstraint()
    }
    
    //MARK: Methods
    private func updeteNavBarTitle(_ items: [String]) {
        if items == itemsForHabits {
            navigationController?.navigationBar.topItem?.title = "Новая привычка"
        }else if items == itemsForEvents{
            navigationController?.navigationBar.topItem?.title = "Новое нерегулярное событие"
        }
    }
    
    private func addSubViews() {
        view.addSubview(trackerName)
        view.addSubview(limitLabel)
        view.addSubview(trackerItems)
        view.addSubview(createButton)
        view.addSubview(cancelButton)
    }
    
    private func setupConstraint() {
        [
            trackerName,
            limitLabel,
            trackerItems,
            createButton,
            cancelButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        trackerItemsTopConstraint = trackerItems.topAnchor.constraint(equalTo: trackerName.bottomAnchor, constant: 24)
        NSLayoutConstraint.activate([
            trackerName.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            trackerName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerName.heightAnchor.constraint(equalToConstant: 75),
            
            limitLabel.topAnchor.constraint(equalTo: trackerName.bottomAnchor, constant: 8),
            limitLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            limitLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            limitLabel.heightAnchor.constraint(equalToConstant: 22),
            
            trackerItemsTopConstraint,
            trackerItems.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerItems.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerItems.heightAnchor.constraint(equalToConstant: CGFloat(75 * currentItems.count)),
            
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.rightAnchor.constraint(equalTo: createButton.leftAnchor, constant: -8),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    //MARK: Actions
    @objc
    private func createButtonTapped() {
        print("Создать нажато и создается трекер")
    }
    
    @objc
    private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

    //MARK: Extension
extension SetupDescriptionViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            print("Категория")
            // TODO: - добавить выбор категории
        case 1:
            print("Расписание")
            // TODO: - добавить выбор расписания

        default:
            break
        }
    }
}

extension SetupDescriptionViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.selectionStyle = .none
        cell.backgroundColor = .ypLightGray.withAlphaComponent(0.3)
        cell.textLabel?.text = currentItems[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = .ypBlack
        
        if indexPath.row == 1, currentItems.contains("Расписание") {
            let shortWeekDays = schedule.compactMap { $0?.shortWeekDay }
            print("Краткие дни недели: \(shortWeekDays)")
            cell.detailTextLabel?.text = shortWeekDays.isEmpty ? "" : shortWeekDays.joined(separator: ", ")
            cell.detailTextLabel?.text = shortWeekDays.joined(separator: ", ")
            cell.detailTextLabel?.textColor = .ypGray
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        if indexPath.row == 0, !currentItems.contains("Расписание") {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        let chevronImage = UIImage(named: "Chevron")
        if let chevronImage = chevronImage {
            let chevronImageView = UIImageView(image: chevronImage)
            cell.accessoryView = chevronImageView
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}
