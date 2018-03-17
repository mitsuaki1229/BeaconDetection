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
    
    var sections: [SectionSettingListData] {
        
        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        
        return [
            SectionSettingListData(header: "", items: [
                SettinglistData(title: "README"),
                SettinglistData(title: "LICENSE"),
                SettinglistData(title: "Version:" + version)
                ])
        ]
    }
    
    override init() {
        super.init()
        
        dataSource.configureCell = {ds, tv, ip, item in
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell")
                ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
            cell.textLabel?.text = item.title
            
            if DescriptionFileType(rawValue: ip.row) == DescriptionFileType.none {
                cell.selectionStyle = .none
                cell.accessoryType = .none
            } else {
                cell.selectionStyle = .default
                cell.accessoryType = .disclosureIndicator
            }
            
            return cell
        }
        
        dataSource.titleForHeaderInSection = {ds, index in
            ds.sectionModels[index].header
        }
    }
}
