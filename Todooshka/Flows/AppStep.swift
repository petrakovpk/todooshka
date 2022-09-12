//
//  AppStep.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import RxFlow

enum AppStep: Step {
  
  // App
  case NavigateBack
  
  // Auth
  case AuthIsRequired
  case AuthIsCompleted
  case CreateAccountIsRequired
  case LogInIsRequired
  
  // Logout
  case LogoutIsRequired
  
  // Onboarding
  case OnboardingIsRequired
  case OnboardingIsCompleted
  
  // Tab Bar
  case CalendarIsRequired
  case TabBarIsRequired
  case MainTaskListIsRequired
 
  // Task List
  case OverduedTaskListIsRequired
  case IdeaTaskListIsRequired
  case CompletedTaskListIsRequired(date: Date)
  case DeletedTaskListIsRequired
  case TaskListIsCompleted
  
  // Type List
  case TaskTypesListIsRequired
  case TaskTypesListIsCompleted
  
  // Deleted Task Type List
  case DeletedTaskTypeListIsRequired
  case DeletedTaskTypeListIsCompleted
  
  // Task Type
  case CreateTaskTypeIsRequired
  case ShowTaskTypeIsRequired(type: TaskType)
  case TaskTypeProcessingIsCompleted

  // Task
  case CreateTaskIsRequired(status: TaskStatus, createdDate: Date?)
  case ShowTaskIsRequired(task: Task)
  case TaskProcessingIsCompleted

  // Settings
  case SettingsIsRequired
  case SettingsIsCompleted
  
  // Remove Task
  case RemoveTaskIsRequired
  case RemoveTaskIsCompleted
  
  // Shop
  case ShopIsRequired
  case ShopIsCompleted
  
  // Show Bird
  case ShowBirdIsRequired(bird: Bird)
  case ShowBirdIsCompleted
  
  // Show Points
  case ShowPointsIsRequired
  case ShowPointsIsCompleted
  
  // Feather
  case FeatherIsRequired
  case FeatherIsCompleted
  
  // Diamond
  case DiamondIsRequired
  case DiamondIsCompleted
  
  // UserProfile
  case UserProfileIsRequired
  case ChangingNameIsRequired
  case ChangingGenderIsRequired
  case ChangingBirthdayIsRequired
  case ChangingPhoneIsRequired
  case ChangingEmailIsRequired
  case ChangingPasswordIsRequired
}
