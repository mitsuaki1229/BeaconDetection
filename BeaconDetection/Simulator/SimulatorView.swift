//
//  SimulatorView.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/08/01.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import UIKit
import SnapKit

class SimulatorView: UIView {
    
    let regenerateButton = UIButton()
    
    private let uuidItemNameLabel = UILabel()
    private let identifierItemNameLabel = UILabel()
    private let majorItemNameLabel = UILabel()
    private let minorItemNameLabel = UILabel()
    
    fileprivate let itemNameStackView = UIStackView()
    
    let uuidLabel = UILabel()
    let identifierLabel = UILabel()
    let majorLabel = UILabel()
    let minorLabel = UILabel()
    
    let backgroundImageView = UIImageView()
    
    fileprivate let itemStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.white
        
        addSubview(backgroundImageView)
        backgroundImageView.image = UIImage(named: "BeaconSimulatorBackground")
        
        addSubview(itemNameStackView)
        itemNameStackView.addArrangedSubview(uuidItemNameLabel)
        uuidItemNameLabel.text = "UUID"
        itemNameStackView.addArrangedSubview(identifierItemNameLabel)
        identifierItemNameLabel.text = "identifier"
        itemNameStackView.addArrangedSubview(majorItemNameLabel)
        majorItemNameLabel.text = "major"
        itemNameStackView.addArrangedSubview(minorItemNameLabel)
        minorItemNameLabel.text = "minor"
        
        addSubview(itemStackView)
        
        itemStackView.addArrangedSubview(uuidLabel)
        itemStackView.addArrangedSubview(identifierLabel)
        itemStackView.addArrangedSubview(majorLabel)
        itemStackView.addArrangedSubview(minorLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundImageView.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().offset(50)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(200)
        }
        
        itemNameStackView.axis = .vertical
        itemNameStackView.alignment = .center
        itemNameStackView.distribution = .fillEqually
        itemNameStackView.spacing = 2
        
        itemNameStackView.snp.remakeConstraints { (make) in
            make.top.equalTo(backgroundImageView.snp.bottom)
            make.left.bottom.equalToSuperview().inset(20)
            make.width.equalTo(200)
        }
        
        itemStackView.axis = .vertical
        itemStackView.alignment = .center
        itemStackView.distribution = .fillEqually
        itemStackView.spacing = 2
        
        itemStackView.snp.remakeConstraints { (make) in
            make.top.equalTo(itemNameStackView)
            make.bottom.right.equalToSuperview().inset(20)
            make.left.equalTo(itemNameStackView.snp.right)
        }
    }
}
