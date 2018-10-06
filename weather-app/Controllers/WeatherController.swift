//
//  WeatherController.swift
//  weather-app
//
//  Created by Tanner Carter on 10/3/18.
//  Copyright © 2018 Tanner Carter. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var locationManager: CLLocationManager?
    var zipCode: Int?
    
    private var owmAPIKey: String = "604fc9863a31ca261d9d2eff4bc4b815"
    private var owmAPIURL: String = "https://api.openweathermap.org/data/2.5/weather"
    
    private var hasLoadedWeather: Bool = false
    private var weatherData: WeatherModel?
    
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var weatherIcon: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var sunrise: UILabel!
    @IBOutlet weak var sunset: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var sunriseSunsetView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        // Hide all views (except for activity indicator) while we are requesting the user's weather data
        setViewsHidden(true)
    }
    
    func setViewsHidden(_ visible: Bool) {
        weatherDescription.isHidden = visible
        temperature.isHidden = visible
        cityName.isHidden = visible
        weatherIcon.isHidden = visible
        sunriseSunsetView.isHidden = visible
    }
    
    override func viewDidLoad() {
        // Determine weather we will be using CoreLocation or just the user's zip code
        
        if locationManager != nil {
            
            locationManager?.delegate = self
            locationManager?.startUpdatingLocation()
            
        } else if zipCode != nil {
            
            retrieveWeather(withZipCode: zipCode!)
            
        } else {
            fatalError("Both locationManager and zipCode were received nil, this is a bad state")
        }
    }
    
    private func retrieveWeather(withLatitude lat: Double, withLongitude lon: Double) {
        // This calls OWM's API with latitude and longitude information from CoreLocation
        
        let apiURL = "\(owmAPIURL)?lat=\(lat)&lon=\(lon)&APPID=\(owmAPIKey)"
        callAPI(withURL: apiURL, withCallback: loadWeatherIntoView)
    }
    
    private func retrieveWeather(withZipCode zip: Int) {
        // Requests weather data using the user's zip code
        // At this time, this only is set to recognize U.S. zip codes
        
        let apiURL = "\(owmAPIURL)?zip=\(zip)&APPID=\(owmAPIKey)"
        callAPI(withURL: apiURL, withCallback: loadWeatherIntoView)
    }
    
    private func loadWeatherIntoView() {
        // Load all the data obtained from OWM into the view
        
        if let data = weatherData {
            cityName.text = data.cityName
            weatherIcon.text = data.icon
            weatherDescription.text = data.conditionDescription
            temperature.text = data.fahrenheit
            
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            formatter.amSymbol = "AM"
            formatter.pmSymbol = "PM"
            
            sunrise.text = formatter.string(from: data.sunrise)
            sunset.text = formatter.string(from: data.sunset)
            
            setViewsHidden(false)
            activityIndicator.isHidden = true
        } else {
            fatalError("weatherData is nil")
        }
    }
    
    private func callAPI(withURL url: String, withCallback cb: @escaping () -> Void) {
        Alamofire.request(url).responseJSON(queue: DispatchQueue.main) { resp in
            switch resp.result {
                
            case .success(let value):
                let json = JSON(value)
                self.weatherData = WeatherModel(json)
                
                // If cityName is nil, chances are we got an error message from OWM
                // If the response contains such a message, display it to the user
                if self.weatherData!.cityName == "" {
                    print(json)
                    
                    if let msg = json["message"].string {
                        // If the error contains something related to the zip code
                        // we shouldn't offer to retry and instead send the user
                        // back to re-enter their zip code
                        if msg.range(of: "city not found") != nil {
                            self.showErrorAlert("invalid zip code", shouldRetry: false)
                        }
                        
                        self.showErrorAlert(msg.lowercased(), shouldRetry: true)
                    } else {
                        self.showErrorAlert("not a clue what happened", shouldRetry: true)
                    }
                    
                    return
                }
                
                self.hasLoadedWeather = true
                cb()
                
            case .failure(let error):
                // If there was a network error, we will display it to the user and offer to try again
                
                self.showErrorAlert(error.localizedDescription.lowercased(), shouldRetry: true)
                print(error)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !hasLoadedWeather {
            retrieveWeather(withLatitude: locations[0].coordinate.latitude, withLongitude: locations[0].coordinate.longitude)
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showErrorAlert(error.localizedDescription.lowercased(), shouldRetry: true)
    }
    
    func showErrorAlert(_ message: String, shouldRetry: Bool) {
        let fullMessage = "Oops! There was an issue getting weather data. Our weatherman said: \(message)"
        
        let alert = UIAlertController(title: "Unable to get weather", message: fullMessage, preferredStyle: .alert)
        
        if shouldRetry {
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
                self.hasLoadedWeather = false
                self.weatherData = nil
                
                self.viewDidLoad()
            }))
        } else {
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.dismiss(animated: true)
            }))
        }
        self.present(alert, animated: true)
    }
}
