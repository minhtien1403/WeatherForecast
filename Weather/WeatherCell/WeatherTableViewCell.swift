//
//  WeatherTableViewCell.swift
//  Weather
//
//  Created by Tiến on 5/7/20.
//  Copyright © 2020 Tiến. All rights reserved.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {
    
    @IBOutlet var HighTemp: UILabel!
    @IBOutlet var LowTemp: UILabel!
    @IBOutlet var DayLabel: UILabel!
    @IBOutlet var WeatherIcon : UIImageView!

    

    override func awakeFromNib() {
        super.awakeFromNib()
//        backgroundColor = .gray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static let identifier = "WeatherTableViewCell"
       
    static func nib() -> UINib{
           return UINib(nibName: "WeatherTableViewCell", bundle: nil)
       }
    
    func config(with model:DailyWeatherEntry){
        LowTemp.text = "\( Int((Double(model.temperatureLow)-32)/1.8))°C"
        HighTemp.text = "\( Int((Double(model.temperatureHigh)-32)/1.8))°C"
        DayLabel.text = getDayforDate(Date(timeIntervalSince1970: Double(model.time)))
        let icon = model.icon.lowercased()
        if icon.contains("cloud"){
            WeatherIcon.image = UIImage(named: "cloud")
        }
        if icon.contains("rain")
        {
            WeatherIcon.image = UIImage(named: "rain")
        }
        if icon.contains("clear")
        {
            WeatherIcon.image = UIImage(named: "clear")
        }
    }
    
    func getDayforDate(_ date:Date?) -> String{
        guard  let inputdate = date else {
            return ""
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // monday
        return formatter.string(from: inputdate)
    }
}
