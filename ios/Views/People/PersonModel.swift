//
//  PersonModel.swift
//  ios
//
//  Created by Mason Phillips on 6/14/20.
//

import Foundation
import RxFlow
import RxCocoa
import RxSwift
import libtmdb

class PersonModel {
    let result = BehaviorRelay<PeopleDetailsModel?>(value: nil)
    let credits = BehaviorRelay<[PeopleCombinedCreditsModel.Cast]>(value: [])
    
    var stepper: Stepper!
    var api: API!
    
    let bag = DisposeBag()
    
    func details(_ id: Int) {
        api.peopleDetails(id).asObservable()
            .bind(to: result)
            .disposed(by: bag)
        
        api.peopleCombinedCredits(id).asObservable()
            .map { $0.cast }
            .bind(to: credits)
            .disposed(by: bag)
    }
}
