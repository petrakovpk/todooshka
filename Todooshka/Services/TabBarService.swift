//
//  TabBarService.swift
//  Todooshka
//
//  Created by Pavel Petakov on 31.08.2022.
//

import RxSwift
import CoreData
import RxRelay

enum TabBarItemType {
  case fun
  case taskList
  case userProfile
}

protocol HasTabBarService {
  var tabBarService: TabBarService { get }
}

class TabBarService {
  let selectedItem = BehaviorRelay<TabBarItemType>(value: .fun)
}
