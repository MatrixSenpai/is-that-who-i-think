//
//  TVShowModel.swift
//  ios
//
//  Created by Mason Phillips on 6/13/20.
//

import Foundation
import RxCocoa
import RxDataSources
import RxFlow
import RxSwift
import libtmdb

class TVShowModel {
    let details = BehaviorRelay<TVDetailsModel?>(value: nil)
    let cast = BehaviorRelay<[TVCreditsModel.Cast]>(value: [])
    
    var stepper: Stepper!
    var api: API!
    
    let bag = DisposeBag()
    
    func details(for id: Int) {
        api.tvDetails(id).asObservable()
            .bind(to: details)
            .disposed(by: bag)
        
        api.tvCredits(id).asObservable()
            .map { $0.cast }
            .bind(to: cast)
            .disposed(by: bag)
    }
}

extension TVShowModel {
    var dataModel: Driver<[ShowSectionModel]> {
        let seasons = details.compactMap { $0?.seasons }
        
        return Observable.combineLatest(seasons, cast).map { args in
            let cast = args.1.map { TVShowSectionModelItem.cast($0) }
            let seasons = args.0.sorted { $0.season_number < $1.season_number }
                .map { TVShowSectionModelItem.season($0) }
            
            return [
                ShowSectionModel(title: "Main Cast", items: cast),
                ShowSectionModel(title: "Seasons", items: seasons)
            ]
        }.asDriver(onErrorJustReturn: [])
    }
}

enum TVShowSectionModelItem {
    case season(_ item: TVDetailsModel.Season)
    case cast(_ item: TVCreditsModel.Cast)
}
struct ShowSectionModel: SectionModelType {
    typealias Item = TVShowSectionModelItem
    
    var title: String
    var items: [Self.Item]
    
    init(original: ShowSectionModel, items: [Self.Item]) {
        self = original
        self.items = items
    }
    
    init(title: String, items: [Self.Item]) {
        self.title = title
        self.items = items
    }
}
