//
//  DetailWeatherViewController.swift
//  TestWeather
//
//  Created by Данил on 9/20/18.
//  Copyright © 2018 Dareniar. All rights reserved.
//

import UIKit
import SwiftyJSON
import JGProgressHUD

class DetailWeatherViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var latitude: Double?
    var longitude: Double?
    var condition: String?
    var temperature: Int?
    
    var selectedItemIndex: Int?
    
    var buttonSystemItem: UIBarButtonItem.SystemItem?

    @IBOutlet weak var conditionImage: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var precipLabel: UILabel!
    
    @IBOutlet weak var conditionImage1: UIImageView!
    @IBOutlet weak var temperatureLabel1: UILabel!
    @IBOutlet weak var dayLabel1: UILabel!
    
    @IBOutlet weak var conditionImage2: UIImageView!
    @IBOutlet weak var temperatureLabel2: UILabel!
    @IBOutlet weak var dayLabel2: UILabel!
    
    @IBOutlet weak var conditionImage3: UIImageView!
    @IBOutlet weak var temperatureLabel3: UILabel!
    @IBOutlet weak var dayLabel3: UILabel!
    
    @IBOutlet weak var conditionImage4: UIImageView!
    @IBOutlet weak var temperatureLabel4: UILabel!
    @IBOutlet weak var dayLabel4: UILabel!
    
    @IBOutlet weak var conditionImage5: UIImageView!
    @IBOutlet weak var temperatureLabel5: UILabel!
    @IBOutlet weak var dayLabel5: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Helper.fetchWeatherData(latitude: latitude!, longitude: longitude!) {
            self.update(with: Helper.weatherJSON!)
        }
        
        guard let buttonSystemItem = buttonSystemItem else { return }
        
        if buttonSystemItem == .add {
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: buttonSystemItem, target: self, action: #selector(addItem(sender:)))
            
        } else if buttonSystemItem == .trash {
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: buttonSystemItem, target: self, action: #selector(deleteItem(sender:)))
        }
    }
    
    //MARK: - Updating UI
    
    func update(with json: JSON) {
        
        temperature = Int(json["currently"]["temperature"].doubleValue)
        condition = json["currently"]["icon"].stringValue
        
        conditionImage.image = Helper.getImage(with: json["currently"]["icon"].stringValue)
        temperatureLabel.text = "\(json["currently"]["temperature"].intValue) °C"
        windSpeedLabel.text = "\(json["currently"]["windSpeed"].intValue)  m/s"
        humidityLabel.text = "\(Int(json["currently"]["humidity"].doubleValue * 100))%"
        precipLabel.text = "\(Int(json["currently"]["precipProbability"].doubleValue) * 100)%"
        
        conditionImage1.image = Helper.getImage(with: json["daily"]["data"][0]["icon"].stringValue)
        temperatureLabel1.text = "\(Int((json["daily"]["data"][0]["temperatureHigh"].doubleValue + json["daily"]["data"][0]["temperatureLow"].doubleValue))/2) °C"
        dayLabel1.text = Helper.getDayOfWeek(with: Date(timeIntervalSince1970: TimeInterval(json["daily"]["data"][0]["time"].intValue)))
        
        conditionImage2.image = Helper.getImage(with: json["daily"]["data"][1]["icon"].stringValue)
        temperatureLabel2.text = "\(Int((json["daily"]["data"][1]["temperatureHigh"].doubleValue + json["daily"]["data"][1]["temperatureLow"].doubleValue))/2) °C"
        dayLabel2.text = Helper.getDayOfWeek(with: Date(timeIntervalSince1970: TimeInterval(json["daily"]["data"][1]["time"].intValue)))
        
        conditionImage3.image = Helper.getImage(with: json["daily"]["data"][2]["icon"].stringValue)
        temperatureLabel3.text = "\(Int((json["daily"]["data"][2]["temperatureHigh"].doubleValue + json["daily"]["data"][2]["temperatureLow"].doubleValue))/2) °C"
        dayLabel3.text = Helper.getDayOfWeek(with: Date(timeIntervalSince1970: TimeInterval(json["daily"]["data"][2]["time"].intValue)))
        
        conditionImage4.image = Helper.getImage(with: json["daily"]["data"][3]["icon"].stringValue)
        temperatureLabel4.text = "\(Int((json["daily"]["data"][3]["temperatureHigh"].doubleValue + json["daily"]["data"][3]["temperatureLow"].doubleValue))/2) °C"
        dayLabel4.text = Helper.getDayOfWeek(with: Date(timeIntervalSince1970: TimeInterval(json["daily"]["data"][3]["time"].intValue)))
        
        conditionImage5.image = Helper.getImage(with: json["daily"]["data"][4]["icon"].stringValue)
        temperatureLabel5.text = "\(Int((json["daily"]["data"][4]["temperatureHigh"].doubleValue + json["daily"]["data"][4]["temperatureLow"].doubleValue))/2) °C"
        dayLabel5.text = Helper.getDayOfWeek(with: Date(timeIntervalSince1970: TimeInterval(json["daily"]["data"][4]["time"].intValue)))
        
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Data Persisting
    
    @objc func deleteItem(sender: UIBarButtonItem) {
        context.delete(Helper.weatherSaved![selectedItemIndex!])
        saveData()
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func addItem(sender: UIBarButtonItem) {
        
        guard let temperature = temperature else {
            
            let hud = JGProgressHUD(style: .dark)
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.textLabel.text = "Lost Connection"
            hud.show(in: self.view)
            hud.dismiss(animated: true)
        
            return
        }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let newWeather = WeatherData(context: self.context)
        
        newWeather.city = navigationItem.title
        newWeather.condition = condition
        newWeather.temperature = Int16(temperature)
        newWeather.latitude = latitude!
        newWeather.longitude = longitude!
        
        Helper.weatherSaved?.append(newWeather)
        
        saveData()
        
        let hud = JGProgressHUD(style: .dark)
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.textLabel.text = "Added"
        hud.show(in: self.view)
        hud.dismiss(animated: true)
    }
    
    func saveData() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        if let startView = navigationController?.viewControllers[0] as? CitiesCollectionViewController {
            startView.loadData()
        }
    }
}
