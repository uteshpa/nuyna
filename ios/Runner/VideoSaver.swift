import Photos

class VideoSaver {
    static func saveVideoWithoutMetadata(filePath: String, completion: @escaping (Bool, Error?) -> Void) {
        let videoURL = URL(fileURLWithPath: filePath)
        
        guard FileManager.default.fileExists(atPath: filePath) else {
            let error = NSError(domain: "VideoSaver", code: -1, userInfo: [NSLocalizedDescriptionKey: "File not found"])
            completion(false, error)
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetCreationRequest.forAsset()
            let options = PHAssetResourceCreationOptions()
            options.shouldMoveFile = false
            creationRequest.addResource(with: .video, fileURL: videoURL, options: options)
        }) { (success, error) in
            completion(success, error)
        }
    }
}
