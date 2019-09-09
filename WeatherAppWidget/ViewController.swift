//
//  ViewController.swift
//  WeatherAppWidget
//
//  Created by Niklas Düttmann on 19.05.16.
//  Copyright © 2016 Niklas Düttmann. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var ConstraintIndicator: NSLayoutConstraint!
    @IBOutlet weak var ConstraintButton: NSLayoutConstraint!
    @IBOutlet weak var ReloadButton: UIButton!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var CityLabel: UILabel!
    @IBOutlet weak var TempLabel: UILabel!
    @IBOutlet weak var RainVolLabel: UILabel!
    @IBOutlet weak var WindLabel: UILabel!
    @IBOutlet weak var CountryLabel: UILabel!
    @IBOutlet weak var CloudinessLabel: UILabel!
    
    var
    currentLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)
    var locationManager: CLLocationManager!
    
    
    override func viewDidLoad() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        writeToUI(text: "--", label: TempLabel)
        writeToUI(text: "--", label: RainVolLabel)
        writeToUI(text: "--", label: WindLabel)
        writeToUI(text: "--", label: CloudinessLabel)

        
        getLocationApp()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDataApp(location: CLLocation){
        
        startLoadingIndicator()
        
        let baseUrl: NSURL = NSURL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&APPID=\(AppState.sharedMedia.apiKey)")!
        print(baseUrl)
        let requeste = NSMutableURLRequest(url: baseUrl as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: requeste as URLRequest){
            (data, response, error) -> Void in
            
            if error == nil{
                print("Everything is fine, download successfully")
                
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    
                    if let main = json["main"], let wind = json["wind"], let clouds = json["clouds"], let sys = json["sys"], let name = json["name"] as? String{
                        
                        if let stadtTemp = main!["temp"] as? Int{
                            print("Temperatur: \(stadtTemp)°")
                            self.writeToUI(text: "\(stadtTemp - 273)°", label: self.TempLabel)
                            
                        }
                        if let windSpeed = wind!["speed"] as? Double{
                            print("Windspeed: \(windSpeed)km/h")
                            self.writeToUI(text: "\(windSpeed)km/h", label: self.WindLabel)
                            
                        }
                        if let cloudiness = clouds!["all"] as? Double{
                            print("Cloudiness: \(cloudiness)%")
                            self.writeToUI(text: "\(cloudiness)%", label: self.CloudinessLabel)

                        }
                        if let country = sys!["country"] as? String{
                            print(getCountryWithCode(country))
                            self.writeToUI(getCountryWithCode(country), label: self.CountryLabel)
                            
                        }
                        
                        self.writeToUI(text: "\(name),", label: self.CityLabel)
                    }
                    
                    if let rain = json["rain"]{
                        
                        if let rainVolumen = rain?["1h"] as? Double{
                            print("RainVolumen: \(rainVolumen)m^3")
                            self.writeToUI("\(rainVolumen)", label: self.RainVolLabel)
                            
                        }
                    } else {
                        print("RainVolume: --")
                        self.writeToUI("--", label: self.RainVolLabel)
                    }
                    
                    self.stopLoadingIndicato()
                    
                } catch {
                    print("Error with Json: \(error)")
                }
                
            } else {
                print(error.debugDescription)
            }
        }
        task.resume()
    }

    
    func getLocationApp(){
        //FIXME: Here will be the getLocation function
        getDataApp(currentLocation)
    }
    
    
    @IBAction func UpdateData(sender: AnyObject) {
        getLocationApp()
    }
    
    func startLoadingIndicator(){
        self.ActivityIndicator.startAnimating()
        
        dispatch_async(dispatch_get_main_queue(), {
            self.ConstraintButton.constant = 50
            self.ConstraintIndicator.constant = 0
        })

    }
    
    func stopLoadingIndicato(){
        self.ActivityIndicator.stopAnimating()
        
        dispatch_async(dispatch_get_main_queue(), {
            self.ConstraintButton.constant = 0
            self.ConstraintIndicator.constant = -50
        })

    }
    
    func writeToUI(text: String, label: UILabel){
        dispatch_async(dispatch_get_main_queue(), {
            label.text = text
        })
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location:CLLocation = locations[locations.count-1]
        
        print("locations = \(locations)")
        print("lat: \(location.coordinate.latitude)     ->  long: \(location.coordinate.longitude)")
        
        currentLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
        print("Can't get your location!")
        
    }

    

}

