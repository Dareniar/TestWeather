//
//  CitiesCollectionViewController.swift
//  TestWeather
//
//  Created by Данил on 9/19/18.
//  Copyright © 2018 Dareniar. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class CitiesCollectionViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    
    let locationManager = CLLocationManager()
    var latitude: Double?
    var longitude: Double?
    var cityName: String?
    
    var selectedItem: IndexPath?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib.init(nibName: "CitiesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CityCell")
        }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }
    
    func loadData(with request: NSFetchRequest<WeatherData> = WeatherData.fetchRequest()) {
        
        do {
            Helper.weatherSaved = try context.fetch(request)
            
            guard let weatherData = Helper.weatherSaved else { return }
            
            for weather in weatherData {
                Helper.fetchWeatherData(latitude: weather.latitude, longitude: weather.longitude) {
                    
                    weather.condition = Helper.weatherJSON!["currently"]["icon"].stringValue
                    weather.temperature = Int16(Helper.weatherJSON!["currently"]["temperature"].doubleValue)
                }
            }
            do {
                try self.context.save()
            } catch {
                print("Error saving context \(error)")
            }
        } catch {
            print("Error fetching data from context \(error)")
        }
        collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "currentLocation" {
            
            let destinationVC = segue.destination as! DetailWeatherViewController
            destinationVC.longitude = longitude
            destinationVC.latitude = latitude
            destinationVC.navigationItem.title = "Current Location"
            
        } else if segue.identifier == "detailView" {
            
            let destinationVC = segue.destination as! DetailWeatherViewController
            destinationVC.longitude = longitude
            destinationVC.latitude = latitude
            destinationVC.buttonSystemItem = UIBarButtonItem.SystemItem.trash
            destinationVC.selectedItemIndex = Int(selectedItem!.row)
            destinationVC.navigationItem.title = cityName
        }
    }
}

//MARK: - Collection View Conformation

extension CitiesCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let weatherData = Helper.weatherSaved {
            return weatherData.count
        } else { return 1 }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let availableWidth = view.frame.width - 20
        let widthPerItem = availableWidth / 3.1
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CityCell", for: indexPath) as! CitiesCollectionViewCell
        cell.configure(at: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        longitude = Helper.weatherSaved![indexPath.row].longitude
        latitude = Helper.weatherSaved![indexPath.row].latitude
        cityName = Helper.weatherSaved![indexPath.row].city
        
        selectedItem = indexPath
        
        performSegue(withIdentifier: "detailView", sender: self)
    }
}

//MARK: - Core Location Functionality

extension CitiesCollectionViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            longitude = Double(location.coordinate.longitude)
            latitude = Double(location.coordinate.latitude)
        }
        performSegue(withIdentifier: "currentLocation", sender: self)
    }
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}
