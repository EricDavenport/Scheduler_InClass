//
//  CompletedScheduleController.swift
//  Scheduler
//
//  Created by Alex Paul on 1/18/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

class CompletedScheduleController: UIViewController {
    
  private var completedEvents = [Event]() {
    didSet {
      // code here
    }
  }
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = self
    loadCompletedItems()
  }
  
  private func loadCompletedItems() {
    // code here
  }
}

extension CompletedScheduleController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return completedEvents.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
    let event = completedEvents[indexPath.row]
    cell.textLabel?.text = event.name
    cell.detailTextLabel?.text = event.date.description
    return cell
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      // remove from data soruce
      completedEvents.remove(at: indexPath.row)
      
      // TODO: persist change
    }
  }
}


