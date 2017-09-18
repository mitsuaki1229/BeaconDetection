//
//  DetectionView.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/07/29.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import UIKit
import SnapKit

class DetectionView: UIView {
    
    let statusLabel = UILabel()
    let proximityUUIDLabel = UILabel()
    let majorLabel = UILabel()
    let minorLabel = UILabel()
    let accuracyLabel = UILabel()
    let rssiLabel = UILabel()
    
    let retryBtn = UIButton()
    let stopBtn = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(statusLabel)
        addSubview(proximityUUIDLabel)
        addSubview(majorLabel)
        addSubview(minorLabel)
        addSubview(accuracyLabel)
        addSubview(rssiLabel)
        addSubview(retryBtn)
        addSubview(stopBtn)
        
        backgroundColor = UIColor(patternImage: UIImage(named: "MonitoringBackground")!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        statusLabel.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(31)
        }
        statusLabel.backgroundColor = .orange
        
        proximityUUIDLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(statusLabel.snp.bottom).offset(0)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(31)
        }
        
        proximityUUIDLabel.backgroundColor = .blue
        
        majorLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(proximityUUIDLabel.snp.bottom).offset(0)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(31)
        }
        
        majorLabel.backgroundColor = .yellow
        
        minorLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(majorLabel.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(31)
        }
        
        minorLabel.backgroundColor = .purple
        
        accuracyLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(minorLabel.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(31)
        }
        
        accuracyLabel.backgroundColor = .cyan

        rssiLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(accuracyLabel.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(31)
        }
        
        rssiLabel.backgroundColor = .darkGray
        
        retryBtn.snp.remakeConstraints { (make) in
            make.top.equalTo(rssiLabel.snp.bottom)
            make.left.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(31)
        }
        
        retryBtn.backgroundColor = .groupTableViewBackground
        retryBtn.setTitle("Retry", for: .normal)

        stopBtn.snp.remakeConstraints { (make) in
            make.top.equalTo(rssiLabel.snp.bottom)
            make.right.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(31)
        }
        
        stopBtn.backgroundColor = .magenta
        stopBtn.setTitle("Stop", for: .normal)
    }
}
