//
//  ViewController.swift
//  Web
//
//  Created by Sergio on 25/09/18.
//  Copyright © 2018 Sergio. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var lbMessage: UILabel!
    var word: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSearch.isEnabled = false
        lbMessage.text = ""
    }
    @IBAction func textFieldChanged(_ sender: Any) {
        if !textField.text!.isEmpty{
            btnSearch.isEnabled=true
        }else{
            btnSearch.isEnabled=false
        }
        self.lbMessage.text = ""
    }
    

    @IBAction func searchWord(_ sender: Any) {
        if !textField.text!.isEmpty{
            word = textField.text!
            
            let preparatedWord = word?.replacingOccurrences(of: " ", with: "%20")
            let urlApiWiki = URL(string: "https://es.wikipedia.org/w/api.php?action=query&prop=extracts&format=json&exintro=&titles=\(preparatedWord!)")
            let task = URLSession.shared.dataTask(with: urlApiWiki!){(data,response,error) in
                    if error != nil{
                        print(error!)
                    }else{
                        do{
                            let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:Any]
                            let query = json["query"] as! [String:Any]
                            let pages = query["pages"] as! [String:Any]
                            let pageKeys = pages.keys
                            let pageId = pageKeys.first!
                            if pageId != "-1" {
                                let extract = pages[pageId] as! [String:Any]
                                let htmlSource = extract["extract"] as! String
                                DispatchQueue.main.sync(execute: {
                                    self.webView.loadHTMLString(htmlSource, baseURL: nil)
                                })
                            }else{
                                DispatchQueue.main.sync(execute: {
                                    self.lbMessage.text = "Palabra no encontrada - Pruebe intentando de manera diferente"
                                })
                            }
                        }catch{
                            print("error al leer el json")
                        }
                    }
                }
            task.resume()
        }
    }
}

