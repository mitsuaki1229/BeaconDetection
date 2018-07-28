//
//  DetectionView.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/09/19.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import SnapKit
import UIKit

class DetectionView: UIView, CustomView {
    
    let proximityUUIDInputTextField = { () -> UITextField in
        let textField = UITextField()
        textField.roundBorder(placeholderText: "proximityUUID")
        textField.keyboardType = .asciiCapable
        return textField
    }()
    
    let majorInputTextField = { () -> UITextField in
        let textField = UITextField()
        textField.roundBorder(placeholderText: "major")
        textField.keyboardType = .numberPad
        return textField
    }()
    
    let minorInputTextField = { () -> UITextField in
        let textField = UITextField()
        textField.roundBorder(placeholderText: "minor")
        textField.keyboardType = .numberPad
        return textField
    }()
    
    let statusLabel = UILabel()
    let detectionInfoTableView = { () -> UITableView in
        let tableView = UITableView()
        tableView.layer.borderWidth = 1.0
        tableView.layer.borderColor = UIColor.black.cgColor
        return tableView
    }()
    
    private var tabBarHeight: CGFloat {
        return UITabBarController().tabBar.frame.size.height
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubviews()
        installConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        
        addSubview(proximityUUIDInputTextField)
        addSubview(majorInputTextField)
        addSubview(minorInputTextField)
        addSubview(statusLabel)
        addSubview(detectionInfoTableView)
    }
    
    func installConstraints() {
        
        proximityUUIDInputTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(majorInputTextField.snp.left).offset(-20)
            make.height.equalTo(30)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(proximityUUIDInputTextField.snp.bottom).offset(10)
            make.left.right.equalTo(proximityUUIDInputTextField)
        }
        
        majorInputTextField.snp.makeConstraints { make in
            make.top.equalTo(proximityUUIDInputTextField)
            make.right.equalToSuperview().offset(-10)
            make.width.equalToSuperview().multipliedBy(0.2)
        }
        
        minorInputTextField.snp.makeConstraints { make in
            make.top.equalTo(statusLabel)
            make.left.right.equalTo(majorInputTextField)
        }
        
        detectionInfoTableView.snp.makeConstraints { make in
            make.top.equalTo(minorInputTextField.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-tabBarHeight)
        }
    }
}
