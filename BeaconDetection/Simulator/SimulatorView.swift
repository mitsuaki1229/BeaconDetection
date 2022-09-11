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
    
    private let uuidItemNameLabel = { () -> UILabel in
        let label = UILabel()
        label.text = "UUID:"
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let majorItemNameLabel = { () -> UILabel in
        let label = UILabel()
        label.text = "major:"
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let minorItemNameLabel = { () -> UILabel in
        let label = UILabel()
        label.text = "minor:"
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let itemNameStackView = { () -> UIStackView in
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        return stackView
    }()
    
    let uuidLabel = { () -> UILabel in
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    let majorLabel = UILabel()
    let minorLabel = UILabel()
    
    let backgroundImageView = { () -> UIImageView in
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "SimulatorBackground")
        return imageView
    }()
    
    private let simulatorTerminalImageView = { () -> UIImageView in
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "SimulatorTerminal")
        return imageView
    }()
    
    private let itemStackView = { () -> UIStackView in
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        return stackView
    }()
    
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
