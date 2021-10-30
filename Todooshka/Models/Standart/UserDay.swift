//
//  UserDay.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 10.06.2021.
//
import RxDataSources
import UIKit

class UserDay: IdentifiableType, Equatable {
    
    var identity: String { return self.UID }
    var UID: String
    var date: Date
    var tasks: [Task]
    
    var closedTasks: [Task] { return self.tasks.filter({$0.closedDate?.beginning(of: .day) == date.beginning(of: Calendar.Component.day)}) }
    var isEmpty: Bool = false
    
    var dateStatus: String {
        switch self.closedTasks.count {
        case 0:
            return "Дом"
        case 1:
            return "Крестьянин"
        case 2:
            return "Рыцарь"
        case 3...4:
            return "Король"
        case 5...100:
            return "Дракон"
        default:
            return ""
        }
    }
    
    var dateText: String {
        switch self.closedTasks.count {
        case 0:
            return "Вы бездельник. Так ваша жизнь никогда не изменится..."
        case 1:
            return "Вы - крестьянин. Пашите свое поле лучше, если хотите забраться повыше!"
        case 2:
            return "Вы - рыцарь. Успехи определенно есть! Так держать!"
        case 3...4:
            return "Вы - король. Делая столько дел ежедневно вы просто заберетесь на вершину олимпа!"
        case 5...100:
            return "Вы - Дракон!!! Высшее существо, все хотят быть как вы, но никто этого не достоин!"
        default:
            return ""
        }
    }
    
    var dateImage: UIImage {
        switch self.closedTasks.count {
        case 0:
            return UIImage(named: "house")!
        case 1:
            return UIImage(named: "worker")!
        case 2:
            return UIImage(named: "knight")!
        case 3...4:
            return UIImage(named: "king")!
        case 5...100:
            return UIImage(named: "dragon")!
        default:
            return UIImage(systemName: "questionmark")!
        }
    }
    
    init(UID: String, date: Date, tasks: [Task]) {
        self.UID = UID
        self.date = date
        self.tasks = tasks
    }
    
    static func == (lhs: UserDay, rhs: UserDay) -> Bool {
        return lhs.UID == rhs.UID
    }
    
    func getTypeNameByIndex(index: Int) -> String? {
      let closedTasksDictionary = Dictionary(grouping: closedTasks, by: { $0.typeUID }).sorted{ $0.value.count > $1.value.count }
        if index >= Array(closedTasksDictionary).count { return nil }
        return Array(closedTasksDictionary)[index].key
    }
    
    func getTypeCountByIndex(index: Int) -> String? {
        let closedTasksDictionary = Dictionary(grouping: closedTasks, by: { $0.typeUID }).sorted{ $0.value.count > $1.value.count }
        if index >= Array(closedTasksDictionary).count { return nil }
        return Array(closedTasksDictionary)[index].value.count.string
    }
}
