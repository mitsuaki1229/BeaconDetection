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
    
    var statusLabel = UILabel()
    var proximityUUIDLabel = UILabel()
    var majorLabel = UILabel()
    var minorLabel = UILabel()
    var accuracyLabel = UILabel()
    var rssiLabel = UILabel()
    
    var helpBtn = UIButton()
    var sendBtn = UIButton()
    var retryBtn = UIButton()
    var stopBtn = UIButton()
    
    var simulatorBtn = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(statusLabel)
        self.addSubview(proximityUUIDLabel)
        self.addSubview(majorLabel)
        self.addSubview(minorLabel)
        self.addSubview(accuracyLabel)
        self.addSubview(rssiLabel)
        self.addSubview(helpBtn)
        self.addSubview(sendBtn)
        self.addSubview(retryBtn)
        self.addSubview(stopBtn)
        self.addSubview(simulatorBtn)
        
        self.backgroundColor = UIColor(patternImage: UIImage(named: "MonitoringBackground")!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        helpBtn.snp.remakeConstraints { (make) in
            make.top.equalTo(self).offset(30)
            make.right.equalTo(self)
            make.width.equalTo(100)
            make.height.equalTo(31)
        }
        
        helpBtn.backgroundColor = .brown
        
        helpBtn.setTitle("ヘルプ", for: .normal)
        
        statusLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(self).offset(30)
            make.centerX.equalTo(self)
            make.width.equalTo(100)
            make.height.equalTo(31)
        }
        statusLabel.backgroundColor = .orange
        
        proximityUUIDLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(statusLabel.snp.bottom).offset(0)
            make.centerX.equalTo(self)
            make.width.equalTo(100)
            make.height.equalTo(31)
        }
        
        proximityUUIDLabel.backgroundColor = .blue
        
        majorLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(proximityUUIDLabel.snp.bottom).offset(0)
            make.centerX.equalTo(self)
            make.width.equalTo(100)
            make.height.equalTo(31)
        }
        
        majorLabel.backgroundColor = .yellow
        
        minorLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(majorLabel.snp.bottom)
            make.centerX.equalTo(self)
            make.width.equalTo(100)
            make.height.equalTo(31)
        }
        
        minorLabel.backgroundColor = .purple
        
        accuracyLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(minorLabel.snp.bottom)
            make.centerX.equalTo(self)
            make.width.equalTo(100)
            make.height.equalTo(31)
        }
        
        accuracyLabel.backgroundColor = .cyan

        rssiLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(accuracyLabel.snp.bottom)
            make.centerX.equalTo(self)
            make.width.equalTo(100)
            make.height.equalTo(31)
        }
        
        rssiLabel.backgroundColor = .darkGray

        sendBtn.snp.remakeConstraints { (make) in
            make.top.equalTo(rssiLabel.snp.bottom)
            make.centerX.equalTo(self)
            make.width.equalTo(100)
            make.height.equalTo(31)
        }
        
        sendBtn.backgroundColor = .green
        sendBtn.setTitle("Send", for: .normal)

        retryBtn.snp.remakeConstraints { (make) in
            make.top.equalTo(sendBtn.snp.bottom)
            make.left.equalTo(self)
            make.width.equalTo(100)
            make.height.equalTo(31)
        }
        
        retryBtn.backgroundColor = .groupTableViewBackground
        retryBtn.setTitle("Retry", for: .normal)

        stopBtn.snp.remakeConstraints { (make) in
            make.top.equalTo(sendBtn.snp.bottom)
            make.right.equalTo(self)
            make.width.equalTo(100)
            make.height.equalTo(31)
        }
        
        stopBtn.backgroundColor = .magenta
        stopBtn.setTitle("Stop", for: .normal)
        
        simulatorBtn.snp.remakeConstraints { (make) in
            make.top.equalTo(stopBtn.snp.bottom)
            make.width.equalTo(100)
            make.height.equalTo(31)
            make.centerX.equalTo(self)
        }
        
        simulatorBtn.backgroundColor = .gray
        simulatorBtn.setTitle("Simulator", for: .normal)
    }
}
