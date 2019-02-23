//
//  CommentsViewController.swift
//  ToDoList
//
//  Created by Radu Ursache on 22/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit
import RealmSwift
import RSTextViewMaster
import UnderKeyboard
import SafariServices

class CommentsViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var textView: RSTextViewMaster!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    let keyboardObserver = UnderKeyboardObserver()
    var commentsDataSource = List<CommentModel>()
    
    var onCompletion: ((List<CommentModel>) -> Void)?
    
    var currentTask = TaskModel()
    var showKeyboardAtLoad = false
    var isNewTask = false
    var keyboardVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.showKeyboardAtLoad {
            self.textView.becomeFirstResponder()
        }
    }
    
    override func setupUI() {
        super.setupUI()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close".localized(), style: .done, target: self, action: #selector(self.closeAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "keyboardIcon")!, target: self, action: #selector(self.keyboardButtonAction))
        
        self.addButton.addTarget(self, action: #selector(self.addCommentAction), for: .touchUpInside)
        
        self.textView.text = ""
        self.textView.delegate = self
        self.textView.placeHolder = "Add a comment".localized()
        self.textView.isAnimate = true
        self.textView.maxHeight = self.textView.frame.height * 3
        
        Utils().themeView(view: self.addButton)
        
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 1))
    }
    
    override func setupBindings() {
        super.setupBindings()
        
        self.commentsDataSource = self.currentTask.comments
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.keyboardObserver.start()
        self.keyboardObserver.willAnimateKeyboard = { height in
            self.keyboardVisible = true
            self.bottomConstraint.constant = height - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
        }
        self.keyboardObserver.animateKeyboard = { height in
            self.inputContainerView.layoutIfNeeded()
        }
    }
    
    @objc func closeAction() {
        self.onCompletion?(self.commentsDataSource)
        
        self.textView.resignFirstResponder()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func addCommentAction() {
        let newComment = CommentModel(title: self.textView.text, date: Date())
        
        if self.isNewTask {
            self.commentsDataSource.append(newComment)
        } else {
            RealmManager.sharedInstance.updateComments(object: self.currentTask, commentsToAdd: [newComment])
        }
        
        Utils().getSyncEngine()?.pushAll()
        
        self.tableView.reloadData()
        
        self.textView.text = ""
    }
    
    func openURL(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true, completion: nil)
    }
    
    func openHashtag(hashtag: String) {
        self.showOK(title: "Hashtag", message: hashtag)
    }
    
    @objc func keyboardButtonAction() {
        if self.keyboardVisible {
            self.keyboardVisible = false
            self.textView.resignFirstResponder()
            self.bottomConstraint.constant = 0
        } else {
            self.textView.becomeFirstResponder()
        }
    }
}

extension CommentsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentsDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.getIdentifier(), for: indexPath) as! CommentTableViewCell
        
        let currentItem = self.commentsDataSource[indexPath.row]
        
        cell.dateLabel.text = Config.General.dateFormatter().string(from: currentItem.date as Date)
        cell.contentLabel.text = currentItem.content
        
        cell.contentLabel.handleURLTap { (url) in
            self.openURL(url: url)
        }
        
        cell.contentLabel.handleHashtagTap { (hashtag) in
            self.openHashtag(hashtag: hashtag)
        }
        
        return cell
    }
    
    
}

extension CommentsViewController: RSTextViewMasterDelegate, UITextViewDelegate {
    func growingTextView(growingTextView: RSTextViewMaster, willChangeHeight height: CGFloat) {
        self.view.layoutIfNeeded()
    }
    
    func growingTextView(growingTextView: RSTextViewMaster, didChangeHeight height: CGFloat) {
        
    }
}
