//
//  Task.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 20.05.2021.
//

import RxDataSources
import CoreData

struct Task: IdentifiableType, Equatable {

  // MARK: - Properites
  var UID: String
  
  var text: String
  var description: String?
  
  var status: TaskStatus
  var serialNum: Int = 0
  
  var created: Date
  var planned: Date?
  var closed: Date?
  
  // link properties
  var typeUID: String = TaskType.Standart.Empty.UID
  
  //MARK: - Calculated Properties
  var identity: String { return self.UID }
  
  var is24hoursPassed: Bool {
    return created.timeIntervalSince1970 <= Date().timeIntervalSince1970 - 24 * 60 * 60
  }
  
  var secondsLeft: Double {
    return max(24 * 60 * 60 + created.timeIntervalSince1970 - Date().timeIntervalSince1970, 0)
  }
  
  var timeLeftText: String {
    let formatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateFormat = "HH'h' mm'm' ss's'"
      formatter.timeZone = TimeZone(secondsFromGMT: 0)
      return formatter
    }()
    
    return formatter.string(from: Date(timeIntervalSince1970: secondsLeft))
  }
  
  var timeLeftPercent: Double {
    status == .InProgress ? secondsLeft / (24 * 60 * 60) : 0
  }
  
  //MARK: - init
  init(UID: String, text: String, description: String?, status: TaskStatus, created: Date) {
    self.UID = UID
    self.text = text
    self.description = description
    self.status = status
    self.created = created
  }
  
  init(UID: String, text: String, description: String?, type: TaskType, status: TaskStatus, created: Date, closed: Date?) {
    self.UID = UID
    self.text = text
    self.description = description
    self.status = status
    self.created = created
    self.typeUID = type.UID
    self.closed = closed
  }
  
  init?(taskCoreData: TaskCoreData) {
    guard let status = TaskStatus(rawValue: taskCoreData.status) else { return nil }
    self.UID = taskCoreData.uid
    self.text = taskCoreData.text
    self.description = taskCoreData.desc
    self.typeUID = taskCoreData.type
    self.status = status
    self.created = taskCoreData.created
    self.closed = taskCoreData.closed
    self.planned = taskCoreData.planned
    self.serialNum = Int(taskCoreData.serialNum)
  }
  
  // MARK: - Equatable
  static func == (lhs: Task, rhs: Task) -> Bool {
    return lhs.UID == rhs.UID && lhs.typeUID == rhs.typeUID
  }
  
  // MARK: - Helpers
  func type(withTypeService service: HasTypesService) -> TaskType? {
    service.typesService.types.value.first(where: { $0.UID == self.typeUID })
  }

}

// MARK: - Static Properties
extension Task {
  
  static let emptyTask: Task = Task(UID: "Empty", text: "", description: "", status: .InProgress, created: Date())
  
}
