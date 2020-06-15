//
//  PersonViewController.swift
//  ios
//
//  Created by Mason Phillips on 6/14/20.
//

import UIKit
import RxCocoa
import RxSwift
import libtmdb

class PersonViewController: UIViewController {
    let model = PersonModel()
    let bag = DisposeBag()
    
    let table = UITableView(frame: .zero, style: .insetGrouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.result.compactMap { $0?.name }
            .bind(to: navigationItem.rx.title)
            .disposed(by: bag)
        
        table.register(PersonCell.self, forCellReuseIdentifier: PersonCell.identifier)
        table.rx.setDelegate(self).disposed(by: bag)
        model.credits.bind(to: table.rx.items(cellIdentifier: PersonCell.identifier, cellType: PersonCell.self)) { index, item, cell in
            cell.configure(item)
        }.disposed(by: bag)
        view.addSubview(table)
        
        view.backgroundColor = .white
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        table.fillSuperview()
    }
}

extension PersonViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? PersonCell
        
        if let item = cell?.item {
            let step: AppStep
            switch item.media_type {
            case "movie": step = .movieDetails(id: item.id)
            case "tv": step = .showDetails(id: item.id)
            default:
                print(item.media_type ?? "EMPITEM")
                warnUnknown()
                return
            }
            
            model.stepper.steps.accept(step)
        } else {
            print(cell?.item ?? "EMPITEM")
            warnUnknown()
        }
    }
    
    func warnUnknown() {
        let alert = UIAlertController(title: "Unknown Item", message: "A selected item has unknown type or is empty", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
}

class PersonCell: UITableViewCell {
    static let identifier: String = "titleCell"
    var item: PeopleCombinedCreditsModel.Cast?
    
    let characterLabel = UILabel()
    let movieLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        characterLabel.font = .systemFont(ofSize: 21)
        contentView.addSubview(characterLabel)
            
        movieLabel.font = .italicSystemFont(ofSize: 17)
        contentView.addSubview(movieLabel)
    }
    
    func configure(_ item: PeopleCombinedCreditsModel.Cast) {
        self.item = item
        
        characterLabel.text = item.character
        let mt = item.title ?? item.original_title
        let tt = item.name ?? item.original_name
        movieLabel.text = mt ?? tt ?? "Unknown Item (\(item.id))"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        characterLabel.anchorAndFillEdge(.top, xPad: 20, yPad: 5, otherSize: 25)
        movieLabel.anchorAndFillEdge(.bottom, xPad: 20, yPad: 8, otherSize: 20)
    }
        
    required init?(coder: NSCoder) {
        fatalError()
    }
}
