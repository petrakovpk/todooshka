//
//  AppStep.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import RxFlow

enum AppStep: Step {
  
  // Logout Is Required
  case LogoutIsRequired
  
  // Onboarding Is Required
  case OnboardingIsRequired
  
  // Onboarding Is Completed
  case OnboardingIsCompleted
  
  // Tab Bar
  case TabBarIsRequired
  
  // Main Task List Is Required
  case MainTaskListIsRequired
  
  // Overdued Task List Is Required
  case OverduedTaskListIsRequired
  
  // Idea Task list Is Required
  case IdeaTaskListIsRequired
  
  // Completed Task List Is Required
  case CompletedTaskListIsRequired(date: Date)
  
  // Deleted Task List Is Required
  case DeletedTaskListIsRequired

  // Task List Is Completed
  case TaskListIsCompleted
  
  // Type List Is Required
  case TaskTypesListIsRequired
  
  // Type List Is Completed
  case TaskTypesListIsCompleted
  
  // Deleted Task Type List  Is Required
  case DeletedTaskTypeListIsRequired
  
  // Deleted Task Type List Is Completed
  case DeletedTaskTypeListIsCompleted
  
  // Create Task Type Is Required
  case CreateTaskTypeIsRequired
  
  // Show Task Type Is Required
  case ShowTaskTypeIsRequired(type: TaskType)
  
  // Task Type Is Completed
  case TaskTypeProcessingIsCompleted

  // Create Task Is Required
  case CreateTaskIsRequired(status: TaskStatus, createdDate: Date?)
  
  // Show Task Is Required
  case ShowTaskIsRequired(task: Task)
  
  // Task Processing Is Completed
  case TaskProcessingIsCompleted

  // User Profile Is Required
  case UserProfileIsRequired
  
  // User Settings Is Required
  case UserSettingsIsRequired
  
  // User Settings Is Completed
  case UserSettingsIsCompleted
  
  // Remove Task Is Required
  case RemoveTaskIsRequired
  
  // Remove Task Is Completed
  case RemoveTaskIsCompleted
  
  // Shop Is Required
  case ShopIsRequired
  
  // Shop Is Completed
  case ShopIsCompleted
  
  // Show Bird Is Required
  case ShowBirdIsRequired(bird: Bird)
  
  // Show Bird Is Completed
  case ShowBirdIsCompleted
  
  // Show Points is Required
  case ShowPointsIsRequired
  
  // Show Points is Completed
  case ShowPointsIsCompleted
}
