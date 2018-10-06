//
//  WeatherModel.swift
//  weather-app
//
//  Created by Tanner Carter on 10/3/18.
//  Copyright © 2018 Tanner Carter. All rights reserved.
//

import Foundation
import SwiftyJSON

class WeatherModel {
    private let WeatherIcons: [String : String] = [
        // Clear sky
        "01d": "", // Day - wi-day-sunny
        "01n": "", // Night - wi-night-clear
        
        // Few clouds
        "02d": "", // Day - wi-day-sunny-overcast
        "02n": "", // Night -wi-night-alt-partly-cloudy
        
        // Scattered clouds
        "03d": "", // Day - wi-day-cloudy
        "03n": "", // Night - wi-night-alt-cloudy
        
        // Broken clouds
        "04d": "", // Day - wi-cloudy
        "04n": "", // Night - wi-night-alt-cloudy-high
        
        // Shower rain
        "09d": "", // Day - wi-showers
        "09n": "", // Night - wi-showers
        
        // Rain
        "10d": "", // Day - wi-day-rain
        "10n": "", // Night - wi-night-alt-showers
        
        // Thunderstorm
        "11d": "", // Day - wi-day-thunderstorm
        "11n": "", // Night - wi-night-alt-storm-showers
        
        // Snow
        "13d": "", // Day - wi-day-snow
        "13n": "", // Night - wi-night-alt-snow
        
        // Mist
        "50d": "", // Day - wi-day-fog
        "50n": "", // Night - wi-night-fog
        
    ]
    
    var cityName: String
    var temperature: Double
    var conditionDescription: String
    var sunset: Date
    var sunrise: Date
    
    private var iconName: String
    
    var fahrenheit: String {
        get {
            return "\(Int((temperature - 273.15) * 9/5 + 32))°F"
        }
    }
    
    var icon: String {
        get {
            if let i = WeatherIcons[iconName] {
                return i
            } else {
                // Return default sunny icon if no icons match, unlikely to happen
                return ""
            }
        }
    }    
    
    init(_ json: JSON) {
        conditionDescription = json["weather"][0]["description"].stringValue.capitalized
        temperature = json["main"]["temp"].doubleValue
        cityName = json["name"].stringValue
        
        sunset = Date(timeIntervalSince1970: json["sys"]["sunset"].doubleValue)
        sunrise = Date(timeIntervalSince1970: json["sys"]["sunrise"].doubleValue)
        
        iconName = json["weather"][0]["icon"].stringValue
    }
}
