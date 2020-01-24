//
//  ViewController.swift
//  Scheduler
//
//  Created by Alex Paul on 11/20/19.
//  Copyright © 2019 Alex Paul. All rights reserved.
//

import UIKit

class ScheduleListController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  
  // data - an array of events
  private var events = [Event]()
  
  public var dataPersistence: DataPersistence<Event>!
  
  private var isEditingTableView = false {
    didSet { // property observer
      // toggle editing mode of table view
      tableView.isEditing = isEditingTableView
      
      // toggle bar button item's title between "Edit" and "Done"
      navigationItem.leftBarButtonItem?.title = isEditingTableView ? "Done" : "Edit"
    }
  }
  
  lazy var dateFormatter:  DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMM d, yyyy, hh:mm a"
    formatter.timeZone = .current
    return formatter
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    print(FileManager.getDocumentsDirectory())
    
    tableView.dataSource = self
    tableView.delegate = self
    
    loadItems()
  }
  
  private func loadItems() {
    do {
      events = try dataPersistence.loadItems()
      tableView.reloadData()
    } catch {
      print("loading items error: \(error)")
    }
  }
  
  @IBAction func newEventWillBeAdded(segue: UIStoryboardSegue) {
    // get a reference to the CreateEventController instance
    guard let createEventController = segue.source as? CreateEventController,
      let newEvent = createEventController.event,
      !newEvent.name.isEmpty else {
        print("could not create new event")
        return 
    }
    
    if createEventController.eventState == .existingEvent {
      let index = events.firstIndex { $0.identifier == newEvent.identifier }
      
      guard let itemIndex = index else { return }
      let oldEvent = events[itemIndex]
      
      update(oldEvent: oldEvent, with: newEvent)
    } else {
      createNewEvent(event: newEvent)
    }
  }
  
  private func update(oldEvent: Event, with newEvent: Event) {
    // update item in documents directory
    dataPersistence.update(oldEvent, with: newEvent)
    
    // call load items to update events array
    // retrieve obbjects from documents directory
    // append to events array
    // reload the tableView
    loadItems()
  }
  
  private func createNewEvent(event: Event) {
    // insert new event into our events array
    // 1. update the data model e.g update the events array
    //events.insert(createdEvent, at: 0) // top of the events array
    
    events.append(event)
    
    // create an indexPath to be inserted into the table view
    let indexPath = IndexPath(row: events.count - 1, section: 0) // will represent top of table view
    
    // 2. we need to update the table view
    // use indexPath to insert into table view
    tableView.insertRows(at: [indexPath], with: .automatic)
    
    try? dataPersistence.createItem(event)
  }
  
  @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
    isEditingTableView.toggle() // changes a boolean value
  }
  
  @IBAction func createEventButtonPressed(_ sender: UIBarButtonItem) {
    showCreateEventVC()
  }
  
  private func showCreateEventVC(_ event: Event? = nil) {
    // we need to use the storyboard to get an imnstance of the CreateEventController
    guard let createEventController = storyboard?.instantiateViewController(identifier: "CreateEventController") as? CreateEventController else {
      fatalError("Could not downcasty to CreateEventController")
    }
    //  let createEC = CreatEventController() - an empty view controller withot any outlets, etc. will crash if you are expecting your ouytlets to work if they exist in storyboard
    createEventController.event = event
    // TODO:
    // for updating an event we will inject ("dependency injection")the selected event
    // create EventControoler
    present(createEventController, animated: true)
  }
}


// MARK:- UITableViewDataSource
extension ScheduleListController : UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return events.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
    let event = events[indexPath.row]
    cell.textLabel?.text = event.name
    cell.detailTextLabel?.text = dateFormatter.string(from: event.date)//event.date.description
    return cell
  }
  
  // MARK:- deleting rows in a table view
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    switch editingStyle {
    case .insert:
      // only gets called if "insertion control" exist and gets selected
      print("inserting....")
    case .delete:
      print("deleting..")
      // 1. remove item for the data model e.g events
      events.remove(at: indexPath.row) // remove event from events array
      
      // remvoe item from documents directory
      try? dataPersistence.deleteItem(at: indexPath.row)
      
      // 2. update the table view
      tableView.deleteRows(at: [indexPath], with: .automatic)
    default:
      print("......")
    }
  }
  
  // MARK:- reordering rows in a table view
  func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    let eventToMove = events[sourceIndexPath.row] // save the event being moved
    events.remove(at: sourceIndexPath.row)
    events.insert(eventToMove, at: destinationIndexPath.row)
    
    // re-save array in docuemnts directory
    dataPersistence.synchronize(events)
    
    loadItems()
  }
}

extension ScheduleListController : UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let event = events[indexPath.row]
    showCreateEventVC(event)
  }
  
  func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
    return "Completed"
  }
  
}

