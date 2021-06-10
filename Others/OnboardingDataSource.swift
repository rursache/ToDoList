//
//  OnboardingDataSource.swift
//  ToDoList
//
//  Created by Radu Ursache on 16/01/2020.
//  Copyright © 2020 Radu Ursache. All rights reserved.
//

import UIKit
import BLTNBoard

class FeedbackPageBLTNItem: BLTNPageItem {
    private let feedbackGenerator = SelectionFeedbackGenerator()

    override func actionButtonTapped(sender: UIButton) {
		feedbackGenerator.prepare()
        feedbackGenerator.selectionChanged()

        super.actionButtonTapped(sender: sender)
    }

    override func alternativeButtonTapped(sender: UIButton) {
		feedbackGenerator.prepare()
        feedbackGenerator.selectionChanged()

        super.alternativeButtonTapped(sender: sender)
    }
}

class SelectionFeedbackGenerator {
    private let anyObject: AnyObject?

    init() {
        if #available(iOS 10, *) {
            anyObject = UISelectionFeedbackGenerator()
        } else {
            anyObject = nil
        }
    }

    func prepare() {
        if #available(iOS 10, *) {
            (anyObject as! UISelectionFeedbackGenerator).prepare()
        }
    }

    func selectionChanged() {
        if #available(iOS 10, *) {
            (anyObject as! UISelectionFeedbackGenerator).selectionChanged()
        }
    }
}

enum OnboardingDataSource {
	static func getAppearance() -> BLTNItemAppearance {
        let appearance = BLTNItemAppearance()
        appearance.titleFontDescriptor = UIFontDescriptor(name: "AvenirNext-Medium", matrix: .identity)
		appearance.descriptionFontDescriptor = UIFontDescriptor(name: "AvenirNext-Regular", matrix: .identity)
		appearance.buttonFontDescriptor = UIFontDescriptor(name: "AvenirNext-DemiBold", matrix: .identity)
		return appearance
    }
	
    static func makeIntroPage() -> FeedbackPageBLTNItem {
		let page = FeedbackPageBLTNItem(title: "ONBOARDING_WELCOME".localized() + Config.General.appName)
        page.image = UIImage(named: "roundedIcon")
	
		page.appearance = self.getAppearance()

        page.descriptionText = "ONBOARDING_START".localized()
        page.actionButtonTitle = "ONBOARDING_CONTINUE".localized()

        page.isDismissable = false

        page.presentationHandler = { item in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                item.manager?.hideActivityIndicator()
            }
        }

        page.actionHandler = { item in
            item.manager?.displayNextItem()
        }

        page.next = makeNotitificationsPage()

        return page
    }

    static func makeNotitificationsPage() -> FeedbackPageBLTNItem {
        let page = FeedbackPageBLTNItem(title: "ONBOARDING_PUSH_NOTIFICATIONS".localized())
        page.image = UIImage(named: "NotificationPrompt")
		
		page.appearance = self.getAppearance()

        page.descriptionText = "ONBOARDING_RECEIVE_PUSH_NOTIFICATIONS".localized()
        page.actionButtonTitle = "ONBOARDING_ACTIVATE".localized()
        page.alternativeButtonTitle = "ONBOARDING_NOT_NOW".localized()

        page.isDismissable = false

        page.actionHandler = { item in
			(UIApplication.shared.delegate as! AppDelegate).requestPushNotificationsPerms {
				item.manager?.displayNextItem()
			}
        }

        page.alternativeHandler = { item in
            item.manager?.displayNextItem()
        }

        page.next = makeCompletionPage()

        return page
    }

    static func makeCompletionPage() -> BLTNPageItem {
        let page = BLTNPageItem(title: "ONBOARDING_DONE".localized())
        page.image = UIImage(named: "IntroCompletion")
		
		page.appearance = self.getAppearance()

        let tintColor: UIColor
        if #available(iOS 13.0, *) {
            tintColor = .systemGreen
        } else {
            tintColor = #colorLiteral(red: 0.2980392157, green: 0.8509803922, blue: 0.3921568627, alpha: 1)
        }
        page.appearance.actionButtonColor = tintColor
        page.appearance.imageViewTintColor = tintColor

        page.appearance.actionButtonTitleColor = .white

        page.descriptionText = "ONBOARDING_DONE_DETAIL".localized()
        page.actionButtonTitle = "ONBOARDING_DONE_ACTION".localized()

        page.isDismissable = true

        page.dismissalHandler = { item in
			UserDefaults.standard.set(true, forKey: Config.UserDefaults.launchedBefore)
        }

        page.actionHandler = { item in
            item.manager?.dismissBulletin(animated: true)
        }

        return page
    }
}

