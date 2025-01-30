import UIKit

final class TrackerViewController: UIViewController {
    
    //MARK: - Private Properties
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var tracker: [Tracker] = []
    private var comlitedTracker: [TrackerRecord] = []
    private var currentDate: Date = Date()
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.calendar.firstWeekday = 2
        return datePicker
    }()
    
    private lazy var emptyBlock: EmptyBlock = {
        let block = EmptyBlock()
        block.setLabel("Что будем отслеживать?")
        return block
    }()
    
    //MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        navigationBar()
        updateVisibleCategories()
    }
    
    //MARK: - Private Methods
    private func navigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
        navigationItem.leftBarButtonItem?.image = UIImage(systemName: "plus")
        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = #selector(addTarget)
        navigationItem.leftBarButtonItem?.tintColor = .ypBlack
        
        let datePickerBarButtonItem = UIBarButtonItem(customView: datePicker)
        datePickerBarButtonItem.customView?.widthAnchor.constraint(equalToConstant: 100).isActive = true
        navigationItem.rightBarButtonItem = datePickerBarButtonItem
        
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
    }
    
    private func updateVisibleCategories() {
        let calendar = Calendar.current
        let selectedDayIndex = calendar.component(.weekday, from: currentDate)
        guard let selectedWeekDay = WeekDay.from(weekdayIndex: selectedDayIndex) else { return }
        
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                print("Проверка трекера: \(tracker.name)")
                if tracker.schedule.isEmpty {
                    print("Трекер без расписания: \(tracker.name)")
                    return true
                } else {
                    let containsWeekDay = tracker.schedule.contains { weekDay in
                        weekDay == selectedWeekDay
                    }
                    print("Трекер содержит \(selectedWeekDay): \(containsWeekDay)")
                    return containsWeekDay
                }
            }
            if trackers.isEmpty { return nil }
            return TrackerCategory(
                title: category.title,
                trackers: trackers
            )
        }
        if visibleCategories.isEmpty {
            print("Видимые категории: \(visibleCategories)")
            createEmptyBlock()
        } else {
            //TODO: тут вызов для колекции
            
        }
        //тут обнова
        //collectionView.reloadData()
    }
    
    private func showEmptyBlock(_ show: Bool) {
        emptyBlock.isHidden = show
    }
    // MARK: - Actions
    @objc
    private func addTarget(){
        print("нажата кнопка +")
    }
    
    @objc private func dateChanged() {
        print("нажата кнопка")
        currentDate = Calendar.current.startOfDay(for: datePicker.date)
        updateVisibleCategories()
    }
    
    //MARK: - Constraints and subView
    private func createEmptyBlock() {
        emptyBlock.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyBlock)
        
        NSLayoutConstraint.activate([
            emptyBlock.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
