//
//  BySeasonModel.swift
//  ios
//
//  Created by Mason Phillips on 6/14/20.
//

import Foundation
import RxCocoa
import RxSwift
import RxFlow
import libtmdb

class BySeasonModel {
    let season = BehaviorRelay<TVSeasonsDetailsModel?>(value: nil)
    var episodes: Driver<[TVSeasonsDetailsModel.Episode]> {
        season.compactMap { $0?.episodes }.asDriver(onErrorJustReturn: [])
    }
    
    var stepper: Stepper!
    var api: API!
    
    var showId: Int!
    
    let bag = DisposeBag()
    
    func details(_ id: Int, season: Int) {
        showId = id
        api.tvSeasonDetails(id, season: season).asObservable()
            .bind(to: self.season)
            .disposed(by: bag)
    }
}
