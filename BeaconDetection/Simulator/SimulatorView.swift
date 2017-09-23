//
//  SimulatorView.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/08/01.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import UIKit
import SnapKit

class SimulatorView: UIView, CustomView {
    
    let backgroundScrollView = UIScrollView()
    private let contentView = UIView()
    
    private let uuidItemNameLabel = UILabel()
    private let majorItemNameLabel = UILabel()
    private let minorItemNameLabel = UILabel()
    
    private let itemNameStackView = UIStackView()
    
    let uuidLabel = UILabel()
    let majorLabel = UILabel()
    let minorLabel = UILabel()
    
    let backgroundImageView = UIImageView()
    private let simulatorTerminalImageView = UIImageView()
    
    private let itemStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
        addSubview(backgroundScrollView)
        backgroundScrollView.addSubview(contentView)
        
        contentView.addSubview(backgroundImageView)
        backgroundImageView.image = UIImage(named: "SimulatorBackground")
        
        contentView.addSubview(simulatorTerminalImageView)
        simulatorTerminalImageView.image = UIImage(named: "SimulatorTerminal")
        
        contentView.addSubview(itemNameStackView)
        itemNameStackView.axis = .vertical
        itemNameStackView.alignment = .leading
        itemNameStackView.distribution = .fillEqually
        itemNameStackView.spacing = 2
        
        itemNameStackView.addArrangedSubview(uuidItemNameLabel)
        uuidItemNameLabel.text = "UUID:"
        uuidItemNameLabel.adjustsFontSizeToFitWidth = true
        itemNameStackView.addArrangedSubview(majorItemNameLabel)
        majorItemNameLabel.text = "major:"
        majorItemNameLabel.adjustsFontSizeToFitWidth = true
        itemNameStackView.addArrangedSubview(minorItemNameLabel)
        minorItemNameLabel.text = "minor:"
        minorItemNameLabel.adjustsFontSizeToFitWidth = true
        
        contentView.addSubview(itemStackView)
        itemStackView.axis = .vertical
        itemStackView.alignment = .leading
        itemStackView.distribution = .fillEqually
        itemStackView.spacing = 2
        
        itemStackView.addArrangedSubview(uuidLabel)
        uuidLabel.lineBreakMode = .byWordWrapping
        uuidLabel.numberOfLines = 2
        itemStackView.addArrangedSubview(majorLabel)
        itemStackView.addArrangedSubview(minorLabel)
        
        installConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func installConstraints() {
        
        backgroundScrollView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
            make.width.equalTo(snp.width)
        }
        
        backgroundImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.width.height.equalTo(contentView.snp.width).multipliedBy(0.7)
        }
        
        simulatorTerminalImageView.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(backgroundImageView)
            make.width.height.equalTo(backgroundImageView.snp.width).multipliedBy(0.7)
        }
        
        itemNameStackView.snp.makeConstraints { make in
            make.top.equalTo(backgroundImageView.snp.bottom)
            make.left.bottom.equalToSuperview().inset(20)
        }
        
        itemStackView.snp.makeConstraints { make in
            make.top.equalTo(itemNameStackView)
            make.bottom.right.equalToSuperview().inset(20)
            make.left.equalTo(itemNameStackView.snp.right)
        }
    }
}
