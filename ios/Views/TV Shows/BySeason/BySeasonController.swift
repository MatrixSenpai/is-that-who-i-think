//
//  BySeasonController.swift
//  ios
//
//  Created by Mason Phillips on 6/14/20.
//

import UIKit
import RxSwift
import libtmdb

class BySeasonController: UIViewController {
    let table = UITableView(frame: .zero, style: .insetGrouped)
    
    let model = BySeasonModel()
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.season.compactMap { $0?.name }
            .bind(to: navigationItem.rx.title)
            .disposed(by: bag)
        
        model.episodes.drive(table.rx.items(cellIdentifier: EpisodeTableCell.identifier, cellType: EpisodeTableCell.self)) { index, item, cell in
            let title = "S\(item.season_number)E\(item.episode_number): \(item.name)"
            cell.textLabel?.text = title
        }.disposed(by: bag)
        table.register(EpisodeTableCell.self, forCellReuseIdentifier: EpisodeTableCell.identifier)
        table.rx.setDelegate(self).disposed(by: bag)
        view.addSubview(table)
        
        view.backgroundColor = .white
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        table.fillSuperview()
    }
}

extension BySeasonController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let season = model.season.value!
        let episode = season.episodes[indexPath.row]
        model.stepper.steps.accept(AppStep.episodeDetails(tv: model.showId, season: season.season_number, episode: episode.episode_number))
    }
}

class EpisodeTableCell: UITableViewCell {
    static let identifier = "episodeCell"
    var item: TVSeasonsDetailsModel.Episode?
    
    func configure(_ item: TVSeasonsDetailsModel.Episode) {
        self.item = item
        let title = "S\(item.season_number)E\(item.episode_number): \(item.name)"
        textLabel?.text = title
    }
}
