//
//  ViewController.swift
//  ams-shoutbox
//
//  Created by Kamil on 12/16/17.
//  Copyright © 2017 Kamil. All rights reserved.
//

import UIKit
import DGElasticPullToRefresh
import Alamofire
import SwiftyJSON

class ViewController: UITableViewController {

    var messages: [Message] = []
    let API = "http://10.0.2.2:8080";
    
    @IBAction func onCompose(_ sender: Any) {
        self.showAlert()
    }
    
    func showAlert(){
        let alertController = UIAlertController(title: "New message", message: "Please state your name and message", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Your name"
        } )
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Your message"
        } )
        let sendAction = UIAlertAction(title: "Send", style: .default, handler: { action in
            let name = alertController.textFields?[0].text
            let message = alertController.textFields?[1].text
            if(name != "" && message != ""){
                self.sendAndRefresh(name: name!, message: message!)
            }
        })
        alertController.addAction(sendAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in })
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: { _ in })
    }
    
    func sendAndRefresh(name: String, message: String){
        let parameters: Parameters = [
            "name": name,
            "message": message
        ]
        
        Alamofire.request(self.API, method: .post, parameters: parameters).responseJSON { response in
            self.getMessages(){
                print("Messages loaded")
            }
        }
    }
    
    func getMessages(complete: @escaping () -> Void){
        Alamofire.request(self.API).responseJSON { response in
            if let res = response.result.value {
            let messagesJSON = JSON(res)
            var messages: [Message] = []
            for (_, dict) in messagesJSON {
                messages.append(Message(name: dict["name"].stringValue, message: dict["message"].stringValue, timestamp: dict["timestamp"].intValue))
            }
            let sorted = messages.sorted{$0.timestamp > $1.timestamp};
            
            self.messages = sorted;
            complete()
            
            self.tableView.reloadData();
            }
        }
    }
    
    func getTimeAgo(timestamp: Int) -> Int {
    
        let elapsed = Int(NSDate().timeIntervalSince1970) - timestamp;
        if(elapsed < 0){
            return 0;
        }
        return (elapsed % 3600) / 60
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let message = self.messages[indexPath.item]
        cell.textLabel?.text = "\(getTimeAgo(timestamp: message.timestamp)) minutes ago"
        cell.detailTextLabel?.text = "\(message.name) says: \(message.message)"
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getMessages(){
            print("Messages loaded")
        }
        
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            // Add your logic here
            // Do not forget to call dg_stopLoading() at the end
            self?.getMessages() {
                print("Messages loaded")
                self?.tableView.dg_stopLoading()
            }
            
            }, loadingView: loadingView)
        tableView.dg_setPullToRefreshFillColor(UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0))
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

