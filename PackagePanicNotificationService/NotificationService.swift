import UserNotifications

final class NotificationService: UNNotificationServiceExtension {
    private var contentHandler: ((UNNotificationContent) -> Void)?
    private var bestAttemptContent: UNMutableNotificationContent?
    private var downloadTask: URLSessionDataTask?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        let userInfo = request.content.userInfo
        logPayload(userInfo)
        
        guard let bestAttemptContent else {
            contentHandler(request.content)
            return
        }
        
        applyAutoBadge(to: bestAttemptContent) { [weak self] in
            guard let self else { return }
            
            guard let imageAddress = self.imageAddress(from: userInfo) else {
                NSLog("[PushExt] No image address found in payload. Returning content with badge = %@", String(describing: bestAttemptContent.badge))
                contentHandler(bestAttemptContent)
                return
            }
            
            NSLog("[PushExt] Downloading image from %@", imageAddress.absoluteString)
            self.downloadAttachment(from: imageAddress) { [weak self] attachment in
                guard let self else { return }
                if let attachment {
                    bestAttemptContent.attachments = [attachment]
                    NSLog("[PushExt] Attachment added.")
                } else {
                    NSLog("[PushExt] Attachment download failed.")
                }
                contentHandler(bestAttemptContent)
                self.contentHandler = nil
            }
        }
    }
    
    private func applyAutoBadge(to content: UNMutableNotificationContent, completion: @escaping () -> Void) {
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            let nextBadge = notifications.count + 1
            content.badge = NSNumber(value: nextBadge)
            NSLog("[PushExt] Badge auto-set to %d", nextBadge)
            completion()
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        NSLog("[PushExt] serviceExtensionTimeWillExpire called.")
        downloadTask?.cancel()
        if let contentHandler, let bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
        contentHandler = nil
    }
    
    private func logPayload(_ userInfo: [AnyHashable: Any]) {
        var safe: [String: Any] = [:]
        for (key, value) in userInfo {
            guard let stringKey = key as? String else { continue }
            safe[stringKey] = jsonSafeValue(value)
        }
        let hasMutableContent = (userInfo["aps"] as? [AnyHashable: Any])?["mutable-content"] != nil
        NSLog("[PushExt] ==========================================")
        NSLog("[PushExt] didReceive called.")
        NSLog("[PushExt] mutable-content present: %@", hasMutableContent ? "true" : "false")
        if JSONSerialization.isValidJSONObject(safe),
           let data = try? JSONSerialization.data(withJSONObject: safe, options: [.prettyPrinted, .sortedKeys]),
           let json = String(data: data, encoding: .utf8) {
            NSLog("[PushExt] Push payload: %@", json)
        } else {
            NSLog("[PushExt] Push payload (raw): %@", String(describing: userInfo))
        }
        NSLog("[PushExt] ==========================================")
    }
    
    private func jsonSafeValue(_ value: Any) -> Any {
        if let dict = value as? [AnyHashable: Any] {
            var result: [String: Any] = [:]
            for (key, value) in dict {
                guard let stringKey = key as? String else { continue }
                result[stringKey] = jsonSafeValue(value)
            }
            return result
        }
        if let array = value as? [Any] {
            return array.map { jsonSafeValue($0) }
        }
        if value is NSNull { return NSNull() }
        if value is NSNumber || value is String || value is Bool {
            return value
        }
        if JSONSerialization.isValidJSONObject([value]) {
            return value
        }
        return "\(value)"
    }
    
    private func imageAddress(from userInfo: [AnyHashable: Any]) -> URL? {
        let keys = [
            "image",
            "image_url",
            "imageUrl",
            "picture",
            "thumbnail",
            "attachment-url",
            "attachment_url",
            "gcm.n.image",
            "gcm.notification.image",
            "google.c.a.c_image"
        ]
        
        for key in keys {
            if let address = validAddress(userInfo[key]) {
                return address
            }
        }
        
        if let fcmOptions = userInfo["fcm_options"] as? [AnyHashable: Any],
           let address = validAddress(fcmOptions["image"]) {
            return address
        }
        if let fcmOptions = userInfo["fcm_options"] as? [AnyHashable: Any],
           let address = validAddress(fcmOptions["imageUrl"]) {
            return address
        }
        
        if let data = userInfo["data"] as? [AnyHashable: Any] {
            for key in keys {
                if let address = validAddress(data[key]) {
                    return address
                }
            }
        }
        
        if let message = userInfo["message"] as? [AnyHashable: Any],
           let data = message["data"] as? [AnyHashable: Any] {
            for key in keys {
                if let address = validAddress(data[key]) {
                    return address
                }
            }
        }
        
        if let address = recursiveImageAddress(from: userInfo) {
            return address
        }
        
        return nil
    }
    
    private func recursiveImageAddress(from value: Any) -> URL? {
        if let dictionary = value as? [AnyHashable: Any] {
            for (key, nestedValue) in dictionary {
                if let key = key as? String,
                   isImageKey(key),
                   let address = validAddress(nestedValue) {
                    return address
                }
                if let address = recursiveImageAddress(from: nestedValue) {
                    return address
                }
            }
        }
        
        if let array = value as? [Any] {
            for item in array {
                if let address = recursiveImageAddress(from: item) {
                    return address
                }
            }
        }
        
        return nil
    }
    
    private func isImageKey(_ key: String) -> Bool {
        let lowercased = key.lowercased()
        return lowercased.contains("image")
            || lowercased.contains("picture")
            || lowercased.contains("thumbnail")
    }
    
    private func validAddress(_ value: Any?) -> URL? {
        guard let string = value as? String,
              let address = URL(string: string),
              let scheme = address.scheme?.lowercased(),
              ["http", "https"].contains(scheme) else {
            return nil
        }
        return address
    }
    
    private func downloadAttachment(from address: URL, completion: @escaping (UNNotificationAttachment?) -> Void) {
        downloadTask = URLSession.shared.dataTask(with: address) { data, response, _ in
            guard let data,
                  let attachment = self.attachment(from: data, response: response, sourceAddress: address) else {
                completion(nil)
                return
            }
            completion(attachment)
        }
        downloadTask?.resume()
    }
    
    private func attachment(from data: Data, response: URLResponse?, sourceAddress: URL) -> UNNotificationAttachment? {
        let fileExtension = resolvedFileExtension(response: response, sourceAddress: sourceAddress)
        let fileAddress = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(fileExtension)
        
        do {
            try data.write(to: fileAddress)
            return try UNNotificationAttachment(identifier: "image", url: fileAddress)
        } catch {
            return nil
        }
    }
    
    private func resolvedFileExtension(response: URLResponse?, sourceAddress: URL) -> String {
        let pathExtension = sourceAddress.pathExtension
        if !pathExtension.isEmpty {
            return pathExtension
        }
        
        guard let mimeType = response?.mimeType?.lowercased() else {
            return "jpg"
        }
        
        switch mimeType {
        case "image/png":
            return "png"
        case "image/gif":
            return "gif"
        case "image/heic":
            return "heic"
        case "image/webp":
            return "webp"
        default:
            return "jpg"
        }
    }
}
