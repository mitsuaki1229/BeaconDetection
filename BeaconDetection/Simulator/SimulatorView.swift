//
//  SimulatorView.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/08/01.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import SnapKit
import UIKit

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
        
        addSubviews()
        addOptionalParameters()
        installConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        
        addSubview(backgroundScrollView)
        backgroundScrollView.addSubview(contentView)
        contentView.addSubview(backgroundImageView)
        
        contentView.addSubview(simulatorTerminalImageView)
        contentView.addSubview(itemNameStackView)
        
        itemNameStackView.addArrangedSubview(uuidItemNameLabel)
        itemNameStackView.addArrangedSubview(majorItemNameLabel)
        itemNameStackView.addArrangedSubview(minorItemNameLabel)
        contentView.addSubview(itemStackView)
        
        itemStackView.addArrangedSubview(uuidLabel)
        itemStackView.addArrangedSubview(majorLabel)
        itemStackView.addArrangedSubview(minorLabel)
    }
    
    func addOptionalParameters() {
        
        simulatorTerminalImageView.image = #imageLiteral(resourceName: "SimulatorTerminal")
        
        backgroundImageView.image = #imageLiteral(resourceName: "SimulatorBackground")
        itemNameStackView.axis = .vertical
        itemNameStackView.alignment = .leading
        itemNameStackView.distribution = .fillEqually
        itemNameStackView.spacing = 2
        
        uuidItemNameLabel.text = "UUID:"
        uuidItemNameLabel.adjustsFontSizeToFitWidth = true
        
        majorItemNameLabel.text = "major:"
        majorItemNameLabel.adjustsFontSizeToFitWidth = true
        
        minorItemNameLabel.text = "minor:"
        minorItemNameLabel.adjustsFontSizeToFitWidth = true
        
        itemStackView.axis = .vertical
        itemStackView.alignment = .leading
        itemStackView.distribution = .fillEqually
        itemStackView.spacing = 2
        
        uuidLabel.lineBreakMode = .byWordWrapping
        uuidLabel.numberOfLines = 2
    }
    
    func installConstraints() {
        
        backgroundScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
