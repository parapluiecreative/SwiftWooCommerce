//
//  ATCMentionsTypeaheadViewController.swift
//  ChatApp
//
//  Created by Mac  on 11/03/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import UIKit

protocol ATCMentionsTypeaheadProtocol {
    func didSelectMentionsUser(member: ATCUser)
}

class ATCMentionsTypeaheadViewController: UIViewController {

    @IBOutlet weak var mentionsUserTableView: ContentSizedTableView!
    
    var delegate: ATCMentionsTypeaheadProtocol?
    private let groupMembersCellClass = ATCMentionsUserTableViewCell.self
    var uiConfig: ATCChatUIConfigurationProtocol
    var sortedRecipients : [ATCUser] = [] {
        didSet {
            if let mentionsUserTableView = mentionsUserTableView {
                mentionsUserTableView.reloadData()
            }
        }
    }

    init(uiConfig: ATCChatUIConfigurationProtocol) {
        self.uiConfig = uiConfig
        super.init(nibName: "ATCMentionsTypeaheadViewController", bundle: nil)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cellNib = UINib(nibName: String(describing: groupMembersCellClass), bundle: nil)
        mentionsUserTableView.register(cellNib,
                                           forCellReuseIdentifier: String(describing: groupMembersCellClass))

        mentionsUserTableView.delegate = self
        mentionsUserTableView.dataSource = self
        mentionsUserTableView.separatorStyle = .none
    }

}

extension ATCMentionsTypeaheadViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedRecipients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: groupMembersCellClass)) as? ATCMentionsUserTableViewCell else {
            return tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        }
        cell.setUserData(sortedRecipients[indexPath.row], uiConfig: self.uiConfig)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let member = sortedRecipients[indexPath.row]
        delegate?.didSelectMentionsUser(member: member)
    }
}
