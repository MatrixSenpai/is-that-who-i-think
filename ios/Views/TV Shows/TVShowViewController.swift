//
//  TVShowViewController.swift
//  ios
//
//  Created by Mason Phillips on 6/13/20.
//

import UIKit
import RxDataSources
import RxSwift

class TVShowViewController: UIViewController {
    let model = TVShowModel()

    let table = UITableView(frame: .zero, style: .insetGrouped)
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.details.compactMap { $0?.name }
            .bind(to: navigationItem.rx.title)
            .disposed(by: bag)
        
        let dataSource = RxTableViewSectionedReloadDataSource<ShowSectionModel>(configureCell: { dataSource, table, index, item -> UITableViewCell in
            let cell: UITableViewCell
            
            switch item {
            case .cast(let i):
                cell = table.dequeueReusableCell(withIdentifier: CastCell.identifier, for: index)
                (cell as? CastCell)?.configure(i)
            case .season(let i):
                cell = table.dequeueReusableCell(withIdentifier: "seasonCell", for: index)
                cell.textLabel?.text = i.name
            }
            
            cell.accessoryType = .disclosureIndicator
            return cell
        }, titleForHeaderInSection: { models, index -> String? in
            models.sectionModels[index].title
        })
        
        model.dataModel.drive(table.rx.items(dataSource: dataSource)).disposed(by: bag)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "seasonCell")
        table.register(CastCell.self, forCellReuseIdentifier: CastCell.identifier)
        table.rx.setDelegate(self).disposed(by: bag)
        view.addSubview(table)
        
        view.backgroundColor = .white
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        table.fillSuperview()
    }    
}

extension TVShowViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if let cell = cell as? CastCell {
            let item = cell.item!
            model.stepper.steps.accept(AppStep.personDetails(id: item.id))
        } else if let data = model.details.value {
            let id = data.id
            let season = data.seasons[indexPath.row]
            model.stepper.steps.accept(AppStep.episodes(tv: id, season: season.season_number))
        }
    }
}
