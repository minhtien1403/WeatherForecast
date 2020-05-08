//
//  ViewController.swift
//  Weather
//
//  Created by Tiến on 5/7/20.
//  Copyright © 2020 Tiến. All rights reserved.
//

import UIKit
import CoreLocation


class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, CLLocationManagerDelegate {
    
    //setup tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as! WeatherTableViewCell
        cell.config(with: Models[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    @IBOutlet var table:UITableView!
    var Models = [DailyWeatherEntry]()
    var currentWeather:CurrentWeather!
    let locationmanager = CLLocationManager()
    var currentLocation:CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //registry 2 cell
        table.register(HourlyTableViewCell.nib(), forCellReuseIdentifier: HourlyTableViewCell.identifier)
        table.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)
        
        table.delegate = self
        table.dataSource = self
        // Do any additional setup after loading the view.
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLocation()
    }

    //location
    func setupLocation(){
        locationmanager.delegate = self
        locationmanager.requestWhenInUseAuthorization()
        locationmanager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil{
            currentLocation = locations.first
            locationmanager.stopUpdatingLocation()
            requestWeatherForLocation()
        }
    }
    
    func requestWeatherForLocation(){
        guard let currLocation = currentLocation else {
            return
        }
        
        let long = currLocation.coordinate.longitude
        let lat = currLocation.coordinate.latitude
        
        
        let url = "https://api.darksky.net/forecast/ddcc4ebb2a7c9930b90d9e59bda0ba7a/\(lat),\(long)?exclude=[flags,minutely]"
        //let url = "https://api.darksky.net/forecast/ddcc4ebb2a7c9930b90d9e59bda0ba7a/21.009480,107.273040"
        
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: {data, response, error in
            //validation
            guard let data = data, error == nil else{
                print("Something went wrong")
                return
            }
            //convert data to model
            var json : WeatherResponse?
            do{
                json = try JSONDecoder().decode(WeatherResponse.self, from: data)
                
            }
            catch{
                print(error.localizedDescription )
                print("jsondecoder")
            }
            
            guard let result = json else{
                return
            }

            let entries = result.daily.data
            self.Models.append(contentsOf: entries)
            
            let current = result.currently
            self.currentWeather = current
            
            //DispatchQueue.main.async đảm bảo lệnh reload sẽ đc thực hiện bởi mainthread -> Update UI nhanh hơn
            DispatchQueue.main.async {
                self.table.reloadData()
                
                self.table.tableHeaderView = self.createTableHeade()
            }
            
            //update user interface
            }).resume()
        
    }
    func createTableHeade() -> UIView{
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width))
        headerView.backgroundColor = .cyan
        
        let weathertype = UIImageView(frame: CGRect(x: 10, y: 10, width: view.frame.size.width-20, height: headerView.frame.size.height/5))
        
        //let locationLabel = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.size.width-20, height: headerView.frame.size.height/5))
        let summaryLabel = UILabel(frame: CGRect(x: 10, y: 20+weathertype.frame.size.height, width: view.frame.size.width-20, height: headerView.frame.size.height/5))
        let tempLabel = UILabel(frame: CGRect(x: 10, y: 20+weathertype.frame.size.height+summaryLabel.frame.size.height, width: view.frame.size.width-20, height: headerView.frame.size.height/3))
        
        summaryLabel.textAlignment = .center
        //locationLabel.textAlignment = .center
        tempLabel.textAlignment = .center
        
        headerView.addSubview(weathertype)
        headerView.addSubview(summaryLabel)
        headerView.addSubview(tempLabel)
        
        
       
        weathertype.contentMode = .scaleAspectFit
        summaryLabel.text = currentWeather.summary
        tempLabel.text = "\( Int((Double(currentWeather.temperature)-32)/1.8))°C"
        let icon = currentWeather.icon.lowercased()
        if icon.contains("cloud"){
            weathertype.image = UIImage(named: "cloud")
        }
        if icon.contains("rain")
        {
            weathertype.image = UIImage(named: "rain")
        }
        if icon.contains("clear")
        {
            weathertype.image = UIImage(named: "clear")
        }
        
        tempLabel.font = UIFont(name: "Helvetica-Bold", size: 34)

        
        
        return headerView
    }

}
struct WeatherResponse: Codable {
    let latitude: Float
    let longitude: Float
    let timezone: String
    let currently: CurrentWeather
    let hourly: HourlyWeather
    let daily: DailyWeather
    let offset: Float
}

struct CurrentWeather: Codable {
    let time: Int
    let summary: String
    let icon: String
    let nearestStormDistance: Int
    let nearestStormBearing: Int
    let precipIntensity: Int
    let precipProbability: Int
    let temperature: Double
    let apparentTemperature: Double
    let dewPoint: Double
    let humidity: Double
    let pressure: Double
    let windSpeed: Double
    let windGust: Double
    let windBearing: Int
    let cloudCover: Double
    let uvIndex: Int
    let visibility: Double
    let ozone: Double
}

struct DailyWeather: Codable {
    let summary: String
    let icon: String
    let data: [DailyWeatherEntry]
}

struct DailyWeatherEntry: Codable {
    let time: Int
    let summary: String
    let icon: String
    let sunriseTime: Int
    let sunsetTime: Int
    let moonPhase: Double
    let precipIntensity: Float
    let precipIntensityMax: Float
    let precipIntensityMaxTime: Int
    let precipProbability: Double
    let precipType: String?
    let temperatureHigh: Double
    let temperatureHighTime: Int
    let temperatureLow: Double
    let temperatureLowTime: Int
    let apparentTemperatureHigh: Double
    let apparentTemperatureHighTime: Int
    let apparentTemperatureLow: Double
    let apparentTemperatureLowTime: Int
    let dewPoint: Double
    let humidity: Double
    let pressure: Double
    let windSpeed: Double
    let windGust: Double
    let windGustTime: Int
    let windBearing: Int
    let cloudCover: Double
    let uvIndex: Int
    let uvIndexTime: Int
    let visibility: Double
    let ozone: Double
    let temperatureMin: Double
    let temperatureMinTime: Int
    let temperatureMax: Double
    let temperatureMaxTime: Int
    let apparentTemperatureMin: Double
    let apparentTemperatureMinTime: Int
    let apparentTemperatureMax: Double
    let apparentTemperatureMaxTime: Int
}

struct HourlyWeather: Codable {
    let summary: String
    let icon: String
    let data: [HourlyWeatherEntry]
}

struct HourlyWeatherEntry: Codable {
    let time: Int
    let summary: String
    let icon: String
    let precipIntensity: Float
    let precipProbability: Double
    let precipType: String?
    let temperature: Double
    let apparentTemperature: Double
    let dewPoint: Double
    let humidity: Double
    let pressure: Double
    let windSpeed: Double
    let windGust: Double
    let windBearing: Int
    let cloudCover: Double
    let uvIndex: Int
    let visibility: Double
    let ozone: Double
}
