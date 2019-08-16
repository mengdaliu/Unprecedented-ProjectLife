//
//  planForDay.swift
//  ProjectLife
//
//  Created by liumengda on 2019/8/15.
//  Copyright © 2019 Unprecedented. All rights reserved.
//

import Cocoa

class planForDay: NSViewController {

    @IBOutlet weak var percentage: NSTextField!
    @IBOutlet var comment: PlaceholderTextView!
    @IBOutlet weak var dateMenu: NSMenu!
    var today : Date!
    var tom : Date!
    var yes : Date!
    var dayBeforeYes : Date!
    var dayAfterTom : Date!
    var Selected : Date?
    
    @IBOutlet weak var datePicker: NSPopUpButton!
    @IBOutlet weak var customDatePicker: NSDatePicker!
    @IBOutlet weak var scroll: NSScrollView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor =  .init(gray: 0.9, alpha: 0.8)
        NSLayoutConstraint.init(item: percentage!, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: 30).isActive = true
        let initialPercentage = NSLayoutConstraint.init(item: percentage!, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: 130)
        initialPercentage.priority = NSLayoutConstraint.Priority(rawValue: 250)
        initialPercentage.isActive = true
        let attributes : [NSAttributedString.Key : Any] = [
            NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue) : NSColor.gray,
            NSAttributedString.Key(rawValue : NSAttributedString.Key.font.rawValue) : NSFont.labelFont(ofSize: 14)
        ]
        
        NSLayoutConstraint.init(item: datePicker, attribute: .width, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: 200).isActive = true
        comment.placeholderAttributedString = NSAttributedString.init(string: "optional comment", attributes: attributes)
        comment.drawsBackground = true
        comment.backgroundColor = NSColor.init(cgColor: CGColor.init(gray: 0.92, alpha: 0.5))!
        //comment.placeholderAttributedString =  NSAttributedString(string: "optional   comment on plan", attributes: attributes)
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        customDatePicker.translatesAutoresizingMaskIntoConstraints = false
        percentage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.init(item: self.view, attribute: .height, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: 100).isActive = true
        
        NSLayoutConstraint.init(item: scroll!, attribute: .height, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: 74).isActive = true
        NSLayoutConstraint.init(item: comment!, attribute: .height, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: 74).isActive = true
        
        
        let today = Date.init()
        self.today = today
        let todayHelper = dateUtils.init(date: today, relativeIndicator: 0)
        let todayString = todayHelper.forProjectSet()
        dateMenu.addItem(withTitle: todayString, action: #selector(self.handleSelectToday), keyEquivalent: "tab")
        
        
        let tommorrow = todayHelper.getDay(addBy: 1)
        self.tom = tommorrow
        let tommorrowHelper = dateUtils.init(date: tommorrow, relativeIndicator: 1)
        let tommorrowString = tommorrowHelper.forProjectSet()
        dateMenu.addItem(withTitle: tommorrowString, action: #selector(self.handleSelectTom), keyEquivalent: "command + 1")
        
        let dayAfterTom = todayHelper.getDay(addBy: 2)
        self.dayAfterTom = dayAfterTom
        let dayAfterTomHelper = dateUtils.init(date: dayAfterTom, relativeIndicator: 2)
        let dayAfterTomString = dayAfterTomHelper.forProjectSet()
        dateMenu.addItem(withTitle: dayAfterTomString, action: #selector(self.handleSelectDayAfterTom), keyEquivalent: "command + 2")
        
        let yesterday = todayHelper.getDay(addBy: -1)
        self.yes = yesterday
        let yesterdayHelper = dateUtils.init(date: yesterday, relativeIndicator: -1)
        let yesterdayString = yesterdayHelper.forProjectSet()
        dateMenu.addItem(withTitle: yesterdayString, action: #selector(self.handleSelectYes), keyEquivalent: "command + 3")
        
        let dayBeforeYes = todayHelper.getDay(addBy: -2)
        self.dayBeforeYes = dayBeforeYes
        let dayBeforeYesHelper = dateUtils.init(date: dayBeforeYes, relativeIndicator: 2)
        let dayBeforeYesString = dayBeforeYesHelper.forProjectSet()
        dateMenu.addItem(withTitle: dayBeforeYesString, action: #selector(self.handleSelectDayBeforeYes), keyEquivalent: "command + 4")
        
        dateMenu.addItem(withTitle: "custom", action: #selector(self.handleCustom)
            , keyEquivalent: "command + 5")
        
       
        
        customDatePicker.isEnabled = true
        customDatePicker.isHidden = false
        //customDatePicker.dateValue = today
        
        for item in dateMenu.items {
            item.isEnabled = true
        }
    }
    
    @objc func handleSelectToday() {
        print("hello world")
        self.Selected = self.today
        customDatePicker.isEnabled = false
        customDatePicker.isHidden = true
    }
    
    @objc func handleSelectTom() {
        self.Selected = self.tom
        customDatePicker.isEnabled = false
        customDatePicker.isHidden = true
    }
    
    @objc func handleSelectYes(){
        self.Selected = self.yes
        customDatePicker.isEnabled = false
        customDatePicker.isHidden = true
    }
    
    @objc func handleSelectDayAfterTom() {
        self.Selected = self.dayAfterTom
        customDatePicker.isEnabled = false
        customDatePicker.isHidden = true
    }
    
    @objc func handleSelectDayBeforeYes(){
        self.Selected = self.dayBeforeYes
        customDatePicker.isEnabled = false
        customDatePicker.isHidden = true
    }
    
    @objc func handleCustom(){
        customDatePicker.isEnabled = true
        customDatePicker.isHidden = false
    }
    
    @IBAction func sendCustomValue(_ sender: NSDatePicker) {
        self.Selected = sender.dateValue
    }
    @IBAction func Confirm(_ sender: Any) {
        print("fuckfuckfuck")
    }
    
}


   
class PlaceholderTextView: NSTextView {
    @objc var placeholderAttributedString: NSAttributedString?
}
   
