//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController ,CLLocationManagerDelegate,cityNameDelegate{
    
    //Constants
    let WEATHER_URL = "https://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "de3875ab621811cc86fb6ac835c32f6a"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String , paramater:[String : String ]){
        Alamofire.request( url , method:.get , parameters : paramater).responseJSON{
            response in
          print(response)
            if response.result.isSuccess{
                print("Success! Go to Weather")
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
            }
            else{
                print("Error \(response.result.error!)")
                self.cityLabel.text = "Connection Issues"
            }
            
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json :JSON)  {
        if   let tempResult = json["main"]["temp"].double {
        weatherDataModel.temperature = Int( tempResult - 273.15)
        weatherDataModel.city = json["name"].stringValue
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            
            updateUIWeatherdata()
    }
        else{
            cityLabel.text = "the weather unavailable"
        }
    }
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWeatherdata() {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            print("longtitude\(location.coordinate.longitude),latitude\(location.coordinate.latitude)")
            let latitude = String( location.coordinate.latitude)
            let longitude = String( location.coordinate.longitude)
            let param :[String :String] = ["lat" : latitude ,"lon": longitude ,"appid": APP_ID]

            getWeatherData(url: WEATHER_URL, paramater: param)
            
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Locations Unavailable"
        
        
        
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    func UsrEnterCityName(city: String) {
        let parms :[String : String] = ["q":city ,"appid":APP_ID]
        getWeatherData(url: WEATHER_URL, paramater: parms)
    }
    
    //Write the userEnteredANewCityName Delegate method here:
    

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
        let distination = segue.destination as!ChangeCityViewController
        distination.delegate = self
        }
    }
    
    
    
    
}


