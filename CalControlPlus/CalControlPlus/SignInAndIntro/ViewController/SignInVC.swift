//
//  SignInVC.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/27.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices

class SignInVC: UIViewController {
    
    let backgroundView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "SignInBackground")
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        
        setupBackground()
        setupSignInWithAppleButton()
    }
    
    private func setupBackground() {
        view.addSubview(backgroundView)
        
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupSignInWithAppleButton() {
        let appleSignInButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        appleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(appleSignInButton)
        
        NSLayoutConstraint.activate([
            appleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appleSignInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            appleSignInButton.heightAnchor.constraint(equalToConstant: 50),
            appleSignInButton.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        appleSignInButton.addTarget(self, action: #selector(handleAppleSignInButtonTapped), for: .touchUpInside)
    }
    
    @objc private func handleAppleSignInButtonTapped() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.delegate = self
        authController.presentationContextProvider = self
        authController.performRequests()
    }
}

extension SignInVC: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            guard let identityTokenData = appleIDCredential.identityToken,
                  let identityTokenString = String(data: identityTokenData, encoding: .utf8) else {
                debugLog("Unable to fetch identity token")
                return
            }
            
            let credential = OAuthProvider.credential(
                providerID: AuthProviderID.apple,
                idToken: identityTokenString
            )
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    debugLog("Firebase Auth Sign in failed - \(error.localizedDescription)")
                    return
                }
                
                guard let user = authResult?.user else { return }
                let name = "\(fullName?.givenName ?? "") \(fullName?.familyName ?? "")"
                
                FirebaseManager.shared.getDocument(from: .users, documentID: user.uid) { (customUser: User?) in
                    if let customUser = customUser {
                        UserProfileViewModel.shared = UserProfileViewModel(user: customUser)
                        
                        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
                           let window = sceneDelegate.window {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            guard let tabBarController = storyboard.instantiateInitialViewController() as?
                                    MainTabBarController else {
                                fatalError("Unable to instantiate MainTabBarController from storyboard.")
                            }
                            window.rootViewController = tabBarController
                            window.makeKeyAndVisible()
                        }
                    } else {
                        UserInfoCollector.shared.userID = user.uid
                        UserInfoCollector.shared.name = name
                        UserInfoCollector.shared.email = email
                        let dataCollectionContainerVC = DataCollectionContainerVC()
                        self.navigationController?.pushViewController(dataCollectionContainerVC, animated: true)
                    }
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        debugLog("Sign in with Apple failed - \(error.localizedDescription)")
    }
}

extension SignInVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
