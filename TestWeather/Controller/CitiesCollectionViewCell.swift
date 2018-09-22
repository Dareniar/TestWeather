//
//  CitiesCollectionViewCell.swift
//  TestWeather
//
//  Created by Данил on 9/19/18.
//  Copyright © 2018 Dareniar. All rights reserved.
//

import UIKit

class CitiesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var weatherImage: UIImageView!
    
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func configure(at indexPath: IndexPath) {
        
        if let weatherData = Helper.weatherSaved {
            weatherImage.image = Helper.getImage(with: weatherData[indexPath.row].condition!)
            temperatureLabel.text = "\(weatherData[indexPath.row].temperature) °C"
            cityLabel.text = weatherData[indexPath.row].city
        }
    }
}
