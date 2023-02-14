//
//  AppStep.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import RxFlow

enum AppStep: Step {
  // Auth
  case authIsRequired
  case authIsCompleted
  case authWithEmailOrPhoneInIsRequired

  // Tab Bar
  case tabBarIsRequired
  case funIsRequired
  case workplaceIsRequired
  case userProfileIsRequired
  
  // workplace
  case mainCalendarIsRequired
  case mainTaskListIsRequired
  
  // Task
  case createTaskIsRequired(task: Task, isModal: Bool)
  case showTaskIsRequired(task: Task)
  case addPhotoIsRequired(task: Task)
  case taskProcessingIsCompleted
  
  // Changing
  case changingNameIsRequired
  case changingGenderIsRequired
  case changingBirthdayIsRequired
  case changingPhoneIsRequired
  case changingEmailIsRequired
  case changingPasswordIsRequired

  
  // Task List
  case overduedTaskListIsRequired
  case ideaTaskListIsRequired
  case plannedTaskListIsRequired(date: Date)
  case completedTaskListIsRequired(date: Date)
  case deletedTaskListIsRequired
  case taskListIsCompleted

  // KindOfTask
  case createKindOfTaskIsRequired
  case showKindOfTaskIsRequired(kindOfTask: KindOfTask)

 

  // Deleted Task Type List
  case deletedTaskTypeListIsRequired

  // DeleteAccount
  case deleteAccountIsRequired

  // Diamond
  case diamondIsRequired

  // Dismiss
  case dismiss

  // Feather
  case featherIsRequired

  // KindsOfTask
  case kindsOfTaskListIsRequired

  // KindOfTaskWithBird
  case kindOfTaskWithBird(birdUID: String)

  // Logout
  case logoutIsRequired

  // Marketplace
  case marketplaceIsRequired

  // NavigateBack
  case dismissAndNavigateBack
  case navigateBack

  // Sync
  case syncDataIsRequired

  // Onboarding
  case onboardingIsRequired
  case onboardingIsCompleted
  
  // profile
  case profileIsRequired

  // Remove Task
  case removeTaskIsRequired

  // Settings
  case settingsIsRequired

  // Support
  case supportIsRequired

  // Shop
  case shopIsRequired
  case shopIsCompleted

  // Show Bird
  case showBirdIsRequired(bird: Bird)

  // Theme
  case themeIsRequired(theme: Theme)
  case themeSettingsIsRequired(theme: Theme)
  case themeStepIsRequired(themeStep: ThemeStep, openViewControllerMode: OpenViewControllerMode)
  case themeTaskIsRequired(themeTaskUID: String, openViewControllerMode: OpenViewControllerMode)
  case themeProcessingIsCompleted

}
