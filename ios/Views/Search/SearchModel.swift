//
//  SearchModel.swift
//  ios
//
//  Created by Mason Phillips on 6/9/20.
//

import Foundation
import RxCocoa
import RxSwift
import RxFlow
import RxDataSources
import libtmdb

class SearchModel: NSObject {
    let results    = BehaviorRelay<[SectionModel<String, SearchMultiModel>]>(value: [])
    let textInput  = BehaviorRelay<String>(value: "")
    
    var stepper: Stepper!
    var api: API!
    
    let bag = DisposeBag()
    
    enum ResultType: Int, CustomStringConvertible {
        case movie, show, person
        
        var description: String {
            switch self {
            case .movie: return "Movies"
            case .show: return "TV Shows"
            case .person: return "People"
            }
        }
    }
    
    override init() {
        super.init()
        
        textInput.debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .subscribe(onNext: query)
            .disposed(by: bag)
    }

    func query(_ queryString: String) {
        api.searchMulti(queryString).asObservable().map { data in
            Dictionary<ResultType, [SearchMultiModel]>(grouping: data.results) { (element) -> ResultType in
                switch element {
                case .movie(_): return .movie
                case .show(_): return .show
                case .person(_): return .person
                }
            }
            .map { k, v in SectionModel<String, SearchMultiModel>(model: k.description, items: v) }
            .sorted { $0.model < $1.model }
        }.bind(to: results).disposed(by: bag)
    }
}

extension SearchModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = (tableView.cellForRow(at: indexPath) as? SearchTableViewCell)?.item, let stepper = stepper {
            switch item {
            case .movie(let item) : stepper.steps.accept(AppStep.movieDetails(id: item.id))
            case .show(let item)  : stepper.steps.accept(AppStep.showDetails(id: item.id))
            case .person(let item): stepper.steps.accept(AppStep.personDetails(id: item.id))
                
//            default: return
            }
        }
    }
}
