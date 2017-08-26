//
//  DescriptionViewModel.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/08/12.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import MMMarkdown

enum DescriptionFileType : Int {
    case license = 0
    case readme
}

class DescriptionViewModel: NSObject {
    
    private var type: DescriptionFileType = .license
    
    init(type: DescriptionFileType) {
        self.type = type
    }
    
    func getHtml() -> String {
        
        let fileName = type == .license ? "LICENSE" : "README"
        
        guard let mdFilePath:String = Bundle.main.path(forResource: fileName, ofType: "md") else {
            return ""
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
        
        return html
    }
}
