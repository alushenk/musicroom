import UIKit
import NotificationBannerSwift

extension UIViewController {

    class func makeFromStoryboard(nameStoryboard: String) -> UIViewController {
        let identifier = String(describing: self)

        return UIStoryboard(name: nameStoryboard, bundle: Bundle.main).instantiateViewController(withIdentifier:identifier)
    }

    static func present(title: String, error: Error) {
        present(title: title, message: error.type.description, style: .danger)
    }

    static func present(title: String, message: String? = nil, style: BannerStyle = BannerStyle.success) {
        var banner: BaseNotificationBanner
        if style == .success, message == nil {
            banner = StatusBarNotificationBanner(title: title, style: .success)
        } else {
            if let message = message,
                message.count > 40 {
                banner = GrowingNotificationBanner(title: title, subtitle: message, style: style)
            } else {
                banner = NotificationBanner(title: title, subtitle: message, style: style)
            }
        }
        if style == .success {
            banner.haptic = .light
        } else {
            banner.haptic = .heavy
        }
        banner.show()
    }

    func askForConfirmation(actionTitle: String, onConfirm: (() -> Void)?, onCancel: (() -> Void)?) {
        let alertController = UIAlertController(title: actionTitle, message: nil, preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: { _ in
            onConfirm?()
        })
        alertController.addAction(confirmAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            onCancel?()
        })
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }
}
