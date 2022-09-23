//
//  AppStep.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import RxFlow

enum AppStep: Step {
  
  // Auth
  case AuthIsRequired
  case AuthIsCompleted
  case AuthWithEmailOrPhoneInIsRequired
  
  // Tab Bar
  case CalendarIsRequired
  case TabBarIsRequired
  case MainTaskListIsRequired
  
  // Changing
  case ChangingNameIsRequired
  case ChangingGenderIsRequired
  case ChangingBirthdayIsRequired
  case ChangingPhoneIsRequired
  case ChangingEmailIsRequired
  case ChangingPasswordIsRequired
  
  // Task List
  case CompletedTaskListIsRequired(date: Date)
  case DeletedTaskListIsRequired
  case IdeaTaskListIsRequired
  case OverduedTaskListIsRequired
  case TaskListIsCompleted
  
  // KindOfTask
  case CreateKindOfTaskIsRequired
  case ShowKindOfTaskIsRequired(kindOfTask: KindOfTask)
  
  // Task
  case CreateTaskIsRequired(status: TaskStatus, createdDate: Date?)
  case ShowTaskIsRequired(task: Task)
  case TaskProcessingIsCompleted
  
  // Deleted Task Type List
  case DeletedTaskTypeListIsRequired
  
  // Diamond
  case DiamondIsRequired
  
  // Dismiss
  case Dismiss
  
  // Feather
  case FeatherIsRequired
  
  // KindOfTaskWithBird
  case KindOfTaskWithBird(birdUID: String)
  
  // Logout
  case LogoutIsRequired
  
  // NavigateBack
  case NavigateBack
  
  // Sync
  case SyncDataIsRequired
  
  // Onboarding
  case OnboardingIsRequired
  case OnboardingIsCompleted
  
  // Remove Task
  case RemoveTaskIsRequired
  
  // Settings
  case SettingsIsRequired
  
  // Shop
  case ShopIsRequired
  case ShopIsCompleted
  
  // Show Bird
  case ShowBirdIsRequired(bird: Bird)
  
  // Show Points
  case ShowPointsIsRequired

  // Type List
  case TaskTypesListIsRequired
  
  // UserProfile
  case UserProfileIsRequired
  
  
}
