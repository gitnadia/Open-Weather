//
//  ViewController.swift
//  OpenWeather
//
//  Created by nadezda.gura 
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    
    
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    //previously created class
    
    let weatherDatamODEL = WeatherDataModel()
    let locationManager = CLLocationManager() //entry point to the location service
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    //MARK - CLLocationManager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            print("Long: \(location.coordinate.longitude), lat: \(location.coordinate.latitude)")
            
            let long = String(location.coordinate.longitude)
            let lat = String(location.coordinate.latitude)
            
            let params: [String: String] = ["lat" : lat, "lon": long, "appid" : weatherDatamODEL.apiId]
            getWeatherData(url: weatherDatamODEL.apiUrl, params: params)
            
            
        }
    }
    
    func getWeatherData(url: String, params: [String: String]){
        AF.request(url, method: .get, parameters: params).responseJSON {
            response in
            if response.value != nil {
                let weatherJSON: JSON = JSON(response.value!)
                print("weatherJSON: ", weatherJSON)
                self.updateWeatherData(json: weatherJSON)
            }else{
                self.cityLabel.text = "weather unavailable"
            }
        }
    }
    
    func updateWeatherData(json: JSON) {
        if let tempResult = json["main"]["temp"].double {
            weatherDatamODEL.temp = Int(tempResult - 273.15)
            
            weatherDatamODEL.city = json["name"].stringValue
            weatherDatamODEL.condition = json["weather"][0]["id"].intValue
            weatherDatamODEL.weatherIconName = weatherDatamODEL.updateWeatherIcon(condition: weatherDatamODEL.condition)
            updateUI()
            
        }else{
            self.cityLabel.text = "Weather unavailable"
        }
    }
    
    func updateUI(){
        cityLabel.text = weatherDatamODEL.city
        tempLabel.text = "\(weatherDatamODEL.temp)"
        weatherIcon.image = UIImage(named: weatherDatamODEL.weatherIconName)
    }
    
    func userEnterCityName(city: String) {
        print(city)
        
        //getting params
        
        let params: [String: String] = ["q": city, "appid" : weatherDatamODEL.apiId]
        getWeatherData(url: weatherDatamODEL.apiUrl, params: params)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "city"{
            let vc = segue.destination as! ChangeCityViewController
            vc.delegate = self
        }
    }
}

