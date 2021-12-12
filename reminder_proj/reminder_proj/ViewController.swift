//
//  ViewController.swift
//  reminder_proj
//
//  Created by Tianzheng Li on 12/7/21.
//

import UIKit
import UserNotifications

extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}

typealias remindTuple = (name: String, time: String, end_time: String)
var reminders = [remindTuple]()

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var remindTable: UITableView!
    
    @IBOutlet weak var taskName: UITextField!
    @IBOutlet weak var taskTime: UITextField!
    @IBOutlet weak var taskEndTime: UITextField!
    
    let datePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    
    @IBAction func insertReminder(_ sender: Any) {
        // add a new reminder as a tuple of (task name, time)
        var name:String? = taskName.text
        var time:String? = taskTime.text
        var end_time:String? = taskEndTime.text
        
        // check for empty text
        if name == nil { name = "" }
        if time == nil { time = "" }
        if end_time == nil { end_time = "" }
        
        // create a notification  for it
        createNotification(name: name!, date: time!)
        
        // append to the array
        let insertTuple = (name: String(name!), time: String(time!), end_time: String(end_time!))
        reminders.append(insertTuple)
        
        // refresh tableview to display
        remindTable.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "remindTableViewCell", bundle: nil)
        remindTable.register(nib, forCellReuseIdentifier: "remindTableViewCell")
        remindTable.delegate = self
        remindTable.dataSource = self
        
        // UI for the date pickers
        createDatePicker()
        createEndDatePicker()
        
        
    }
    
    
    // create notifications
    func createNotification(name: String, date: String) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            //
        }
        
        let content = UNMutableNotificationContent()
        content.title = "A reminder for a task/event that has just begun."
        content.body = "\(name)"
        
        // convert string date from text field to Date() object
        var year = ""
        var month = ""
        var day = ""
        var hour = ""
        var minute = ""
        for i in 0...3 { year += String(date[i]) }
        for i in 5...6 { month += String(date[i]) }
        for i in 8...9 { day += String(date[i]) }
        for i in 11...12 { hour += String(date[i]) }
        for i in 14...15 { minute += String(date[i]) }

        var tempDateComponents = DateComponents()
        tempDateComponents.year = Int(year)
        tempDateComponents.month = Int(month)
        tempDateComponents.day = Int(day)
        tempDateComponents.hour = Int(hour)
        tempDateComponents.minute = Int(minute)
        let userCalendar = Calendar(identifier: .gregorian)
        let notificationDate = userCalendar.date(from: tempDateComponents)
        
        // send request for a notification, depending on whether or not user has allowed them
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notificationDate!)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        center.add(request) { (error) in
            if error != nil { print("notification error has occured") }
            else { print("notification succeeded") }
        }
    }
    
    // allows user to pick a date
    func createDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: true)
        
        taskTime.inputAccessoryView = toolbar
        taskTime.inputView = datePicker
    }
    @objc func donePressed() {
        taskTime.text = "\(datePicker.date)"
        self.view.endEditing(true)
    }
    
    
    // allows user to pick a date
    func createEndDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedEnd))
        toolbar.setItems([doneButton], animated: true)
        
        taskEndTime.inputAccessoryView = toolbar
        taskEndTime.inputView = endDatePicker
    }
    @objc func donePressedEnd() {
        taskEndTime.text = "\(endDatePicker.date)"
        self.view.endEditing(true)
    }
    
    
    // tableview functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "remindTableViewCell", for: indexPath) as! remindTableViewCell
        cell.taskName.text = reminders[indexPath.row].name
        cell.taskTime.text = reminders[indexPath.row].time
        cell.taskEndTime.text = reminders[indexPath.row].end_time
        
        return cell
    }
    
}



