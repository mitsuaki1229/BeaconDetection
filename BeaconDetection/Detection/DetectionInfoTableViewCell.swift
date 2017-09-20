//
//  DetectionInfoTableViewCell.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/09/19.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import UIKit
import SnapKit

class DetectionInfoTableViewCell: UITableViewCell {
    
    let uuidLabel = UILabel()
    let majorLabel = UILabel()
    let minorLabel = UILabel()
    let proximityLabel = UILabel()
    let accuracyLabel = UILabel()
    let rssiLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(uuidLabel)
        addSubview(majorLabel)
        addSubview(minorLabel)
        addSubview(proximityLabel)
        addSubview(accuracyLabel)
        addSubview(rssiLabel)
        
        uuidLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().offset(5)
            make.height.equalTo(15)
        }
        
        majorLabel.snp.makeConstraints { make in
            make.top.equalTo(uuidLabel.snp.bottom).offset(5)
            make.left.height.equalTo(uuidLabel)
            make.width.equalTo(50)
        }
        
        minorLabel.snp.makeConstraints { make in
            make.top.equalTo(majorLabel.snp.bottom).offset(5)
            make.left.width.height.equalTo(majorLabel)
        }
        
        proximityLabel.snp.makeConstraints { make in
            make.top.height.equalTo(majorLabel)
            make.left.equalTo(majorLabel.snp.right).offset(5)
            make.right.equalToSuperview().offset(5)
        }
        
        accuracyLabel.snp.makeConstraints { make in
            make.top.equalTo(proximityLabel.snp.bottom).offset(5)
            make.left.height.equalTo(proximityLabel)
            make.right.equalTo(rssiLabel.snp.left).offset(5)
        }

        rssiLabel.snp.makeConstraints { make in
            make.top.height.equalTo(accuracyLabel)
            make.right.equalToSuperview().offset(-5)
            make.width.equalTo(50)
        }
        
        uuidLabel.adjustsFontSizeToFitWidth = true
        majorLabel.adjustsFontSizeToFitWidth = true
        minorLabel.adjustsFontSizeToFitWidth = true
        proximityLabel.adjustsFontSizeToFitWidth = true
        accuracyLabel.adjustsFontSizeToFitWidth = true
        rssiLabel.adjustsFontSizeToFitWidth = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

