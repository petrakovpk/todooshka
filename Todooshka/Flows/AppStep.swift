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
  case calendarIsRequired
  case tabBarIsRequired
  case mainTaskListIsRequired

  // Changing
  case changingNameIsRequired
  case changingGenderIsRequired
  case changingBirthdayIsRequired
  case changingPhoneIsRequired
  case changingEmailIsRequired
  case changingPasswordIsRequired
  
  // Feed
  case feedIsRequired

  // Task List
  case completedTaskListIsRequired(date: Date)
  case deletedTaskListIsRequired
  case ideaTaskListIsRequired
  case overduedTaskListIsRequired
  case plannedTaskListIsRequired(date: Date)
  case taskListIsCompleted

  // KindOfTask
  case createKindOfTaskIsRequired
  case showKindOfTaskIsRequired(kindOfTask: KindOfTask)

  // Task
  case createTaskIsRequired(task: Task)
  case showTaskIsRequired(task: Task)
  case taskProcessingIsCompleted

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
  case navigateBack

  // Sync
  case syncDataIsRequired

  // Onboarding
  case onboardingIsRequired
  case onboardingIsCompleted

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

  //case addThemeIsRequired
  case openThemeIsRequired(theme: Theme)
  case themeProcessingIsCompleted
  case themeStepIsRequired(themeStep: ThemeStep, openViewControllerMode: OpenViewControllerMode)
  case themeTaskIsRequired(themeTaskUID: String, openViewControllerMode: OpenViewControllerMode)

  // UserProfile
  case userProfileIsRequired
}
