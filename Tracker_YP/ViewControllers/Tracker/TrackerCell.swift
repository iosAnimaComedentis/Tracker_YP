import Foundation
import UIKit

protocol TrackerCellDelegate: AnyObject {
    func completeTracker(id: UUID, at indexPath: IndexPath)
    func uncompleteTracker(id: UUID, at indexPath: IndexPath)
}

final class TrackerCell: UICollectionViewCell {
    
    weak var delegate: TrackerCellDelegate?
    
    var currentDate: Date?
    var trackerId: UUID?
    
    private var indexPath: IndexPath?
    
    private var isCompletedToday = false
    private let doneImage = UIImage(named: "Done")
    private let plusImage = UIImage(named: "Plus")
    
    var  topContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var  bottomContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite
        return view
    }()
    
    var  titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypWhite
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var emojiView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite.withAlphaComponent(0.3)
        view.clipsToBounds = true
        view.layer.cornerRadius = 24 / 2
        view.layer.masksToBounds = true
        return view
    }()
    
    var emoji: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    var dayCounterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        return label
    }()
    
    var  actionButton: UIButton = {
        let button = UIButton()
        let buttonSize = 34
        button.layer.cornerRadius = 34 / 2
        button.alpha = 1
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviewAndConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviewAndConstraints() {
        contentView.addSubview(topContainer)
        contentView.addSubview(bottomContainer)
        
        topContainer.addSubview(emojiView)
        topContainer.addSubview(emoji)
        topContainer.addSubview(titleLabel)
        
        bottomContainer.addSubview(actionButton)
        bottomContainer.addSubview(dayCounterLabel)
        
        [
            topContainer,
            bottomContainer,
            emojiView,
            emoji,
            dayCounterLabel,
            titleLabel,
            actionButton
        ].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            topContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            topContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topContainer.heightAnchor.constraint(equalToConstant: 90),
            
            bottomContainer.topAnchor.constraint(equalTo: topContainer.bottomAnchor),
            bottomContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            emojiView.topAnchor.constraint(equalTo: topContainer.topAnchor, constant: 12),
            emojiView.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor, constant: 12),
            emojiView.widthAnchor.constraint(equalToConstant: 24),
            emojiView.heightAnchor.constraint(equalToConstant: 24),
            
            emoji.centerXAnchor.constraint(equalTo: emojiView.centerXAnchor),
            emoji.centerYAnchor.constraint(equalTo: emojiView.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: -12),
            
            dayCounterLabel.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: 16),
            dayCounterLabel.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 12),
            
            actionButton.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: 8),
            actionButton.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -12),
            actionButton.widthAnchor.constraint(equalToConstant: 34),
            actionButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    func setupCell(with tracker: Tracker, indexPath: IndexPath, completedDay: Int, isCompletedToday: Bool) { // TODO
        self.trackerId = tracker.id
        self.isCompletedToday = isCompletedToday
        self.indexPath = indexPath
        
        self.contentView.backgroundColor = .ypWhite
        self.topContainer.backgroundColor = tracker.color
        
        self.emoji.text = tracker.emoji
        self.titleLabel.text = tracker.name
        
        let wordDay = dayWord(for: completedDay)
        dayCounterLabel.text = "\(completedDay) \(wordDay)"
        
        if isCompletedToday {
            actionButton.tintColor = .ypWhite
            actionButton.backgroundColor = tracker.color
            actionButton.alpha = 0.3
        } else {
            actionButton.tintColor = tracker.color
            actionButton.backgroundColor = .ypWhite
            actionButton.alpha = 1
        }
        
        let image = isCompletedToday ? doneImage : plusImage
        actionButton.setImage(image, for: .normal)
        if actionButton.image(for: .normal) == nil {
            print("Изображение не установлено для кнопки!")
        }
    }
    
    func configure(with title: String, date: Date) {
        titleLabel.text = title
        self.currentDate = date
    }
    
    @objc private func buttonTapped() {
        guard let trackerId = trackerId, let indexPath = indexPath else {
            print("Нет ID трекера")
            return }
        if isCompletedToday {
            delegate?.uncompleteTracker(id: trackerId, at: indexPath)
        } else {
            delegate?.completeTracker(id: trackerId, at: indexPath)
        }
    }
}
