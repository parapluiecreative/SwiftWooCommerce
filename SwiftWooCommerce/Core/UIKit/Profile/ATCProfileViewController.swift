//
//  ATCProfileViewController.swift
//  DatingApp
//
//  Created by Florian Marcu on 2/2/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Photos

class ATCProfileViewController: ATCGenericCollectionViewController, ProfileImageTapCollectionViewDelegate {
    var profileImageUpdater: ATCProfileUpdaterProtocol? = nil
    
    var user: ATCUser? {
        didSet {
            update()
        }
    }
    var uiConfig: ATCUIGenericConfigurationProtocol
    var items: [ATCGenericBaseModel]

    init(items: [ATCGenericBaseModel],
         uiConfig: ATCUIGenericConfigurationProtocol,
         selectionBlock: ATCollectionViewSelectionBlock? = nil) {
        let profileVCConfig = ATCGenericCollectionViewControllerConfiguration(
            pullToRefreshEnabled: false,
            pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
            collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
            collectionViewLayout: ATCCollectionViewFlowLayout(),
            collectionPagingEnabled: false,
            hideScrollIndicators: false,
            hidesNavigationBar: false,
            headerNibName: nil,
            scrollEnabled: true,
            uiConfig: uiConfig,
            emptyViewModel: nil
        )
        self.items = items
        self.uiConfig = uiConfig
        super.init(configuration: profileVCConfig, selectionBlock: selectionBlock)
        self.use(adapter: ATCProfileItemRowAdapter(uiConfig: uiConfig), for: "ATCProfileItem")
        self.use(adapter: ATCTextRowAdapter(font: uiConfig.boldFont(size: 18),
                                            textColor: uiConfig.mainTextColor,
                                            alignment: .center),
                 for: "ATCText")
        let roundImageAdapter = ATCRoundImageRowAdapter()
        roundImageAdapter.delegate = self
        self.use(adapter: roundImageAdapter, for: "ATCImage")
        self.use(adapter: ATCDividerRowAdapter(titleFont: uiConfig.regularFont(size: 16), minHeight: 10), for: "ATCDivider")
        self.use(adapter: ATCProfileButtonItemRowAdapter(uiConfig: uiConfig), for: "ATCProfileButtonItem")
        self.use(adapter: InstaMultiRowPageCarouselRowAdapter(uiConfig: uiConfig), for: "InstaMultiRowPageCarouselViewModel")
        self.update()
    }
    
    public func update() {
        var allItems: [ATCGenericBaseModel] = []
        if let user = user {
            allItems.append(ATCImage(user.profilePictureURL, placeholderImage: UIImage.localImage("empty-avatar")))
            allItems.append(ATCText(text: user.fullName()))
        }
        allItems.append(contentsOf: self.items)
        allItems.append(ATCProfileButtonItem(title: "Logout".localizedCore,
                                             color: nil,
                                             textColor: uiConfig.mainTextColor))
        self.genericDataSource = ATCGenericLocalHeteroDataSource(items: allItems)
        self.genericDataSource?.loadFirst()
    }
    
    func profileImageDidTap(cell: ATCRoundImageCollectionViewCell) {
        let indexPath = self.collectionView.indexPath(for: cell)
        if let indexPath = indexPath {
            let object = self.genericDataSource?.object(at: indexPath.row)
            if let _ = object as? ATCImage {
                showActionSheet(cell)
            }
        }
    }
    
    fileprivate func showActionSheet(_ view: UIView) {
        let actionSheet = UIAlertController(title: "Profile Photo", message: "Update your profile photo", preferredStyle: .actionSheet)
        let removeAction = UIAlertAction(title: "Remove Photo", style: .destructive) { [weak self] (remove) in
            // Remove photo from the firebase
            guard let self = self else { return }
            self.removePhoto()
        }
        
        let changeAction = UIAlertAction(title: "Change Photo", style: .default) { [weak self] (change) in
            guard let self = self else { return }
            self.showChangePhotoOptionsActionSheet()
        }
    
        let cancelAction = UIAlertAction(title: "Cancel".localizedCore, style: .cancel, handler: nil)

        if let popoverPresentationController = actionSheet.popoverPresentationController {
            popoverPresentationController.sourceView = view
            popoverPresentationController.sourceRect = view.frame
        }

        actionSheet.addAction(changeAction)
        actionSheet.addAction(removeAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    fileprivate func showChangePhotoOptionsActionSheet() {
        let actionSheet = UIAlertController(title: "Change Photo", message: "Change your profile photo", preferredStyle: UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] (camera) in
            //Take photo from camera
            guard let strongSelf = self else { return }
            strongSelf.didTapAddImageButton(sourceType: .camera)
        }
        
        let libraryAction = UIAlertAction(title: "Library", style: .default) { [weak self] (change) in
           //Import photo from library
            guard let self = self else { return }
            self.didTapAddImageButton(sourceType: .photoLibrary)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel".localizedCore, style: .cancel, handler: nil)
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(cancelAction)
        actionSheet.popoverPresentationController?.sourceView = view // works for both iPhone & iPad
        present(actionSheet, animated: true, completion: nil)
    }
    
    func removePhoto() {
        guard let user = user else { return }
        let documentRef = Firestore.firestore().collection("users").document("\(user.uid!)")

        let hud = CPKProgressHUD.progressHUD(style: .loading(text: "Removing"))
        hud.show(in: view)
        documentRef.updateData([
            "profilePictureURL" : FieldValue.delete()
        ]) { (error) in
            user.profilePictureURL = ATCUser.defaultAvatarURL
            hud.dismiss()
            NotificationCenter.default.post(name: kATCLoggedInUserDataDidChangeNotification, object: nil)
            self.update()
        }
    }
    
    private func didTapAddImageButton(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            picker.sourceType = sourceType
        } else {
            return
        }
    
        present(picker, animated: true, completion: nil)
    }

    func updateProfileImage(image: UIImage) {
        guard let user = user else { return }
        profileImageUpdater = ATCProfileFirebaseUpdater(usersTable: "users")
        guard let imageupdater = profileImageUpdater else { return }
        let hud = CPKProgressHUD.progressHUD(style: .loading(text: "Uploading"))
        hud.show(in: view)
        imageupdater.uploadPhoto(image: image, user: user, isProfilePhoto: true) {[weak self] (success) in
            hud.dismiss()
            NotificationCenter.default.post(name: kATCLoggedInUserDataDidChangeNotification, object: nil)
            guard let `self` = self else { return }
            // Posting a notification that profile image has changed
            self.update()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UIImagePickerControllerDelegate
extension ATCProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let asset = info[.phAsset] as? PHAsset {
            let size = CGSize(width: 500, height: 500)
            PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: nil) { [weak self] result, info in
                guard let image = result else {
                    return
                }
                guard let strongSelf = self else { return }
                strongSelf.updateProfileImage(image: image)
            }
        } else if let image = info[.originalImage] as? UIImage {
           // use image
            self.updateProfileImage(image: image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
