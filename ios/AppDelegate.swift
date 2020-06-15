//
//  AppDelegate.swift
//  ios
//
//  Created by Mason Phillips on 6/9/20.
//

import UIKit
import RxSwift
import RxFlow

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let coordinator = FlowCoordinator()
    let bag = DisposeBag()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        coordinator.rx.willNavigate.subscribe(onNext: { f, s in
            print("WILLNAV: \(f) -> \(s)")
        }).disposed(by: bag)
        coordinator.rx.didNavigate.subscribe(onNext: { f, s in
            print("DIDNAV: \(f) -> \(s)")
        }).disposed(by: bag)
        
        let flow = AppFlow()
        
        Flows.use(flow, when: .created) { [window] root in
            window?.rootViewController = root
            window?.makeKeyAndVisible()
        }
        
        coordinator.coordinate(flow: flow, with: flow.stepper)
        
        return true
    }
}
