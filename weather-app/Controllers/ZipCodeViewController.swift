//
//  ZipCodeViewController.swift
//  weather-app
//
//  Created by Tanner Carter on 10/2/18.
//  Copyright © 2018 Tanner Carter. All rights reserved.
//

import UIKit

class ZipCodeViewController: UIViewController, UITextFieldDelegate {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var zipCode: UITextField!
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        
        zipCode.becomeFirstResponder()
        zipCode.delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCount = textField.text?.count ?? 0
        
        if range.length + range.location > currentCount {
            return false
        }
        
        let newLength = currentCount + string.count - range.length
        return newLength <= 5
    }
    
    @IBAction func onContinuePressed(_ sender: Any) {
        if zipCode.text == nil {
            return
        } else if zipCode.text!.count < 5 {
            return
        }
        
        performSegue(withIdentifier: "zipToWeather", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "zipToWeather" {
            let weatherController = segue.destination as! WeatherViewController
            weatherController.zipCode = Int(zipCode.text!)
        }
    }
}
