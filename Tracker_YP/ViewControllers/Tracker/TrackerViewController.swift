import UIKit

final class TrackerViewController: UIViewController {
    
    //MARK: - Private Properties
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var tracker: [Tracker] = []
    private var completedTrackers: [TrackerRecord] = []
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
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .ypWhite
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(TrackerTitleView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TrackerTitleView.switchHeaderIdentifier)
        return collectionView
    }()
    
    //MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        categories = MockData.mockData
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        navigationBar()
        dateChanged()
    }
    
    //MARK: - Private Methods
    private let cellConfig = CellConfig(
        cellCount: 2,
        leftInset: 16,
        rightInset: 16,
        cellSpacing: 9,
        height: 148,
        paddingWidth: 0
    )
    
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
            showEmptyBlockOrCollectionView(false)
        } else {
            showEmptyBlockOrCollectionView(true)
        }
        collectionView.reloadData()
    }
    
    private func showEmptyBlockOrCollectionView(_ show: Bool) {
        view.addSubview(collectionView)
        view.addSubview(emptyBlock)
        [collectionView, emptyBlock].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            emptyBlock.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        if show{
            emptyBlock.isHidden = true
            collectionView.isHidden = false
        }else {
            emptyBlock.isHidden = false
            collectionView.isHidden = true
        }
    }
    // MARK: - Actions
    @objc
    private func addTarget(){
        let vc = TypeScreenViewController()
        //vc.delegate = self
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }
    
    @objc private func dateChanged() {
        currentDate = Calendar.current.startOfDay(for: datePicker.date)
        updateVisibleCategories()
    }
}

extension TrackerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("Количество секций: \(visibleCategories.count)")
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section < visibleCategories.count else {
            return 0
        }
        let category = visibleCategories[section]
        return category.trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerCell else { return UICollectionViewCell() }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        print("Секция: \(indexPath.section), Элемент: \(indexPath.row)")
        
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        cell.delegate = self
        
        let currentDate = datePicker.date
        let completedDay = completedTrackers.filter{ $0.id == tracker.id }.count
        cell.configure(with: tracker.name, date: currentDate)
        cell.setupCell(with: tracker, indexPath: indexPath, completedDay: completedDay, isCompletedToday: isCompletedToday)
        print("Создана ячейка для секции \(indexPath.section), элемента \(indexPath.row), с трекером \(tracker.name)")
        return cell
    }
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
    }
    
    private func isSameTrackerRecord(trackerRecord: TrackerRecord, id: UUID) -> Bool {
        let isSomeDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
        return trackerRecord.id == id && isSomeDay
    }
}

extension TrackerViewController: TrackerCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        let todayDate = Date()
        
        if let picker = datePicker.date.ignoringTime, let date = todayDate.ignoringTime {
            guard picker <= date else {
                print("Ошибка: нельзя отметить трекер для будущей даты \(datePicker.date)")
                return
            }
        }else {
            return
        }
        
        let trackerRecord = TrackerRecord(id: id, date: datePicker.date)
        print("Выполнен трекер с id \(id) о чем создана запись \(trackerRecord.date)")
        completedTrackers.append(trackerRecord)
        collectionView.reloadItems(at: [indexPath])
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        completedTrackers.removeAll() { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
        print("Отмена выполнения трекера с id \(id) - запись о нем удалена")
        collectionView.reloadItems(at: [indexPath])
    }
}

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: cellConfig.leftInset, bottom: 0, right: cellConfig.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                               withReuseIdentifier: TrackerTitleView.switchHeaderIdentifier,
                                                                               for: indexPath) as? TrackerTitleView
        else { return UICollectionReusableView() }
        let titleCategory = visibleCategories[indexPath.section].title
        headerView.titleLabel.text = titleCategory
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - cellConfig.cellSpacing - cellConfig.leftInset - cellConfig.rightInset) / CGFloat(cellConfig.cellCount),
                      height: cellConfig.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellConfig.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
