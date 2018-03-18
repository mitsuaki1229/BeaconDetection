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
    
    let detectionInfoTableView = UITableView()
    
    let statusLabel = UILabel()
    let proximityUUIDInputTextField = UITextField()
    let majorInputTextField = UITextField()
    let minorInputTextField = UITextField()
    
    private var tabBarHeight: CGFloat {
        return UITabBarController().tabBar.frame.size.height
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubviews()
        addOptionalParameters()
        installConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        
        addSubview(statusLabel)
        addSubview(proximityUUIDInputTextField)
        addSubview(majorInputTextField)
        addSubview(minorInputTextField)
        addSubview(detectionInfoTableView)
    }
    
    func addOptionalParameters() {
        
        proximityUUIDInputTextField.placeholder = "proximityUUID"
        majorInputTextField.placeholder = "major"
        minorInputTextField.placeholder = "minor"
        
        setInputTextFieldOption(textField: proximityUUIDInputTextField)
        proximityUUIDInputTextField.keyboardType = .asciiCapable
        setInputTextFieldOption(textField: majorInputTextField)
        majorInputTextField.keyboardType = .numberPad
        setInputTextFieldOption(textField: minorInputTextField)
        minorInputTextField.keyboardType = .numberPad
        
        detectionInfoTableView.layer.borderWidth = 1.0
        detectionInfoTableView.layer.borderColor = UIColor.black.cgColor
    }
    
    func installConstraints() {
        
        statusLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(majorInputTextField.snp.left).offset(-20)
            make.height.equalTo(30)
        }
        
        proximityUUIDInputTextField.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(10)
            make.left.right.equalTo(statusLabel)
        }
        
        majorInputTextField.snp.makeConstraints { make in
            make.top.equalTo(statusLabel)
            make.right.equalToSuperview().offset(-10)
            make.width.equalToSuperview().multipliedBy(0.2)
        }
        
        minorInputTextField.snp.makeConstraints { make in
            make.top.equalTo(proximityUUIDInputTextField)
            make.left.right.equalTo(majorInputTextField)
        }
        
        detectionInfoTableView.snp.makeConstraints { make in
            make.top.equalTo(minorInputTextField.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-tabBarHeight)
        }
    }
    
    private func setInputTextFieldOption(textField: UITextField) {
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.cornerRadius = 5.0
        textField.keyboardType = .asciiCapable
    }
}
