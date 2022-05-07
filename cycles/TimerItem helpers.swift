//
//  TimerItem helpers.swift
//  cycles
//
//  Created by Tony Zhang on 5/7/22.
//
import Foundation

extension TimerItem {
    var wrappedStartTime: Date {
        startTime ?? Date()
    }
    var wrappedName: String {
        get {
            name ?? "Untitled Timer"
        }
        set (value) {
            name = value.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}
