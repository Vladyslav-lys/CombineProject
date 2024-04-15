//
//  ViewController.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 29.08.2022.
//

import UIKit
import WidgetKit
import Services

typealias PickerDelegate = UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension MainVC: Makeable {
    static func make() -> MainVC {
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MainVC") { coder in
            MainVC(coder: coder)
        }
    }
}

final class MainVC: BaseVC, ViewModelContainer {
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    
    var viewModel: MainVM?
    
    private var dataSource: DataSource?
    
    // MARK: - Lifecyrcle
    init?(viewModel: MainVM, coder: NSCoder) {
        super.init(coder: coder)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
        getUsers(params: UserParams(results: 10))
        //download()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //openGallery()
    }
    
    // MARK: - Setup
    private func setup() {
        dataSource = makeDataSource(for: tableView)
        withNonNil(tableView) {
            $0.register(MainTVC.self)
            $0.delegate = self
        }
    }
    
    // MARK: - Bind
    override func bind() {
        super.bind()
        viewModel?.$users
            .compactMap { $0 }
            .sink { [weak self] in
                guard let self = self else { return }
                
                $0.forEach { user in
                    print("\(user.name.first) \(user.name.last)")
                }
                
                let snapshot = self.makeSnapshot(from: $0)
                self.dataSource?.apply(snapshot)
            }
            .store(in: &subscriptions)
        
        viewModel?.$uploadResult
            .compactMap { $0 }
            .sink {
                print("Uploaded!!!")
            }
            .store(in: &subscriptions)
        
        viewModel?.$downloadResult
            .compactMap { $0 }
            .sink {
                print("Downloaded!!!")
            }
            .store(in: &subscriptions)
        
        viewModel?.$error
            .compactMap { $0 }
            .sink {
                print($0.localizedDescription)
            }
            .store(in: &subscriptions)
    }
    
    // MARK: - Helpers
    private func openGallery() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.mediaTypes = ["public.image"]
        vc.delegate = self
        present(vc, animated: true)
    }
    
    private func getUsers(params: UserParams) {
        viewModel?.getUsers(params: params)
    }
    
    private func upload(params: UploadFileParams) {
        viewModel?.upload(params: params)
    }
    
    private func download() {
        viewModel?.download()
    }
    
    private func showDetail(user: User) -> DetailVC {
        DetailVC.make {
            $0.viewModel = DetailVM(user: user)
        }
    }
    
    // MARK: - Actions
    @IBAction private func didTap(_ sender: UIButton) {
        guard let text = textField.text else { return }
        viewModel?.setTextValue(text)
    }
}

// MARK: - PickerDelegate
extension MainVC: PickerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage,
              let data = image.jpegData(compressionQuality: 100) else { return }
        let imageUrl = info[.imageURL] as? URL
        if let imageUrl = imageUrl, imageUrl.pathExtension != "jpeg" && imageUrl.pathExtension != "png" {
            dismiss(animated: true)
            return
        }
        upload(params: UploadFileParams(data: data,
                                        name: "image/\(imageUrl?.pathExtension ?? "jpeg")",
                                        mimeType: imageUrl?.pathExtension ?? "jpeg",
                                        fileExtension: imageUrl?.deletingPathExtension().lastPathComponent ?? image.description))
        dismiss(animated: true)
    }
}

// MARK: - MainTVCDelegate
extension MainVC: MainTVCDelegate {
    func didTapRemove(_ cell: MainTVC, with user: User) {
        viewModel?.removeUser(user)
    }
    
    func didTapRemoveComment(_ cell: MainTVC, with comment: Comment, andUser user: User) {
        viewModel?.removeComment(comment, withUser: user)
    }
    
    func didTapAddComment(_ cell: MainTVC, withUser user: User) {
        viewModel?.addComment(toUser: user)
    }
    
    func didGetPreview(_ cell: MainTVC, withUser user: User) -> UIViewController {
        showDetail(user: user)
    }
}

// MARK: - UITableViewDelegate
extension MainVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = viewModel?.users?[indexPath.row] else { return }
        let detailVC = showDetail(user: user)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
