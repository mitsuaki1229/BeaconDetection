//
//  DetectionView.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/09/19.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import UIKit
import SnapKit

class DetectionView: UIView {
    
    let detectionInfoTableView = UITableView()
    
    let statusLabel = UILabel()
    let proximityUUIDInputTextField = UITextField()
    let majorInputTextField = UITextField()
    let minorInputTextField = UITextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(statusLabel)
        addSubview(proximityUUIDInputTextField)
        proximityUUIDInputTextField.placeholder = "proximityUUID"
        addSubview(majorInputTextField)
        majorInputTextField.placeholder = "major"
        addSubview(minorInputTextField)
        minorInputTextField.placeholder = "minor"
        
        setInputTextFieldOption(textField: proximityUUIDInputTextField)
        setInputTextFieldOption(textField: majorInputTextField)
        setInputTextFieldOption(textField: minorInputTextField)
        
        addSubview(detectionInfoTableView)
        detectionInfoTableView.layer.borderWidth = 1.0
        detectionInfoTableView.layer.borderColor = UIColor.black.cgColor
    }
    
    private func setInputTextFieldOption(textField :UITextField) {
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.cornerRadius = 5.0
        textField.keyboardType = .asciiCapable
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        statusLabel.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(majorInputTextField.snp.left).offset(-20)
            make.height.equalTo(30)
        }
        
        proximityUUIDInputTextField.snp.remakeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(10)
            make.left.right.equalTo(statusLabel)
        }
        
        majorInputTextField.snp.remakeConstraints { make in
            make.top.equalTo(statusLabel)
            make.right.equalToSuperview().offset(-10)
            make.width.equalToSuperview().multipliedBy(0.2)
        }
        
        minorInputTextField.snp.remakeConstraints { make in
            make.top.equalTo(proximityUUIDInputTextField)
            make.left.right.equalTo(majorInputTextField)
        }
        
        detectionInfoTableView.snp.remakeConstraints { make in
            make.top.equalTo(minorInputTextField.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview()
        }
    }
}
