//
//  WeatherManager.swift
//  Clima
//
//  Created by Onat KILINÇ on 18.06.2024.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    var delegate: WeatherManagerDelegate?
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?APPID=0c1f378322d0502de05d1da930be1c81&units=metric"
    
    func fecthWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequst(with: urlString)
    }
    
    func fecthWeather(latitute: CLLocationDegrees, longitute: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitute)&lon=\(longitute)"
        performRequst(with: urlString)
    }
    
    func performRequst(with urlString: String) {
        //create url
        if let url = URL(string: urlString) {
            //create url session
            let session = URLSession(configuration: .default)
            //give session a task
            let task = session.dataTask(with: url) { data, urlResponse, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                }
                
                if let safeData = data {
                    if let weather = parseJson(safeData) {
                        delegate?.didUpdateWeather(weather: weather)
                    }
                }
            }
            //start task
            task.resume()
        }
    }
    
    func parseJson(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            
            let id = decodedData.weather[0].id
            let temperatue = decodedData.main.temp
            let cityName = decodedData.name
            
            let weatherModel = WeatherModel(conditionId: id, temperature: temperatue, cityName: cityName)
            return weatherModel
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
