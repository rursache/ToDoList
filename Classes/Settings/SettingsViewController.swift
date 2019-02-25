//
//  SettingsViewController.swift
//  ToDoList
//
//  Created by Radu Ursache on 25/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit
import AcknowList
import MessageUI

class SettingsViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var dataSource = [SettingsItemSection]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setDataSource()
    }
    
    override func setupUI() {
        super.setupUI()
        
        self.addRightDoneButton()
        
        let tableViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 50))
        tableViewFooter.backgroundColor = UIColor.clear
        let version = UILabel(frame: CGRect(x: 8, y: 15, width: self.tableView.frame.width, height: 30))
        version.font = UIFont.systemFont(ofSize: 12)
        version.textColor = UIColor.darkGray
        version.textAlignment = .center
        
        if let fullName = UserDefaults.standard.string(forKey: Config.UserDefaults.userFullName), Utils().userIsLoggedIniCloud() {
            version.text = "Logged in as: \(fullName)"
            tableViewFooter.addSubview(version)
            self.tableView.tableFooterView  = tableViewFooter
        }
    }
    
    func addRightDoneButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done".localized(), style: .done, target: self, action: #selector(self.closeButtonAction))
    }
    
    override func setupBindings() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func setDataSource() {
        let mainSection = SettingsItemSection(items: [
            SettingsItemModel(title: "Start page", icon: "settings_start_page", subtitle: nil, rightTitle: "Overview"),
            SettingsItemModel(title: "Theme", icon: "settings_theme", subtitle: nil, rightTitle: "Red"),
            SettingsItemModel(title: "Language", icon: "settings_language", subtitle: nil, rightTitle: "English"),
            SettingsItemModel(title: "Open Web Links", icon: "settings_openurl", subtitle: nil, rightTitle: "In App")
                                                        ])
        
        let aboutSection = SettingsItemSection(items: [
            SettingsItemModel(title: "Manual iCloud Sync", icon: "settings_sync", subtitle: nil, rightTitle: nil),
            SettingsItemModel(title: "Feedback", icon: "settings_feedback", subtitle: nil, rightTitle: nil),
            SettingsItemModel(title: "Acknowledgments", icon: "settings_acknowledgments", subtitle: nil, rightTitle: nil),
            SettingsItemModel(title: "About", icon: "settings_about", subtitle: nil, rightTitle: nil)
                                                        ])
        
        self.dataSource = [mainSection, aboutSection]
        
        self.tableView.reloadData()
    }
    
    func cellAction(indexPath: IndexPath) {
        // human readable rows and sections
        let row = indexPath.row + 1
        let section = indexPath.section + 1
        
        // section 1
        
        // to do
        
        // section 2
        
        if section == 2 && row == 1 {
            // sync
            Utils().showSuccessToast(message: "Sync started, please wait...".localized())
            self.navigationItem.rightBarButtonItem = nil
            
            Utils().getSyncEngine()?.pull()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                Utils().getSyncEngine()?.pushAll()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                    self.addRightDoneButton()
                    Utils().showSuccessToast(message: "Sync done".localized())
                })
            })
        
        } else if section == 2 && row == 2 {
            // feedback
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(["contact@randusoft.ro"])
                self.present(mail, animated: true)
            } else {
                Utils().showErrorToast(message: "No email account setup on your device".localized())
            }
        
        } else if section == 2 && row == 3 {
            // acknowledgments
            self.navigationController?.pushViewController(AcknowListViewController(), animated: true)
        
        } else if section == 2 && row == 4 {
            // about
            self.showOK(message: "A simple To-do list app written in Swift 4.2\nRadu Ursache - RanduSoft\n\nVersion \(Bundle.main.releaseVersionNumber) (\(Bundle.main.buildVersionNumber))")
        }
    }
    
    @objc func closeButtonAction() {
        self.close()
    }
    
    func close() {
        self.dismiss(animated: true, completion: nil)
    }

}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.getIdentifier(), for: indexPath) as! SettingsTableViewCell
        
        let currentItem = self.dataSource[indexPath.section].items[indexPath.row]
        
        cell.titleLabel.text = currentItem.title
        cell.iconImageView.image = currentItem.icon
        
        if let subtitle = currentItem.subtitle {
            cell.subtitleLabel.isHidden = false
            cell.subtitleLabel.text = subtitle
        } else {
            cell.subtitleLabel.isHidden = true
        }
        
        if let rightTitle = currentItem.rightTitle {
            cell.rightLabel.isHidden = false
            cell.rightLabel.text = rightTitle
        } else {
            cell.rightLabel.isHidden = true
        }
        
        cell.layoutIfNeeded()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.cellAction(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
