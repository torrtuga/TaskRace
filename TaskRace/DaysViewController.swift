//
//  DaysViewController.swift
//  Todo
//
//  Created by Heather Shelley on 11/26/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import UIKit

class DaysViewController: UIViewController, RSDFDatePickerViewDelegate {
    
    override func viewDidLoad() {
        if let dayView = view as? RSDFDatePickerView {
            dayView.delegate = self
            if let dayViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("DayViewController") as? DayViewController {
                dayViewController.day = UserDataController.sharedController().dayForDate(Date(date: NSDate()))
                navigationController?.pushViewController(dayViewController, animated: false)
            }
        } else {
            assert(false)
        }
    }
    
    func datePickerView(view: RSDFDatePickerView!, didSelectDate date: NSDate!) {
        let day = UserDataController.sharedController().dayForDate(Date(date: date))
        performSegueWithIdentifier("DaySegue", sender: day)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? DayViewController {
            destination.day = sender as? Day
        }
    }
    
}
