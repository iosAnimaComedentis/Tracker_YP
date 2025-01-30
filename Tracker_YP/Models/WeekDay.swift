//
//  WeekDay.swift
//  Tracker_YP
//
//  Created by Максим Карпов on 30.01.2025.
//

enum WeekDay: String, CaseIterable {
    case modeay = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверрг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
    
    var shortWeekDay: String {
        switch self {
        case .modeay: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
    
    static func from(weekdayIndex: Int) -> WeekDay? {
        switch weekdayIndex {
        case 1: return .modeay
        case 2: return .tuesday
        case 3: return .wednesday
        case 4: return .thursday
        case 5: return .friday
        case 6: return .saturday
        case 7: return .sunday
        default: return nil
        }
    }
}
