//
//  TrackersViewController.swift
//  Tracker_YP
//
//  Created by Максим Карпов on 30.01.2025.
//
import UIKit

final class TrackersViewController: UIViewController {
    //MARK: - Private Properties
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
        setupConstraints()
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
        
        datePicker.addTarget(self, action: #selector(datePickerDateSelection), for: .valueChanged)
        
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
    }
    
    @objc
    private func addTarget(){
        
    }
    
    @objc private func datePickerDateSelection() {
        
    }
    
    //MARK: - Constraints and subView
    private func setupConstraints() {
        [
            emptyBlock
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            emptyBlock.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}
