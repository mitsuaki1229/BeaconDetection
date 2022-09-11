//
//  DescriptionView.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/08/12.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import UIKit
import WebKit

class DescriptionView: UIView, CustomView {
    
    let displayArea = WKWebView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if #available(iOS 13.0, *), UITraitCollection.current.userInterfaceStyle == .dark {
        } else {
            backgroundColor = .white
        }
        
        addSubviews()
        installConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(displayArea)
    }
    
    func installConstraints() {
        displayArea.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
}
