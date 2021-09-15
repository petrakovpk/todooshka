//
//  AppStep.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import RxFlow

enum AppStep: Step {
  
  // Global
  case logoutIsRequired
  
  // Auth
  case authIsRequired
  case authIsCompleted
  case createAccountIsRequired(isNewUser: Bool)
  case createAccountIsCompleted
  
  // Onboarding
  case onboardingIsRequired
  case onboardingIsCompleted
  
  // Tab Bar
  case tabBarIsRequired
  
  // Task List
  case taskListIsRequired
  
  // Task Type
  case taskTypeIsRequired(type: TaskType?)
  case taskTypeIsCompleted
  
  // Deleted Task List
  case deletedTaskTypeListIsRequired
  case deletedTaskTypeListIsCompleted
  
  // Overdued Task List
  case overdueTaskListIsRequired
  case overdueTaskListIsCompleted
  
  // Completed Task List
  case completedTaskListIsRequired(date: Date)
  case completedTaskListIsCompleted
  
  // Deleted Task List
  case deletedTaskListIsRequired
  case deletedTaskListIsCompleted
  
  // Idea Box Task list
  case ideaBoxTaskListIsRequired
  case ideaBoxTaskListIsCompleted
  
  // Task
  case createTaskIsRequired(status: TaskStatus, createdDate: Date?)
  case showTaskIsRequired(task: Task)
  
  case taskProcessingIsCompleted
  
  // Type List
  case taskTypesListIsRequired
  case taskTypesListIsCompleted
  
  // UserProfile
  case userProfileIsRequired
  case userSettingsIsRequired
  case userSettingsIsCompleted
  
  // Remove Confirmation
  case removeTaskConfirmationIsRequired
  case removeTaskConfirmationisCompleted
  
}
