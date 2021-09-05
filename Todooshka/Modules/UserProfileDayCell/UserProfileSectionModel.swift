//
//  UserProfileSectionModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 10.06.2021.
//
import RxDataSources
import Foundation

struct CalendarDay: IdentifiableType, Equatable {

    var date: Date
    var isSelectedMonth: Bool
    
    var identity: Double {
        return date.timeIntervalSince1970
    }
    
    static func == (lhs: CalendarDay, rhs: CalendarDay) -> Bool {
        return lhs.date == rhs.date && lhs.isSelectedMonth == rhs.isSelectedMonth
    }
}

struct UserProfileSectionModel: AnimatableSectionModelType {
    
    var identity: String {
        return header
    }
    
    var header: String
    var items: [CalendarDay]
    
    init(header: String, items: [CalendarDay]) {
        self.header = header
        self.items = items
    }
    
    init(original: UserProfileSectionModel, items: [CalendarDay]) {
        self = original
        self.items = items
    }
}
