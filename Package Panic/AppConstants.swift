import Foundation

enum AppConstants {
    static let appsFlyerDevKey = "B8g54jbZRfCk6vV2h4yruG"
    static let appsFlyerAppleAppID = "6769775764"
    
    static let appName = "PackagePanic: Dispatch"
    static var bundleID: String {
        Bundle.main.bundleIdentifier ?? "com.PackagePanicDispatch"
    }
    static var storeID: String {
        "id\(appsFlyerAppleAppID)"
    }
    
    static let configEndpoint = "https://packagepanicdispatch.com/config.php"
    static let privacyPolicyAddress = "https://packagepanicdispatch.com/privacy-policy.html"
    
    static let osName = "IOS"
    static let pushTokenPlaceholder = "00000000000000000000"
    static let firebaseProjectID = "166858017601"
    
    static let gcdRetryDelay: TimeInterval = 1.0
    static let mergeWaitInterval: TimeInterval = 3.0
    static let launchLoaderDuration: TimeInterval = 20.0
    
    static let contentViewApplicationName = "Mobile/15E148 appid/\(appsFlyerAppleAppID) appname/\(appName)"
    
    static let pushPermissionRetryDelay: TimeInterval = 60 * 60 * 24 * 3
    
    static let pushDataAddressKey = "url"
    static let firstLaunchInternetCheckCompletedKey = "first_launch_internet_check_completed"
    static let firstLaunchNoInternetAlertShownKey = "first_launch_no_internet_alert_shown"
}
