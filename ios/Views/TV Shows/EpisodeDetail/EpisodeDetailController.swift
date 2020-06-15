//
//  EpisodeDetailController.swift
//  ios
//
//  Created by Mason Phillips on 6/14/20.
//

import UIKit
import RxDataSources
import RxSwift

class EpisodeDetailController: UIViewController {
    let table = UITableView(frame: .zero, style: .insetGrouped)
    
    let model = EpisodeDetailModel()
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let source = RxTableViewSectionedReloadDataSource<EpisodeDetailSection>(configureCell: { model, table, index, item -> UITableViewCell in
            let cell = table.dequeueReusableCell(withIdentifier: EpisodeDetailCell.identifier, for: index)
            (cell as? EpisodeDetailCell)?.configure(item)
            return cell
        }, titleForHeaderInSection: { section, index -> String in
            section.sectionModels[index].title
        })
        
        table.register(EpisodeDetailCell.self, forCellReuseIdentifier: EpisodeDetailCell.identifier)
        table.rx.setDelegate(self).disposed(by: bag)
        model.dataModel.drive(table.rx.items(dataSource: source)).disposed(by: bag)
        view.addSubview(table)
        
        view.backgroundColor = .white
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        table.fillSuperview()
    }
}

extension EpisodeDetailController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? EpisodeDetailCell
        
    }
}
