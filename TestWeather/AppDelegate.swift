//
//  AppDelegate.swift
//  TestWeather
//
//  Created by Данил on 9/19/18.
//  Copyright © 2018 Dareniar. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let userDefaults = UserDefaults.standard

        let defaultValues = ["firstRun": true]

        userDefaults.register(defaults: defaultValues)

        if userDefaults.bool(forKey: "firstRun") {

            userDefaults.set(false, forKey: "firstRun")
            
            preloadSQL()
        
        }
        
        do {
            Helper.keys = try persistentContainer.viewContext.fetch(Key.fetchRequest()).map { $0.letter! }
            Helper.keys = Helper.keys!.sorted()
            for key in Helper.keys! {
                Helper.cityDictionary[key] = getCities(for: key)?.sorted {$0.name! < $1.name! }
            }
        } catch {
            print(error)
        }
        
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "TestWeather")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

// MARK: - Preloading SQL DataBase

extension AppDelegate {
    
    func preloadSQL() {
        
        let sqlitePath = Bundle.main.path(forResource: "TestWeather", ofType: "sqlite")
        
        let sourceURL = URL(fileURLWithPath: sqlitePath!)
        let destinationURL = URL(fileURLWithPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/TestWeather.sqlite")
            
        do {
            try FileManager.default.removeItem(atPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/TestWeather.sqlite")
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
        } catch {
            print(error)
        }
    }
    
    func getCities(for key: String) -> [City]? {
        
        let request: NSFetchRequest<City> = City.fetchRequest()
        let predicate = NSPredicate(format: "key.letter MATCHES %@", key)
        request.predicate = predicate
        
        do {
            let cities = try persistentContainer.viewContext.fetch(request)
            return cities
        } catch {
            print("Error fetching data from context \(error)")
            return nil
        }
        
    }
}

// MARK: - Converting cities.json to SQL

//extension AppDelegate {
//
//    func preloadData() {
//
//        let context = persistentContainer.viewContext
//
//        let userDefaults = UserDefaults.standard
//
//        let defaultValues = ["firstRun": true]
//
//        userDefaults.register(defaults: defaultValues)
//
//        if userDefaults.bool(forKey: "firstRun") {
//
//            userDefaults.set(false, forKey: "firstRun")
//
//            // Preload WeatherData
//
//            let defaultCity1 = WeatherData(context: context)
//            defaultCity1.city = "Kyiv"
//            defaultCity1.condition = "clear-day"
//            defaultCity1.temperature = 20
//            defaultCity1.latitude = 50.45466
//            defaultCity1.longitude = 30.5238
//
//            let defaultCity2 = WeatherData(context: context)
//            defaultCity2.city = "Dnipro"
//            defaultCity2.condition = "clear-day"
//            defaultCity2.temperature = 25
//            defaultCity2.latitude = 48.45
//            defaultCity2.longitude = 34.98333
//
//            saveContext()
//
//            // Converting cities.json to .sql database
//
//            var cityDictionary = [String: [City]]()
//
//            if let filepath = Bundle.main.path(forResource: "cities", ofType: "json") {
//                do {
//                    let url = URL(fileURLWithPath: filepath)
//                    let contents = try JSON(data: Data(contentsOf: url))
//                    for i in 0..<contents.count {
//                        let first = contents[i]["name"].stringValue.first!
//                        if first >= "A" && first <= "Z" {
//
//                            let city = City(context: context)
//                            city.name = contents[i]["name"].stringValue
//                            city.longitude = contents[i]["lng"].doubleValue
//                            city.latitude = contents[i]["lat"].doubleValue
//
//                            saveContext()
//                        }
//                    }
//
//                    let cities = try context.fetch(City.fetchRequest()) as! [City]
//
//                    for city in cities {
//                        let firstLetterIndex = city.name!.index(city.name!.startIndex, offsetBy: 1)
//
//                        let key = String(city.name![..<firstLetterIndex])
//
//                        if var values = cityDictionary[key] {
//                            values.append(city)
//                            cityDictionary[key] = values
//                        } else {
//                            cityDictionary[key] = [city]
//                        }
//                    }
//
//                    for (key,values) in cityDictionary {
//                        let newKey = Key(context: context)
//                        newKey.letter = key
//                        for city in values {
//                            city.key = newKey
//                        }
//                        saveContext()
//                    }
//                } catch {
//                    print(error)
//                }
//            } else {
//                print("cities.json wasn't found")
//            }
//        }
//    }
//}

