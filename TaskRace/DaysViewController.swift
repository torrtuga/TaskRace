//
//  DaysViewController.swift
//  Todo
//
//  Created by Heather Shelley on 11/26/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import UIKit
import RSDayFlow

class DaysViewController: UIViewController, RSDFDatePickerViewDelegate {
    var dayView: RSDFDatePickerView?
    
    override func viewDidLoad() {
        if let dayView = view as? RSDFDatePickerView {
            self.dayView = dayView
            dayView.delegate = self
            if let dayViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DayViewController") as? DayViewController {
                dayViewController.day = UserDataController.sharedController().dayForDate(Date(date: Foundation.Date()))
                navigationController?.pushViewController(dayViewController, animated: false)
            }
        } else {
            assert(false)
        }
    }
    
    func datePickerView(_ view: RSDFDatePickerView!, didSelect date: Foundation.Date!) {
        let day = UserDataController.sharedController().dayForDate(Date(date: date))
        performSegue(withIdentifier: "DaySegue", sender: day)
    }
    
    @IBAction func todayButtonPressed(_ sender: UIBarButtonItem) {
        self.dayView?.scroll(toToday: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DayViewController {
            destination.day = sender as? Day
        }
    }
    
}
