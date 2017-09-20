//
//  SettingViewController.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/07/30.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SettingViewController: UIViewController {
    
    private let viewModel = SettingViewModel()
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        view = SettingView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = "Description"
        
        let settingView = view as! SettingView
        settingView.listTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        settingView.listTableView.rx.itemSelected
            .map { [weak self] ip in
                return (ip, self?.viewModel.dataSource[ip])
            }
            .subscribe(onNext: { [weak self] ip, ds in
                
                guard let type = DescriptionFileType(rawValue: ip.row) else {
                    return
                }
                
                guard type != .none else {
                    return
                }
                
                let descriptionViewController = DescriptionViewController(type: type)
                self?.navigationController?.pushViewController(descriptionViewController, animated: true)
                
            }).disposed(by: disposeBag)
        
        Observable.just(viewModel.sections)
            .bind(to: settingView
                .listTableView
                .rx
                .items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SettingViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
