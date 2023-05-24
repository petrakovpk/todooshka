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
  
  // User Image
  case extUserDataCameraForIsRequired(extUserData: UserExtData)
  case extUserDataPhotoLibraryForIsRequired(extUserData: UserExtData)

  // Tab Bar
  case tabBarIsRequired
  case funIsRequired
  case marketplaceIsRequired
  case mainTaskListIsRequired
  case addTabBarPresentationIsRequired

  // Task
  case openTaskIsRequired(task: Task, taskListMode: TaskListMode)
  case resultPreviewIsRequired(task: Task)
  case taskProcessingIsCompleted
  
  // Publication
  case publicationIsRequired(publication: Publication)
  case publicationEditIsRequired(publication: Publication, publicationImage: PublicationImage?)
  case publicationSettingsIsRequired(publication: Publication, publicationImage: PublicationImage?)
  case publicationCameraIsRequired(publication: Publication)
  case publicationPhotoLibraryIsRequired(publication: Publication)
  case publicationPublicKindIsRequired(publication: Publication)
  
  case publicationEditProcesingIsCompleted
  case publicationProcesingIsCompleted
  
  // Settings
  case settingsIsRequired
  case accountSettingsIsRequired
  case changingNameIsRequired
  case changingGenderIsRequired
  case changingBirthdayIsRequired
  case changingPhoneIsRequired
  case changingEmailIsRequired
  case changingPasswordIsRequired

  // Task List
  case overduedTaskListIsRequired
  case ideaTaskListIsRequired
  case dayTaskListIsRequired(date: Date)
  case deletedTaskListIsRequired
  case taskListIsCompleted

  // Kind
  case openKindIsRequired(kind: Kind)

  // Deleted Task Type List
  case deletedKindListIsRequired

  // Delete Account
  case deleteAccountIsRequired

  // Diamond
  case diamondIsRequired

  // Dismiss
  case dismiss
  case dismissVC(viewController: UIViewController)
  case dismissModalRoot

  // Feather
  case featherIsRequired

  // KindsOfTask
  case kindListIsRequired

  // KindOfTaskWithBird
  case kindOfTaskWithBird(birdUID: String)

  // Logout
  case logoutIsRequired

  // NavigateBack
  case dismissAndNavigateBack
  case navigateBack

  // Sync
  case syncDataIsRequired

  // Onboarding
  case onboardingIsRequired
  case onboardingIsCompleted
  
  // user profile
  case profileIsRequired
  case imagePickerIsRequired
  case followersIsRequired
  case subsriptionsIsRequired

  // Remove Task
  case removeTaskIsRequired
  
  // Support
  case supportIsRequired

  // Shop
  case shopIsRequired
  case shopIsCompleted

  // Show Bird
  case showBirdIsRequired(bird: Bird)

  // Quest
  case questIsRequired(quest: Quest)
  case questGalleryIsRequired(quest: Quest, questImage: QuestImage)
  case questAuthorImagesPresentationIsRequired(quest: Quest)
  case questAuthorImagesPhotoLibraryIsRequired(quest: Quest)
  case questAuthorImagesCameraIsRequired(quest: Quest)
  case questProcessingIsCompleted
  
  case questSettingsPresentationIsRequired(quest: Quest)
  
  case questEditIsRequired(quest: Quest)
  
  case questPreviewIsRequired(quest: Quest)
  case questPreviewImagePresentationIsRequired(quest: Quest)
  case questPreviewImagePhotoLibraryIsRequired(quest: Quest)
  case questPreviewImageCameraIsRequired(quest: Quest)
  case questPreviewProcessingIsCompleted
  
//  case questOpenCameraIsRequired(quest: Quest)
//  case questOpenPhotoLibraryIsRequired(quest: Quest)
  
  
  // Empty
  case empty
}
