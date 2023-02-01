//
//  EventsViewController.swift
//  ExploreNYC
//
//  Created by Paul Sayad on 4/27/22.
//

import UIKit

class EventsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var finalAreaOfDay = ""
    var darkMode = UserDefaults.standard.bool(forKey: "theme")
    var events: EventData?
    var downloadTask: URLSessionDownloadTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Events"
        
        if(darkMode){
            self.view.backgroundColor = .lightGray
            tableView.backgroundColor = .lightGray
        }
        
        tableView.dataSource = self
        tableView.delegate = self

        // Do any additional setup after loading the view.
        finalAreaOfDay = UserDefaults.standard.string(forKey: "AOD")!
        finalAreaOfDay = "Events+in+" + finalAreaOfDay.replacingOccurrences(of: " ", with: "+")
        print(finalAreaOfDay)
        
        let api_key = "4c9becd5f1f76305fcd0e9cc4c65866ffd1e7f96c0042face8a84e9311505dca"
        let url = "https://serpapi.com/search.json?engine=google_events&q=\(finalAreaOfDay)&hl=en&gl=us&api_key=" + api_key
        
        let testUrl = "https://serpapi.com/search.json?engine=google_events&q=Events+in+Austin&hl=en&gl=us&api_key=" + api_key
        getEvents(from: url)
    }
        
    func getEvents(from url: String) {
        print(url)
        let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: {data, response, error in

            // If Error, Return out of func
            guard let data = data, error == nil else {
                print("Error")
                return
            }
            
            // If Data was acquired, decode it using our struct
            do {
                print("YES")
                self.events = try JSONDecoder().decode(EventData.self, from: data)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            } catch {
                print("Failure: \(error.localizedDescription)")
                print(String(describing: error))
            }
        })

        // Sends the request
        task.resume()
    }
    
    // Step 2: Implement these two Table View Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events?.events_results.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // dequeue reusable cells reuses cells that are off screen
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell") as! EventCell
        if(darkMode){
            cell.backgroundColor = .lightGray
        }
        let event = events?.events_results[indexPath.row]
        
        let eventTitle = event?.title
        let eventTime = (event?.date!.start_date)! + ", " + (event?.date!.when)!
        let eventAddress = event?.address?[0]
        let eventLocation = event?.address?[1]
        let eventPictureURL = event?.thumbnail
        
        cell.eventTitle.text = eventTitle
        cell.eventTime.text = eventTime
        cell.eventAddress.text = eventAddress
        cell.eventLocation.text = eventLocation
        cell.eventImage.image = UIImage(systemName: "square")
        if let smallURL = URL(string: eventPictureURL!) {
            downloadTask = cell.eventImage.loadImage(url: smallURL)
        }
        
        return cell
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
            
        // Find the selected movie
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)!
        let event = events?.events_results[indexPath.row]
        
        // Pass the selected movie to the details view controller
        let eventDetailsViewController = segue.destination as! EventDetailsViewController
        eventDetailsViewController.event = event
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension UIImageView {
    func loadImage(url: URL) -> URLSessionDownloadTask {
        let session = URLSession.shared
        // 1
        let downloadTask = session.downloadTask(with: url) {
            [weak self] url, _, error in
                // 2
            if error == nil, let url = url,
            let data = try? Data(contentsOf: url), // 3
            let image = UIImage(data: data) {
            // 4
                DispatchQueue.main.async {
                    if let weakSelf = self {
                        weakSelf.image = image
                    }
                }
            }
        }
        // 5
        downloadTask.resume()
        return downloadTask
    }
}

struct EventData: Codable {
    let search_metadata: SearchMetaData
    let search_parameters: SearchParameters
    let search_information: SearchInformation
    let events_results: Array<EventResults>
}

struct SearchMetaData: Codable {
    let id: String
    let status: String
    let json_endpoint: String
    let created_at: String
    let processed_at: String
    let google_events_url: String
    let raw_html_file: String
    let total_time_taken: Float
}

struct SearchParameters: Codable {
    let q: String
    let engine: String
}

struct SearchInformation: Codable {
    let events_results_state: String
}

struct EventResults: Codable {
    let title: String?
    let date: EventDate?
    let address: Array<String>?
    let link: String?
    let event_location_map: EventLocationMap?
    let description: String?
    let ticket_info: Array<TicketInfo>?
    var venue: Venue?
    let thumbnail: String?
}

struct EventDate: Codable {
    let start_date: String
    let when: String
}

struct EventLocationMap: Codable {
    let image: String
    let link: String
    let serpapi_link: String
}

struct TicketInfo: Codable {
    let source: String
    let link: String
    let link_type: String
}

struct Venue: Codable {
    let name: String
    let rating: Float
    let reviews: Int
    let link: String
}
