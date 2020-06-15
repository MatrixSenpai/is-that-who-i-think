//
//  SearchViewController.swift
//  ios
//
//  Created by Mason Phillips on 6/9/20.
//

import UIKit
import RxCocoa
import RxDataSources
import RxSwift
import Neon
import libtmdb

class SearchViewController: UIViewController {
    
    let search = UISearchController()
    let table  = UITableView(frame: .zero, style: .insetGrouped)
    
    let model = SearchModel()
    
    let bag = DisposeBag()
    
    var isSearchEmpty: Bool {
        return search.searchBar.text?.isEmpty ?? true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        search.searchBar.placeholder = "Search movies, shows, people..."
        search.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = search
        definesPresentationContext = true
        search.searchBar.rx.text.orEmpty
            .asObservable()
            .bind(to: model.textInput)
            .disposed(by: bag)
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, SearchMultiModel>>(configureCell: { (model, table, index, item) -> UITableViewCell in
            let cell = table.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier, for: index) as! SearchTableViewCell
            cell.configure(item: item)
            return cell
        }, titleForHeaderInSection: { models, index -> String? in
            models.sectionModels[index].model
        })
        
        table.rx.setDelegate(model).disposed(by: bag)
        model.results
            .bind(to: table.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        table.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.identifier)
        view.addSubview(table)
        
        view.backgroundColor = .systemBackground
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        table.fillSuperview()
    }
}

class SearchTableViewCell: UITableViewCell {
    static let identifier: String = "searchItemCell"
    var item: SearchMultiModel!
    
    func configure(item: SearchMultiModel) {
        self.item = item
        
        switch item {
        case .movie(let i): textLabel?.text = i.title
        case .show(let i): textLabel?.text = i.name
        case .person(let i): textLabel?.text = i.name
        }
    }
}
