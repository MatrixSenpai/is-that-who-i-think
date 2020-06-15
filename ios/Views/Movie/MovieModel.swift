//
//  MovieModel.swift
//  ios
//
//  Created by Mason Phillips on 6/13/20.
//

import Foundation
import RxCocoa
import RxFlow
import RxSwift
import libtmdb

class MovieModel {
    let details = BehaviorRelay<MovieDetailsModel?>(value: nil)
    let cast = BehaviorRelay<[MovieCreditsModel.Cast]>(value: [])
    
    var stepper: Stepper!
    var api: API!
    
    let bag = DisposeBag()
    
    func details(for id: Int) {
        api.movieDetails(id).asObservable()
            .bind(to: details)
            .disposed(by: bag)
        
        api.movieCredits(id).asObservable()
            .map { $0.cast }
            .bind(to: cast)
            .disposed(by: bag)
    }
}
