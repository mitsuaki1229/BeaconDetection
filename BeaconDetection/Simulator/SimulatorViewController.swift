//
//  SimulatorViewController.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/08/01.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SimulatorViewController: UIViewController {
    
    private let viewModel = SimulatorViewModel()
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        self.view = SimulatorView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false
        
        let simulatorView = self.view as! SimulatorView
        
        viewModel.proximityUUID.subscribe(onNext: { u in
            simulatorView.uuidLabel.text = u.uuidString
        }).disposed(by: disposeBag)
        
        viewModel.major.subscribe(onNext: { i in
            simulatorView.majorLabel.text = String(i)
            }).disposed(by: disposeBag)
        
        viewModel.minor.subscribe(onNext: { i in
            simulatorView.minorLabel.text = String(i)
        }).disposed(by: disposeBag)
        
        viewModel.identifier.subscribe(onNext: { s in
            simulatorView.identifierLabel.text = s
        }).disposed(by: disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
