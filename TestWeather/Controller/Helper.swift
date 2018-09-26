//
//  Helper.swift
//  TestWeather
//
//  Created by Данил on 9/20/18.
//  Copyright © 2018 Dareniar. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreData

class Helper {
    
    //MARK: - Shared Properties
    
    static let shared = Helper()
    
    let basicURL = "https://api.darksky.net/forecast/7b98a80047308516204ad5d82bb210b7/"
    
    var weatherJSON: JSON?
    
    var weatherSaved: [WeatherData]?
    
    var keys: [String]?
    
    var cityDictionary = [String: [City]]()
    
    //MARK: - Shared Methods
    
    func fetchWeatherData(latitude: Double, longitude: Double, completion: ( () -> ())?) {
        
        if let url = URL(string: "\(self.basicURL)\(latitude),\(longitude)") {
            
            Alamofire.request(url, method: .get, parameters: ["units":"si"]).responseJSON {
                
                response in
                if response.result.isSuccess {
                    
                    self.weatherJSON = JSON(response.result.value!)
                    completion?()
                } else {
                    print("Error \(String(describing: response.result.error)).")
                }
            }
        } else {
            print("Can't convert String to URL!")
        }
    }
        
    func getDayOfWeek(with date: Date) -> String {
        
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: date)
        
        switch weekDay {
        case 1:
            return "Mon"
        case 2:
            return "Tue"
        case 3:
            return "Wed"
        case 4:
            return "Thu"
        case 5:
            return "Fri"
        case 6:
            return "Sat"
        default :
            return "Sun"
        }
    }
    
    func getImage(with icon: String) -> UIImage {
        
        switch (icon) {
            
        case "clear-day", "clear-night" :
            return UIImage(named: "Sunny")!
            
        case "rain":
            return UIImage(named: "Rain")!
            
            
        case "cloudy":
            return UIImage(named: "Cloudy")!
        
        case "thunderstorm":
            return UIImage(named: "Thunder")!
            
        default :
            return UIImage(named: "Cloud")!
        }
    }
}
