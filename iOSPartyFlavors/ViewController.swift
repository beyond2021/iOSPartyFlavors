//
//  ViewController.swift
//  iOSPartyFlavors
//
//  Created by KEEVIN MITCHELL on 11/27/20.
//

import UIKit

class ViewController: UITableViewController {
    // an array of these things to show on the screen
    var breverages = [Breverage]()
   
    

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    
    //Method to fetch data from server and show on screen
    func fetchData() {
        let url = URL(string: "http:192.168.1.60:8080/breverages")! // bang ! because I know its safe
        URLSession.shared.dataTask(with: url) { data, response, error in
           // it failed
            guard let data = data else {
                print(error?.localizedDescription ?? "Unknown Error")
                return
            }
            //it worked so lets start using it
            let decoder = JSONDecoder()
            
            // if we can get a bevs array from that
            if let bevs = try? decoder.decode([Breverage].self, from: data) {
                //means we got an array of beverages
                // push them to main thread
                DispatchQueue.main.async {
                    // put into our array
                    self.breverages = bevs
                    self.tableView.reloadData()
                    print("loaded \(bevs.count) drinks")
                }
            } else {
                //we got back bad JSON or something
                print("Unable to parse JSON")
            }
            
            
            
        }.resume()
    }
    
    //Methos to show tableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return breverages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // pull out the matching brev to that
        let breverage = breverages[indexPath.row]
        // bev name and price at the top
        // description bottom
        cell.textLabel?.text = "\(breverage.name)- $\(breverage.price)"
        cell.detailTextLabel?.text = breverage.description
        //
        return cell
    }
    //when u tap on a bev show and alert to enter your name
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //1: which bev they tapped?
        let brev = breverages[indexPath.row]
        //show a uialertcontroller
        let ac = UIAlertController(title: "Order a \(brev.name)?", message: "Please enter your name", preferredStyle: .alert)
        //add text field to alert
        ac.addTextField()
        
        //action
        ac.addAction(UIAlertAction(title: "Order it!", style: .default, handler: { (action) in
            //2: did they enter a neame in the textfield or not?
            guard let name = ac.textFields?[0].text  else { return } // bail out if no name entered
            //3; if there is a name
            self.order(brev, name: name)
        }))
        // add a cancel button if they choose the wrong brev
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        // present
        present(ac, animated: true, completion: nil)
    }
    
    
    //place the order
    func order(_ brev: Breverage, name: String) {
        // wrap this in an order object so we can send it to our server
        let order = Order(breverageName: brev.name, buyerName: name)
        // send it off to a url
        let url = URL(string: "http://192.168.1.60:8080/orders")!
        
        //encode our object to JSON to send over the wire. it doesnt know what a struct is
        let encoder = JSONEncoder()
        
        //put the data into an instance of a URLRequest - how to handle complex data trnsmission over the web
        // what kind of http method etc?
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //- writing data to the server
        
        //VERY IMPORTANT the web works with text so u have to tell it what content type it is-html? xml?, JSON? etc
        // ours looks like text but its actually JSON
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // try to send it over the wire
        request.httpBody = try? encoder.encode(order)
        
        //now send it over the wire
        URLSession.shared.dataTask(with: request ) { data, response, error in
            // did we get data back or not?
            if let data = data {
                let decoder = JSONDecoder()
                if let item = try? decoder.decode(Order.self, from: data) {
                    // get order back from wire
                    // if it work
                    print(item.buyerName)
                } else {
                    print("Bad JSON Received back.")
                }
            }
            
        }.resume()
        
    }

}

