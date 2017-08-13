//
//  SettingViewModel.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/07/30.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import RxDataSources

struct SettinglistData {
    var title: String
}

struct SectionSettingListData {
    var header: String
    var items: [Item]
}

extension SectionSettingListData: SectionModelType {
    
    typealias Item = SettinglistData
    
    init(original: SectionSettingListData, items: [Item]) {
        self = original
        self.items = items
    }
}

class SettingViewModel: NSObject {
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionSettingListData>()
    
    override init() {
        super.init()
        
        dataSource.configureCell = {ds, tv, ip, item in
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell") ?? SettingListTableViewCell(style: .default, reuseIdentifier: "Cell")
            
            cell.textLabel?.text = item.title
            
            return cell
        }
        
        dataSource.titleForHeaderInSection = {ds, index in
            ds.sectionModels[index].header
        }
    }
}
