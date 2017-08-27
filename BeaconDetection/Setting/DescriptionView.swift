//
//  DescriptionView.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/08/12.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import UIKit
import WebKit

class DescriptionView: UIView {

    let displayArea = WKWebView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(displayArea)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        displayArea.snp.remakeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
}
