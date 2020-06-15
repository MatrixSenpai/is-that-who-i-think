//
//  MovieViewController.swift
//  ios
//
//  Created by Mason Phillips on 6/13/20.
//

import UIKit
import RxDataSources
import RxSwift
import Neon
import libtmdb

class MovieViewController: UIViewController {
    let model = MovieModel()

    let table = UITableView(frame: .zero, style: .insetGrouped)
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.details.compactMap { $0?.title }
            .bind(to: navigationItem.rx.title)
            .disposed(by: bag)
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, MovieCreditsModel.Cast>>(configureCell: { dataSource, table, index, item -> UITableViewCell in
            let cell = table.dequeueReusableCell(withIdentifier: MovieCell.identifier, for: index)
            (cell as? MovieCell)?.configure(item)
            return cell
        }, titleForHeaderInSection: { models, index -> String? in
            models.sectionModels[index].model
        })
        
        model.cast
            .filter { !$0.isEmpty }
            .map { [SectionModel<String, MovieCreditsModel.Cast>(model: "", items: $0)] }
            .bind(to: table.rx.items(dataSource: dataSource)).disposed(by: bag)
        table.register(MovieCell.self, forCellReuseIdentifier: MovieCell.identifier)
        table.rx.setDelegate(self).disposed(by: bag)
        view.addSubview(table)
        
        view.backgroundColor = .white
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        table.fillSuperview()
    }
}

extension MovieViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? MovieCell
        if let item = cell?.item {
            model.stepper.steps.accept(AppStep.personDetails(id: item.id))
        }
    }
}
