//
//  EpisodeDetailModel.swift
//  ios
//
//  Created by Mason Phillips on 6/14/20.
//

import Foundation
import RxFlow
import RxDataSources
import RxCocoa
import RxSwift
import libtmdb

class EpisodeDetailModel {
    let details = BehaviorRelay<TVEpisodesDetailsModel?>(value: nil)
    let cast = BehaviorRelay<[TVEpisodesCreditsModel.Cast]>(value: [])
    let guest = BehaviorRelay<[TVEpisodesCreditsModel.GuestStar]>(value: [])
    
    var stepper: Stepper!
    var api: API!
    
    let bag = DisposeBag()
    
    func details(_ id: Int, season: Int, episode: Int) {
        api.tvEpisodeDetails(id, season: season, episode: episode).asObservable()
            .bind(to: details)
            .disposed(by: bag)
        
        let cs = api.tvEpisodeCredits(id, season: season, episode: episode).asObservable()
        cs.map { $0.cast }.bind(to: cast).disposed(by: bag)
        cs.map { $0.guest_stars }.bind(to: guest).disposed(by: bag)
    }
    
    var dataModel: Driver<[EpisodeDetailSection]> {
        return Observable.combineLatest(cast, guest).map { args in
            let c = args.0.map { EpisodeDetailSection.Types.cast($0) }
            let g = args.1.map { EpisodeDetailSection.Types.guest($0) }
            
            return [
                EpisodeDetailSection(title: "Main Cast", items: c),
                EpisodeDetailSection(title: "Guest Stars", items: g)
            ]
        }.asDriver(onErrorJustReturn: [])
    }
}

struct EpisodeDetailSection: SectionModelType {
    typealias Item = Types
    
    enum Types {
        case cast(_ item: TVEpisodesCreditsModel.Cast)
        case guest(_ item: TVEpisodesCreditsModel.GuestStar)
    }
    
    var title: String
    var items: [Self.Item]
    
    init(original: EpisodeDetailSection, items: [Self.Item]) {
        self = original
        self.items = items
    }
    
    init(title: String, items: [Self.Item]) {
        self.title = title
        self.items = items
    }
}
