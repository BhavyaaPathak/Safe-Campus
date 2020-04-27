//
//  FilterPopupViewController.swift
//  safe_campus
//
//  Created by Bhavya Pathak on 4/21/20.
//  Copyright © 2020 Bhavya Pathak. All rights reserved.
//

import UIKit
import M13Checkbox
import iOSDropDown

class FilterPopupViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var catagoryPicker: UIPickerView!
    @IBOutlet weak var occurancePicker: UIPickerView!
    @IBOutlet weak var zipTF: UITextField!
    @IBOutlet weak var statusPicker: UIPickerView!
    
    var filtersSelected: [String : String?] = [:]
    
    let OcurranceData = ["None", "Recent", "Last 7 days", "Last Month"]
    
    let StatusData = ["All", "Active", "Inactive"]
    
    var delegate: FilterDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.loadCatagoryDropDown()
        self.loadPickers()
    }
    
    func loadPickers() {
        self.occurancePicker.delegate = self
        self.occurancePicker.dataSource = self
        self.statusPicker.delegate = self
        self.statusPicker.dataSource = self
        self.catagoryPicker.delegate = self
        self.catagoryPicker.dataSource = self
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == 1) {
            return OcurranceData.count
        }
        if (pickerView.tag == 2) {
            return StatusData.count
        }
        if (pickerView.tag == 3) {
            return IncidentCatagoryList.list.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView.tag == 1) {
            return OcurranceData[row]
        }
        if (pickerView.tag == 2) {
            return StatusData[row]
        }
        if (pickerView.tag == 3) {
            return IncidentCatagoryList.list[row]
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView.tag == 1) {
            filtersSelected["Occurance"] = OcurranceData[row]
        }
        if (pickerView.tag == 2) {
            filtersSelected["Status"] = StatusData[row]
        }
        if (pickerView.tag == 3) {
            filtersSelected["Catagory"] = IncidentCatagoryList.list[row]
        }
    }
    
//    func loadCatagoryDropDown () {
//        catagoryDropDown.optionArray = IncidentCatagoryList.list
//        //Closure for selected value
//        catagoryDropDown.didSelect{(selectedText, _, _) in
//            self.filtersSelected["Catagory"] = selectedText
//        }
//    }

    
    @IBAction func closePopupBtn(_ sender: UIButton) {
        if (!(zipTF.text!.isEmpty)) {
            self.filtersSelected["Zip"] = zipTF.text!
        }
        
        if (self.filtersSelected["Zip"] == nil && self.filtersSelected["Catagory"] == nil && self.filtersSelected["Occurance"] == nil && self.filtersSelected["Status"] == nil) {
            dismiss(animated:true)
            return
        }
        
        delegate?.filterValueSelected(filters: filtersSelected)
        dismiss(animated:true)
    }
}

