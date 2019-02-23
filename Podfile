platform :ios, '11.0'

inhibit_all_warnings!

target 'ToDoList' do
  use_frameworks!

  # pod 'PKHUD'
  pod 'LKAlertController'
  pod 'ActionSheetPicker-3.0'
  # pod 'SwiftTheme' # v1.1 feature
  # pod 'BulletinBoard' # v1.1 feature (onboarding tutorial)
  # pod 'Alamofire'
  pod 'Firebase/Core'
  pod 'IceCream', :git => 'https://github.com/iPhoNewsRO/IceCream.git'
  pod 'UnderKeyboard'
  pod 'ActiveLabel'
  pod 'Realm'
  pod 'RealmSwift'
  # pod 'Reveal-SDK', '20', :configurations => ['Debug']
  pod 'RSTextViewMaster'
  pod 'CFNotify'


post_install do |installer|
  installer.pods_project.targets.each do |target|
      if ['CFNotify'].include? target.name
          target.build_configurations.each do |config|
              config.build_settings['SWIFT_VERSION'] = '4.0'
          end
      end
  end
end

end
