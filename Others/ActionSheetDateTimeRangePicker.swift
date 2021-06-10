//
//  ActionSheetDateTimeRangePicker.swift
//
//  Created by Radu Ursache on 04/03/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit
import CoreActionSheetPicker

class ActionSheetDateTimeRangePicker: AbstractActionSheetPicker {

    typealias SelectHandler = (_ selectedRange: DateRange) -> ()
    typealias CancelHandler = () -> ()

    typealias DateRange = (start: Date, end: Date)

    fileprivate var minimumDate: Date
    fileprivate var maximumDate: Date
    fileprivate var selectedRange: DateRange?

    var didSelectHandler: SelectHandler?
    var didCancelHandler: CancelHandler?
    var minutesInterval: Int
    var minimumMultipleOfMinutesIntervalForRangeDuration: Int = 3
    var minimumRangeDurationInMinutes: Int {
        return minutesInterval * minimumMultipleOfMinutesIntervalForRangeDuration
    }

    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM YY"
        return dateFormatter
    }()
    
    var startDateComponentStartDate: Date!
    var endDateComponentStartDate: Date!

    init(
        title: String,
        minimumDate: Date,
        maximumDate: Date,
        selectedRange: DateRange?,
        didSelectHandler: SelectHandler?,
        didCancelHandler: CancelHandler?,
        origin: UIView,
        minutesInterval: Int = 5,
        minimumMultipleOfMinutesIntervalForRangeDuration: Int = 3
        ) {
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self.selectedRange = selectedRange
        self.didSelectHandler = didSelectHandler
        self.didCancelHandler = didCancelHandler
        self.minutesInterval = minutesInterval
        self.minimumMultipleOfMinutesIntervalForRangeDuration = minimumMultipleOfMinutesIntervalForRangeDuration
        super.init()
        self.title = title
        refreshStartDates()
    }

    static func showPicker(
        title: String,
        minimumDate: Date,
        maximumDate: Date,
        selectedRange: DateRange?,
        didSelectHandler: SelectHandler?,
        didCancelHandler: CancelHandler?,
        origin: UIView,
        minutesInterval: Int = 5
        ) -> ActionSheetDateTimeRangePicker {

        let picker = ActionSheetDateTimeRangePicker(
            title: title,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            selectedRange: selectedRange,
            didSelectHandler: didSelectHandler,
            didCancelHandler: didCancelHandler,
            origin: origin,
            minutesInterval: minutesInterval
        )

        picker.show()

        return picker
    }

    fileprivate func refreshStartDates() {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([
            .year,
            .month,
            .day,
            .minute,
            .hour,
            .second,
            .timeZone
            ], from: self.minimumDate)

        dateComponents.minute = Int(ceil( Double(dateComponents.minute ?? 0) / Double(minutesInterval) ) * Double(minutesInterval))
        dateComponents.second = 0

        startDateComponentStartDate = calendar.date(from: dateComponents)!
        endDateComponentStartDate = Date(
            timeInterval: TimeInterval(minimumRangeDurationInMinutes * 60),
            since: startDateComponentStartDate
        )
    }

    override func configuredPickerView() -> UIView! {
        let frame = CGRect(x: 0, y: 40, width: self.viewSize.width, height: 216);
        let pickerView = UIPickerView(frame: frame)

        pickerView.delegate = self
        pickerView.dataSource = self

        self.pickerView = pickerView

        if let selectedRange = selectedRange {
            pickerView.selectRow(
                row(date: selectedRange.start, component: 0),
                inComponent: 0,
                animated: false
            )
            pickerView.selectRow(
                row(date: selectedRange.end, component: 1),
                inComponent: 1,
                animated: false
            )
        }

        return pickerView
    }

    override func notifyTarget(_ target: Any!, didSucceedWithAction successAction: Selector!, origin: Any!) {
        guard let pickerView = self.pickerView as? UIPickerView else {
            return
        }
        let selectedRange = (
            start: date(component: 0, row: pickerView.selectedRow(inComponent: 0)),
            end: date(component: 1, row: pickerView.selectedRow(inComponent: 1))
        )

        self.selectedRange = selectedRange
        didSelectHandler?(selectedRange)
    }

    override func notifyTarget(_ target: Any!, didCancelWithAction cancelAction: Selector!, origin: Any!) {
        didCancelHandler?()
    }

    func startDate(component: Int) -> Date {
        let startDate: Date
        if component == 0 {
            startDate = startDateComponentStartDate
        } else {
            startDate = endDateComponentStartDate
        }

        return startDate
    }

    func date(component: Int, row: Int) -> Date {
        return Date(
            timeInterval: TimeInterval(row * minutesInterval * 60),
            since: startDate(component: component)
        )
    }
    
    func row(date: Date, component: Int) -> Int {
        let minutesSinceStartDate = max(date.timeIntervalSince(startDate(component: component)) / 60, 0)
        return Int(minutesSinceStartDate) / minutesInterval
    }
}

extension ActionSheetDateTimeRangePicker: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numberOfDatesForComponent(component)
    }

    func numberOfDatesForComponent(_ component: Int) -> Int {
        let minutesBetweenDates = ceil(
            maximumDate.timeIntervalSince(startDateComponentStartDate) / 60.0
            - Double(minimumRangeDurationInMinutes)
        )
        return Int(minutesBetweenDates / Double(minutesInterval))
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dateFormatter.string(
            from: date(component: component, row: row)
        )
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.selectedRow(inComponent: 0) > pickerView.selectedRow(inComponent: 1) {
            pickerView.selectRow(pickerView.selectedRow(inComponent: 0), inComponent: 1, animated: true)
        }
    }

}
