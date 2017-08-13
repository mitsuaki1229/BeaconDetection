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
    
    let viewModel = SettingViewModel()
    let disposeBag = DisposeBag()
    
    override func loadView() {
        self.view = SettingView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false
        
        let settingView = self.view as! SettingView
        settingView.listTableView.rx.setDelegate(self)
            .addDisposableTo(disposeBag)
        
        settingView.listTableView.rx.itemSelected
            .map { [weak self] ip in
                return (ip, self?.viewModel.dataSource[ip])
            }
            .subscribe(onNext: { ip, ds in
                print("indexpath:section:\(ip.section) row:\(ip.row)" )
            }).disposed(by: disposeBag)
        
        let sections = [
            SectionSettingListData(header: "Info", items: [
                SettinglistData(title: "License"),
                SettinglistData(title: "Version"),
                SettinglistData(title: "About"),
                ])
        ]
        
        Observable.just(sections)
            .bind(to: settingView
                .listTableView
                .rx
                .items(dataSource: viewModel.dataSource))
            .addDisposableTo(disposeBag)
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
