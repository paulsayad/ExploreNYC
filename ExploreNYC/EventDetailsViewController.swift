//
//  EventDetailsViewController.swift
//  ExploreNYC
//
//  Created by Paul Sayad on 5/3/22.
//

import UIKit

class EventDetailsViewController: UIViewController {

    @IBOutlet weak var titleDetail: UILabel!
    @IBOutlet weak var picDetail: UIImageView!
    @IBOutlet weak var dateDetail: UILabel!
    @IBOutlet weak var venueDetail: UILabel!
    @IBOutlet weak var addressDetail: UILabel!
    @IBOutlet weak var descriptionDetail: UILabel!
    @IBOutlet weak var detailText: UILabel!
    
    var event: EventResults!
    var downloadTask: URLSessionDownloadTask?
    var darkMode = UserDefaults.standard.bool(forKey: "theme")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Event Details"
        // Do any additional setup after loading the view.
        
        if(darkMode) {
            self.view.backgroundColor = .lightGray
//            titleDetail.textColor = .white
//            dateDetail.textColor = .white
//            venueDetail.textColor = .white
//            addressDetail.textColor = .white
//            descriptionDetail.textColor = .white
//            detailText.textColor = .white
        }
        
        titleDetail.text = event.title
        titleDetail.sizeToFit()
        titleDetail.adjustsFontSizeToFitWidth = true
        
        let pictureURL = event?.thumbnail
        picDetail.image = UIImage(systemName: "square")
        if let smallURL = URL(string: pictureURL!) {
            downloadTask = picDetail.loadImage(url: smallURL)
        }
        
        dateDetail.text = (event?.date!.start_date)! + ", " + (event?.date!.when)!
        dateDetail.sizeToFit()
        dateDetail.adjustsFontSizeToFitWidth = true
        
        var venueText = ""
        if(event.venue?.name != nil) {
            venueText = event.venue!.name
            if(event.venue?.rating != nil) {
                venueText = venueText + " - \(event.venue!.rating) Stars from \(event.venue!.reviews) reviews"
            }
        } else {
            venueText = "No Information on Venue"
        }
        
        venueDetail.text = venueText
        venueDetail.sizeToFit()
        venueDetail.adjustsFontSizeToFitWidth = true
        addressDetail.text = event.address?.joined(separator: " ")
        addressDetail.sizeToFit()
        addressDetail.adjustsFontSizeToFitWidth = true
        descriptionDetail.text = event.description
        descriptionDetail.sizeToFit()
        descriptionDetail.adjustsFontSizeToFitWidth = true
    }
}
