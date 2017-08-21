//
//  DescriptionViewController.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/08/12.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import UIKit
import WebKit
import MMMarkdown

class DescriptionViewController: UIViewController {
    
    fileprivate var type:Int = 0
    
    init(type: Int) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func loadView() {
        self.view = DescriptionView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDisplayArea()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate func loadDisplayArea() {
        
        let descriptionView = self.view as! DescriptionView
        
        let fileName = type == 0 ? "LICENSE" : "README"
        
        guard let mdFilePath:String = Bundle.main.path(forResource: fileName, ofType: "md") else {
            return
        }
        
        var md = ""
        var html = ""
        
        do {
            md = try String.init(contentsOfFile: mdFilePath)
        } catch {
            print("md:Error")
        }
        
        do {
            html = try MMMarkdown.htmlString(withMarkdown: md)
        } catch {
            print("html:Error")
        }
        
        descriptionView.displayArea.loadHTMLString(html, baseURL: nil)
    }
}
