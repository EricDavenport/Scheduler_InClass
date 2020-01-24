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
      //guard let tableView = tableView else { return }
    }
  }
  private let completedEventsPersistenc = DataPersistence<Event>(filename: "completedEvents.plist")
  public var dataPersistence: DataPersistence<Event>!   // saved to schedules.plist
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = self
    loadCompletedItems()
  }
  
  private func loadCompletedItems() {
    do {
      completedEvents = try completedEventsPersistenc.loadItems()
    } catch {
      print("error loading completed events: \(error)")
    }
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
      do {
        try completedEventsPersistenc.deleteItem(at: indexPath.row)
      } catch {
        print("error deleting completed task: \(error)")
      }
    }
  }
}

extension CompletedScheduleController : DataPersistenceDelegate {
  func didDeleteItem<T>(_ persistenceHelper: DataPersistence<T>, item: T) where T : Decodable, T : Encodable, T : Equatable {
    print("item was deleted")
    // persist item to completed events persisstence
    do {
      let event = item as! Event
      try completedEventsPersistenc.createItem(event)
    } catch {
      print("error creaating item\(error)")
    }
    // reload completed items array
    loadCompletedItems()
  }
}
