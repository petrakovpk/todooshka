//
//  SceneDelegate.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import UIKit
import SwiftUI
import RxFlow
import RxSwift
import RxCocoa
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  let disposeBag = DisposeBag()
  var window: UIWindow?
  var coordinator = FlowCoordinator()
  
  let birdService = BirdService()
  let birdTypeService = BirdTypeService()
  let pointService = PointService()
  let preferencesService = PreferencesService()
  let tasksService = TasksService()
  let typesService = TypesService()
  
  lazy var appServices = {
    return AppServices(
      birdService: birdService,
      birdTypeService: birdTypeService,
      pointService: pointService,
      preferencesService: preferencesService,
      tasksService: tasksService,
      typesService: typesService
    )
  }()
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    
    // UserDefaults.standard.setValue(false, forKey: "isOnboardingCompleted")
    
    guard let scene = (scene as? UIWindowScene) else { return }
    window = UIWindow.init(windowScene: scene)
    
    coordinator.rx.willNavigate.subscribe { (flow, step) in
      print("will navigate to flow=\(flow) and step=\(step)")
    }.disposed(by: disposeBag)
    
    coordinator.rx.didNavigate.subscribe { (flow, step) in
      print("did navigate to flow=\(flow) and step=\(step)")
    }.disposed(by: disposeBag)
    
    let appFlow = AppFlow(services: appServices)
    
    coordinator.coordinate(flow: appFlow, with: AppStepper(withServices: appServices))
    
    Flows.use(appFlow, when: .created) { [weak self] (root) in
      self?.window?.rootViewController = root
      self?.window?.makeKeyAndVisible()
    }
        
    UNUserNotificationCenter.current().delegate = self

  }
  

  
  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
  }
  
  func sceneDidBecomeActive(_ scene: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
  }
  
  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
  }
  
  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
  }
  
  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
    
    // Save changes in the application's managed object context when the application transitions to the background.
    (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
  }
  
  
}

//MARK: - UNUserNotificationCenterDelegate
extension SceneDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler(UNNotificationPresentationOptions.init(arrayLiteral: [.alert, .badge]))
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    // example of how DeepLink can be handled
    // self.coordinator.navigate(to: DemoStep.movieIsPicked(withId: 23452))
  }
}
