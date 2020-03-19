//
//  CommentsViewController.swift
//  ToDoList
//
//  Created by Radu Ursache on 22/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit
import RSTextViewMaster
import UnderKeyboard
import SafariServices
import LKAlertController
import ImageViewer_swift

class CommentsViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputContainerView: UIView!
	@IBOutlet weak var imageButton: UIButton!
	@IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var textView: RSTextViewMaster!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    let keyboardObserver = UnderKeyboardObserver()
    
    var onCompletion: (() -> Void)?
    
    var currentTask = TaskModel()
    var showKeyboardAtLoad = false
    var currentEditingComment = CommentModel()
    var editMode = false
    var keyboardVisible = false
	
	private var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addButton.layer.cornerRadius = self.addButton.bounds.height / 2

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.showKeyboardAtLoad {
            self.textView.becomeFirstResponder()
        }
    }
    
    override func setupUI() {
        super.setupUI()
        
        self.title = "COMMENTS_TITLE".localized()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "CLOSE".localized(), style: .done, target: self, action: #selector(self.closeAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "keyboardIcon")!, target: self, action: #selector(self.keyboardButtonAction))
        
        self.addButton.addTarget(self, action: #selector(self.addCommentAction), for: .touchUpInside)
		self.imageButton.addTarget(self, action: #selector(self.addImageButton), for: .touchUpInside)
        
        self.textView.text = ""
        self.textView.delegate = self
        self.textView.placeHolder = "COMMENTS_ADD_COMMENT".localized()
        self.textView.isAnimate = true
        self.textView.maxHeight = self.textView.frame.height * 3
        
        Utils().themeView(view: self.addButton)
        
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 1))
    }
    
    override func setupBindings() {
        super.setupBindings()
        
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
		
		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
		}
    }
    
    @objc func closeAction() {
        self.onCompletion?()
        
        self.textView.resignFirstResponder()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func addCommentAction() {
        if self.editMode {
            self.editMode = false
            
            self.addButton.setTitle("ADD".localized(), for: .normal)
            
            RealmManager.sharedInstance.changeCommentContent(comment: self.currentEditingComment, content: self.textView.text)
        } else {
            let newComment = CommentModel(title: self.textView.text, date: Date())
            newComment.setTask(task: self.currentTask)
            
            RealmManager.sharedInstance.addComment(comment: newComment)
        }
		
		self.keyboardButtonAction()
		
		self.reloadData()
    }
	
	@objc func addImageButton() {
		let actionSheet = ActionSheet(title: "COMMENTS_ADD_IMAGE_TITLE".localized())
		actionSheet.addAction("COMMENTS_SOURCE_CAMERA".localized(), style: .default) { _ in
			self.showImagePicker(gallery: false)
		}
		actionSheet.addAction("COMMENTS_SOURCE_GALLERY".localized(), style: .default) { _ in
			self.showImagePicker()
		}
		actionSheet.addAction("CANCEL".localized(), style: .destructive)
		actionSheet.show()
	}
	
	fileprivate func showImagePicker(gallery: Bool = true) {
		self.imagePicker.delegate = self
		self.imagePicker.sourceType = gallery ? .photoLibrary : .camera
		self.imagePicker.allowsEditing = false
		self.present(self.imagePicker, animated: true, completion: nil)
	}
    
    func startEditMode() {
        self.editMode = true
        
        self.textView.setText(text: self.currentEditingComment.content)
        self.textView.layoutIfNeeded()
        self.textView.becomeFirstResponder()
        
        self.addButton.setTitle("UPDATE".localized(), for: .normal)
    }
    
    func deleteComment(comment: CommentModel) {
        RealmManager.sharedInstance.deleteComment(comment: comment, soft: true)
        
        self.tableView.reloadData()
    }
    
    func openURL(url: URL) {
        let currentOption = UserDefaults.standard.integer(forKey: Config.UserDefaults.openLinks)
        if currentOption == 0 {
            
            if url.absoluteString.hasPrefix("https://") || url.absoluteString.hasPrefix("http://"){
                let myURL = URL(string: url.absoluteString)
                let safariVC = SFSafariViewController(url: myURL!)
                self.present(safariVC, animated: true, completion: nil)
            }else {
                let correctedURL = "http://\(url.absoluteString)"
                let myURL = URL(string: correctedURL)
                let safariVC = SFSafariViewController(url: myURL!)
                self.present(safariVC, animated: true, completion: nil)
            }
            
        } else if currentOption == 1 {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    func openHashtag(hashtag: String) {
//        self.showOK(title: "Hashtag".localized(), message: hashtag)
    }
    
    @objc func keyboardButtonAction() {
        if self.keyboardVisible {
            self.keyboardVisible = false
            self.textView.resignFirstResponder()
            self.bottomConstraint.constant = 0
            
        } else {
            self.textView.becomeFirstResponder()
        }
        
        self.scrollToBottom()
    }
    
    func scrollToBottom() {
        self.tableView.scrollToBottomRow()
    }
	
	func reloadData() {
		self.tableView.reloadData()
        self.scrollToBottom()
        
        self.textView.text = ""
	}
}

extension CommentsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentTask.availableComments().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let currentItem = self.currentTask.availableComments()[indexPath.row]
		
		if currentItem.isImageComment() {
			let cell = tableView.dequeueReusableCell(withIdentifier: CommentImageTableViewCell.getIdentifier(), for: indexPath) as! CommentImageTableViewCell
			
			cell.dateLabel.text = Config.General.dateFormatter().string(from: currentItem.date as Date)
			cell.commentImageView.image = UIImage(data: currentItem.imageData as Data)
			cell.commentImageView.setupImageViewer(from: self)
			
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.getIdentifier(), for: indexPath) as! CommentTableViewCell
			
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
		
		let task = self.currentTask.availableComments()[indexPath.row]
		
		if task.isImageComment() {
			return
		}
        
        self.currentEditingComment = task
        
        self.startEditMode()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "DELETE".localized()) { (_, indexPath) in
            guard indexPath.row < self.currentTask.availableComments().count else { return }
            let comment = self.currentTask.availableComments()[indexPath.row]
            
            self.deleteComment(comment: comment)
        }
        return [deleteAction]
    }
}

extension CommentsViewController: RSTextViewMasterDelegate, UITextViewDelegate {
    func growingTextView(growingTextView: RSTextViewMaster, willChangeHeight height: CGFloat) {
        self.view.layoutIfNeeded()
    }
    
    func growingTextView(growingTextView: RSTextViewMaster, didChangeHeight height: CGFloat) {
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.scrollToBottom()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.keyboardButtonAction()
    }
}

extension CommentsViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		guard let image = info[.originalImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
			return
        }
		
		let newComment = CommentModel(image: image, date: Date())
		newComment.setTask(task: self.currentTask)
		RealmManager.sharedInstance.addComment(comment: newComment)
		self.reloadData()
		
		picker.dismiss(animated: true, completion: nil)
	}
}
