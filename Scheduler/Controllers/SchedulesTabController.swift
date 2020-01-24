//
//  SchedulesTabController.swift
//  Scheduler
//
//  Created by Eric Davenport on 1/24/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

class SchedulesTabController: UITabBarController {
  
  // get instance of the two tabs from storyboard
  private let dataPersistence = DataPersistence<Event>(filename: "schedules.plist")
  
  private lazy var schedulesNavController: UINavigationController = {
    guard let navController = storyboard?.instantiateViewController(identifier: "SchedulesNavController") as? UINavigationController,
      let schedulesListController = navController.viewControllers.first as? ScheduleListController else {
      fatalError()
    }
    schedulesListController.dataPersistence = dataPersistence
    return navController
  }()
  
  private lazy var completedNavController: UINavigationController = {
    guard let navController = storyboard?.instantiateViewController(identifier: "CompletedNavController") as? UINavigationController,
      let completedController = navController.viewControllers.first as? CompletedScheduleController else {
        fatalError("could not load nav controller")
    }
    // set dataPersistence property
    completedController.dataPersistence = dataPersistence
    // step 4: custom delegation - set delegate object
    completedController.dataPersistence.delegate = completedController
    return navController
  }()

  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewControllers = [schedulesNavController, completedNavController]
  }
  
  
  
}
