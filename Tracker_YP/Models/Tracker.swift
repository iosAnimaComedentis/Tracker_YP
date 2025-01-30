//
//  Tracker.swift
//  Tracker_YP
//
//  Created by Максим Карпов on 30.01.2025.
//
import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay?]
}
