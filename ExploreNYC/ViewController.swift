//
//  ViewController.swift
//  ExploreNYC
//
//  Created by Paul Sayad on 4/25/22.
//

import UIKit
import MapKit
import AudioToolbox

class ViewController: UIViewController {

    @IBOutlet weak var aodLabel: UILabel!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var boroughLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var testButton: UIButton!
    @IBOutlet weak var exploreButton: UIButton!
    
    var areaOfDay = ""
    var soundID: SystemSoundID = 0
    
    var darkMode = false
    //var darkMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ExploreNYC"
        
        darkMode = UserDefaults.standard.bool(forKey: "theme")
        
        if(darkMode) {
            self.view.backgroundColor = .lightGray
            exploreButton.backgroundColor = .black
            exploreButton.setTitleColor(.white, for: .normal)
        }
        
        testButton.layer.cornerRadius = 12
        
        loadSoundEffect("Sound.caf")
        playSoundEffect()
        
        // URL for NYC Open Data Neighborhood API
        let url = "https://data.cityofnewyork.us/resource/xyye-rtrs.json"
        
        // Calls func to getData using URL and stores it in result
        let result = getArea(from: url)
        
        aodLabel.adjustsFontSizeToFitWidth = true
        areaLabel.adjustsFontSizeToFitWidth = true
        boroughLabel.adjustsFontSizeToFitWidth = true
        
        // Sets the Labels to the Neighborhood and Borough retrieved from result variable
        self.areaLabel.text = result.0
        self.boroughLabel.text = result.1
        
        areaOfDay = result.0 + " " + result.1
        UserDefaults.standard.set(areaOfDay, forKey: "AOD")
        
        let location = CLLocation(latitude: result.2[1], longitude: result.2[0])
        mapView.centerToLocation(location)
    }
    
    // TESTING FUNCTIONS TO SHOW IT WORKS INFINITE NUMBER OF TIMES
    @IBAction func testFunc(_ sender: UIButton) {
        self.animateView(sender)
        playSoundEffect()
        
        // URL for NYC Open Data Neighborhood API
        let url = "https://data.cityofnewyork.us/resource/xyye-rtrs.json"
        
        // Calls func to getData using URL and stores it in result
        let result = getArea(from: url)
        
        // Sets the Labels to the Neighborhood and Borough retrieved from result variable
        self.areaLabel.text = result.0
        self.boroughLabel.text = result.1

        areaOfDay = result.0 + " " + result.1
        UserDefaults.standard.set(areaOfDay, forKey: "AOD")
        
        let location = CLLocation(latitude: result.2[1], longitude: result.2[0])
        mapView.centerToLocation(location)
    }
    
    // Makes API call to NYC Open Data Neighborhood Database
    // Returns Neighborhood and Borough
    func getArea(from url: String) -> (String, String, Array<Double>) {
        
        // Varialbes to be returned
        var neighborhood: String?
        var borough: String?
        var coords: Array<Double>?
        
        // Setup for Return call to wait until API call is finished
        let group = DispatchGroup()
        
        // Enter Call
        group.enter()
        
        // Async Task - Actual API call
        DispatchQueue.global(qos: .default).async {
            let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: {data, response, error in
                
                // If Error, Return out of func
                guard let data = data, error == nil else {
                    print("Error")
                    return
                }
                
                // If Data was acquired, decode it using our struct
                var result: [MyData]?
                do {
                    result = try JSONDecoder().decode([MyData].self, from: data)
                } catch {
                    print("Failure: \(error.localizedDescription)")
                    print(String(describing: error))
                }
                
                // If we dont have our object, Return out of func
                guard let json = result else {
                    return
                }
                
                // Gets random area from the JSON
                let area = json.randomElement()
                
                // Setting Variables to Neighborhood and Borough
                neighborhood = area?.name
                borough = area?.borough
                coords = area?.the_geom.coordinates
                
                // Leave Call
                group.leave()
            })
            
            // Sends the request
            task.resume()
        }
        
        // Wait Call - Waiting for the (1) Leave call since there was (1) Enter call
        group.wait()
        
        // Returning Neighborhood and Borough
        return (neighborhood ?? "DEFAULT" , borough ?? "DEFAULT", coords ?? [40.7128, 74.0060])
    }
    
    // MARK: - Animation effects
    fileprivate func animateView (_ viewToAnimate: UIView) {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
            
            viewToAnimate.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            
        }) { (_) in
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
                    viewToAnimate.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        }
    }
    
    @IBAction func settingsButton(_ sender: Any) {
        let settingsVC = storyboard?.instantiateViewController(identifier: "settings") as! SettingsViewController
        settingsVC.delegate = self
        show(settingsVC, sender: nil)
    }
    
    // MARK: - Sound effects
    func loadSoundEffect(_ name: String) {
        if let path = Bundle.main.path(forResource: name, ofType: nil) {
            let fileURL = URL(fileURLWithPath: path, isDirectory: false)
            let error = AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundID)
            if error != kAudioServicesNoError {
                print("Error code (error) loading sound: (path)")
            }
        }
    }
    
    func unloadSoundEffect() {
        AudioServicesDisposeSystemSoundID(soundID)
        soundID = 0
    }
    
    func playSoundEffect() {
        AudioServicesPlaySystemSound(soundID)
    }
 
//    // MARK: - Segue Func
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard segue.identifier == "events" else {return}
//        let vc = segue.destination as! EventsViewController
//        print("pre:")
//        print(areaOfDay)
//        vc.finalAreaOfDay = areaOfDay
//    }
}

// Created Structs to store data (bytes) to my objects
// Codable - Converts Data from Network Call to Class/Struct

struct MyData: Codable {
    let the_geom: MyGeom
    let objectid: String
    let name: String
    let stacked: String
    let annoline1: String
    let annoline2: String
    let annoline3: String
    let annoangle: String
    let borough: String
}

struct MyGeom: Codable {
    let type: String
    let coordinates: [Double]
}



private extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 1700
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}

extension ViewController: SettingsViewControllerDelegate {
    func flipDarkMode(enabled: Bool) {
        print(darkMode)
        if(!darkMode){
            self.view.backgroundColor = .lightGray
            exploreButton.backgroundColor = .black
            exploreButton.setTitleColor(.white, for: .normal)
            darkMode = true
        } else {
            self.view.backgroundColor = .systemTeal
            exploreButton.backgroundColor = .lightGray
            exploreButton.setTitleColor(.black, for: .normal)
            darkMode = false
        }

        UserDefaults.standard.set(darkMode, forKey: "theme")
    }
}

/*
    Code for API call from
    "Getting Data from API in Swift + iOS (Xcode 11 tutorial) - Beginners" via "iOS Academy" on Youtube
    (https://www.youtube.com/watch?v=sqo844saoC4)
  
    Code for MapKit from
    "MapKit Tutorial: Getting Started" via "Andrew Tetlaw" on raywenderlich
    (https://www.raywenderlich.com/7738344-mapkit-tutorial-getting-started)
   
    Code for Spring Animation from
    "Button Tap Spring Animation - UIButton Spring Animations in Swift & Xcode" via "maxcodes" on Youtube
    (https://www.youtube.com/watch?v=9MHG6JWGUP8)
*/
