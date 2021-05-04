//
//  ATCComposerPhotoGalleryViewController.swift
//  ListingApp
//
//  Created by Florian Marcu on 10/6/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import Photos
import UIKit

class ATCComposerPhotoGalleryViewController: ATCGenericCollectionViewController {
    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        let layout = ATCLiquidCollectionViewLayout(cellPadding: 10)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let vcConfig = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                       pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
                                                                       collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
                                                                       collectionViewLayout: layout,
                                                                       collectionPagingEnabled: false,
                                                                       hideScrollIndicators: true,
                                                                       hidesNavigationBar: false,
                                                                       headerNibName: nil,
                                                                       scrollEnabled: true,
                                                                       uiConfig: uiConfig,
                                                                       emptyViewModel: nil)

        super.init(configuration: vcConfig)
        let size = CGSize(width: 70, height: 70)
        use(adapter: ATCFormImageRowAdapter(size: size, uiConfig: uiConfig), for: "ATCFormImageViewModel")
        setupDataSource()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectionBlock =  {[weak self] (navigationController, object, indexPath) in
            guard let `self` = self else { return }
            if let viewModel = object as? ATCFormImageViewModel {
                if let image = viewModel.image {
                    let vc = self.removeImageAlertController(image: image, index: indexPath.row, isVideoPreview: viewModel.isVideoPreview)
                    self.parent?.present(vc, animated: true)
                } else {
                    let vc = self.addImageAlertController()
                    self.parent?.present(vc, animated: true)
                }
            }
        }
    }

    private func setupDataSource() {
        if genericDataSource == nil {
            genericDataSource = ATCGenericLocalDataSource<ATCFormImageViewModel>(items: [ATCFormImageViewModel(image: nil, videoUrl: nil)])
            collectionView?.reloadData()
        }
    }

    private func removeImageAlertController(image: UIImage, index: Int, isVideoPreview: Bool) -> UIAlertController {
        let alert = UIAlertController(title: (isVideoPreview ? "Remove video" : "Remove photo").localizedComposer, message: "", preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: (isVideoPreview ? "Remove video" : "Remove photo").localizedComposer, style: .destructive, handler: {[weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.didTapRemoveImageButton(image: image, index: index)
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localizedCore, style: .cancel, handler: nil))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = self.view.bounds
        }
        return alert
    }

    private func didTapRemoveImageButton(image: UIImage, index: Int) {
        if let ds = self.genericDataSource as? ATCGenericLocalDataSource<ATCFormImageViewModel> {
            ds.items.remove(at: index)
            self.collectionView?.reloadData()
        }
    }

    private func addImageAlertController() -> UIAlertController {
        let alert = UIAlertController(title: "Upload Media".localizedComposer, message: "Choose Media".localizedCore, preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Import from Library".localizedComposer, style: .default, handler: {[weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.didTapAddImageButton(sourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Take Photo".localizedComposer, style: .default, handler: {[weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.didTapAddImageButton(sourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localizedCore, style: .cancel, handler: nil))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = self.view.bounds
        }
        return alert
    }

    private func didTapAddImageButton(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self

        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            picker.sourceType = sourceType
        } else {
            return
        }

        picker.mediaTypes = ["public.image", "public.movie"]

        present(picker, animated: true, completion: nil)
    }

    fileprivate func didAddImage(_ image: UIImage, videoUrl: URL?) {
        if let ds = self.genericDataSource as? ATCGenericLocalDataSource<ATCFormImageViewModel> {
            if videoUrl != nil {
                ds.items = ds.items.filter({ $0.image == nil })
            } else {
                ds.items = ds.items.filter({ $0.videoUrl == nil })
            }
            let calculateNewMediaIndex = (videoUrl != nil) ? 0 : ds.items.count - 1
            ds.items.insert(ATCFormImageViewModel(image: image, videoUrl: videoUrl), at: calculateNewMediaIndex)
            self.collectionView?.reloadData()
        }
        
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ATCComposerPhotoGalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let asset = info[.phAsset] as? PHAsset {
            let size = CGSize(width: 500, height: 500)
            PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: nil) { result, info in
                guard let image = result else {
                    return
                }
                self.didAddImage(image, videoUrl: nil)
            }
        } else if let image = info[.originalImage] as? UIImage {
            didAddImage(image, videoUrl: nil)
        } else if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String, mediaType == "public.movie" {
            if let mediaURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL  {
                
                let videoData = NSData(contentsOf: mediaURL)
                let videoName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
                let videoFileUrl = documentDirectory().appendingPathComponent(videoName+".mp4")
                
                DispatchQueue.global().async {
                    do {
                        if FileManager.default.fileExists(atPath: videoFileUrl.path) {
                            try FileManager.default.removeItem(at: videoFileUrl)
                        }
                        videoData?.write(to: videoFileUrl, atomically: false)
                    } catch (let error) {
                        print("Cannot copy: \(error)")
                    }
                }
                
                let asset = AVURLAsset(url: videoFileUrl, options: nil)
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                var videoThumbnail = UIImage()
                do {
                    let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
                    videoThumbnail = UIImage(cgImage: thumbnailImage)
                } catch let error {
                    print(error)
                }
                let videoDuration = asset.duration
                let videoDurationSeconds = CMTimeGetSeconds(videoDuration)
                
                self.didAddImage(videoThumbnail, videoUrl: videoFileUrl)
            }
        }
       
    }

    func documentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
