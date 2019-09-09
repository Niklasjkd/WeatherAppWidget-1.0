//
//  TodayViewController.swift
//  Widget
//
//  Created by Niklas Düttmann on 19.05.16.
//  Copyright © 2016 Niklas Düttmann. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreLocation

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var CityLabel: UILabel!
    @IBOutlet weak var TempLabel: UILabel!
    @IBOutlet weak var RainVolLabel: UILabel!
    @IBOutlet weak var WindLabel: UILabel!
    @IBOutlet weak var CloudinessLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        

        TempLabel.text = "--"
        RainVolLabel.text = "--"
        WindLabel.text = "--"
        CloudinessLabel.text = "--"
        
        getLocationApp()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
    /*func widgetMarginInsetsForProposedMarginInsets
        (defaultMarginInsets: UIEdgeInsets) -> (UIEdgeInsets) {
        return UIEdgeInsetsZero
    }*/

    func getDataApp(location: CLLocation){
        
        let baseUrl: NSURL = NSURL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&APPID=d943befbd2498240fc8b83a088aa0c9e")!
        let requeste = NSMutableURLRequest(URL: baseUrl)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(requeste){
            (data, response, error) -> Void in
            
            if error == nil{
                print("Everything is fine, download successfully")
                
                do{
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    
                    if let main = json["main"], let wind = json["wind"], let clouds = json["clouds"], let rain = json["rain"]{
                        
                        if var stadtTemp = main!["temp"] as? Int{
                            stadtTemp -= 273
                            print("Temperatur: \(stadtTemp)°")
                            self.TempLabel.text = "\(stadtTemp)°"
                        }
                        if let windSpeed = wind!["speed"] as? Double{
                            print("Windspeed is \(windSpeed)km/h")
                            self.WindLabel.text = "\(windSpeed)km/h"
                        }
                        if let cloudiness = clouds!["all"] as? Double{
                            print("Cloudiness: \(cloudiness)%")
                            self.CloudinessLabel.text = "\(cloudiness)%"
                        }
                        if let rainVolumen = rain!["3h"] as? Double{
                            print("RainVolumen\(rainVolumen)")
                            self.RainVolLabel.text = "\(rainVolumen)"
                        }
                    }
                    
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
        
        let meerbusch:CLLocation = CLLocation(latitude: 51.2512949, longitude: 6.6889757000000145)
        
        getDataApp(meerbusch)
    }
    
}
