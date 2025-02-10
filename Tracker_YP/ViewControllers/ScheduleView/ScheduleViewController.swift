import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didUpdateSchedule(_ schedule: [WeekDay?])
}

final class ScheduleViewController: UIViewController {
    //MARK: Prorerties
    
    weak var delegate: ScheduleViewControllerDelegate?
    private var schedule: [WeekDay?] = []
    
    private lazy var scheduleTableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Day")
        table.layer.masksToBounds = true
        table.layer.cornerRadius = 16
        table.separatorStyle = .singleLine
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.layer.maskedCorners = [
            .layerMaxXMaxYCorner,
            .layerMaxXMinYCorner,
            .layerMinXMaxYCorner,
            .layerMinXMinYCorner
        ]
        table.clipsToBounds = true
        table.isScrollEnabled = false
        return table
    }()
    
    private lazy var applyButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .ypBlack
        btn.setTitle("Готово", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.tintColor = .ypWhite
        btn.layer.cornerRadius = 16
        btn.addTarget(self, action: #selector(saveDays), for: .touchUpInside)
        return btn
    }()
    
    //MARK: LufeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        navigationBar()
        subView()
        constraint()
    }
    //MARK: Actions
    @objc
    private func saveDays() {
        delegate?.didUpdateSchedule(schedule)
        dismiss(animated: true)
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        let index = sender.tag
        let weekDay = WeekDay.allCases[index]
        
        if sender.isOn {
            if !schedule.contains(where: { $0 == weekDay }) {
                schedule.append(weekDay)
            }
        } else {
            if let indexToRemove = schedule.firstIndex(of: weekDay) {
                schedule[indexToRemove] = nil
            }
        }
        
        print("Selected schedule: \(schedule.map { $0?.rawValue ?? "None" })")
    }
    
    //MARK: Methods
    private func navigationBar() {
        guard let navTitle = navigationController?.navigationBar.topItem else { return }
        navTitle.title = "Расписание"
    }
    
    private func subView(){
        view.addSubview(scheduleTableView)
        view.addSubview(applyButton)
    }
    
    private func constraint(){
        [ scheduleTableView, applyButton ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            scheduleTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scheduleTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scheduleTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            scheduleTableView.heightAnchor.constraint(equalToConstant: 525),
            
            applyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            applyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            applyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            applyButton.heightAnchor.constraint(equalToConstant: 60)

        ])
    }
    
    func loadSelectedSchedule(from schedule: [WeekDay?]) {
        self.schedule = schedule
    }
}

//MARK: Extension
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeekDay.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Day", for: indexPath)
        
        let weekDay = WeekDay.allCases[indexPath.row]
        
        cell.textLabel?.text = weekDay.rawValue
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = .ypBlack
        cell.selectionStyle = .none
        cell.backgroundColor = .ypLightGray.withAlphaComponent(0.3)
        
        if indexPath.row == 6 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        let switchControl = UISwitch()
        switchControl.isOn = schedule.contains(weekDay)
        switchControl.tag = indexPath.row
        switchControl.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        switchControl.tintColor = .ypBlue
        switchControl.onTintColor = .ypBlue
        cell.accessoryView = switchControl
        
        return cell
    }
}

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(75)
    }
}
