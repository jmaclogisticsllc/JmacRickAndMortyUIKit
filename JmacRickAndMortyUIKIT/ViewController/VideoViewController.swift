//
//  VideoViewController.swift
//  JmacRickAndMortyUIKIT
//
//  Created by Tom on 2/10/23.
//

import UIKit
import OpenTok

let kWidgetHeight = 240
let kWidgetWidth = 320

class VideoViewController: UIViewController {

    let apiKey = String(cString: getenv("VONAGE_API_KEY"))
    let sessionId = String(cString: getenv("VONAGE_SESSION_ID"))
    let token = String(cString: getenv("VONAGE_TOKEN"))
    
    private var subscriberView: UIView?
    
    // Session
    lazy var session: OTSession = {
        return OTSession(apiKey: apiKey, sessionId: sessionId, delegate: self)!
    }()
    
    // Publisher
    lazy var publisher: OTPublisher = {
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        return OTPublisher(delegate: self, settings: settings)!
    }()
    
    var subscriber: OTSubscriber?
    
    let sessionButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .blue
        setupLeaveSessionButton()
        connectToSession()
    }
    
    func setupLeaveSessionButton() {
        view.addSubview(sessionButton)
        
        sessionButton.configuration = .filled()
        sessionButton.configuration?.baseBackgroundColor = .systemRed
        sessionButton.configuration?.title = "Leave Session"
        sessionButton.addTarget(self, action: #selector(goToTabView), for: .touchUpInside)
        sessionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sessionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sessionButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            sessionButton.widthAnchor.constraint(equalToConstant: 200),
            sessionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func goToTabView() {
        let nextScreen = CharacterViewController()
        nextScreen.title = "Character Screen"
        navigationController?.pushViewController(nextScreen, animated: true)
    }
    
    func connectToSession() {
        session.connect(withToken: token, error: nil)
    }
    
    private func publishCamera() {
        // 1
        guard let publisher = OTPublisher(delegate: nil) else { return }

        // 2
        var error: OTError?
        session.publish(publisher, error: &error)

        // 3
        if let error = error {
            print("An error occurred when trying to publish", error)
            return
        }

        if let pubView = publisher.view {
            pubView.frame = CGRect(x: 0, y: 0, width: 320, height: 240)
            view.addSubview(pubView)
        }
    }
    
    fileprivate func doPublish() {
        var error: OTError?
        defer {
            processError(error)
        }
        
        session.publish(publisher, error: &error)
        
        if let pubView = publisher.view {
            pubView.frame = CGRect(x: 0, y: 0, width: kWidgetWidth, height: kWidgetHeight)
            view.addSubview(pubView)
        }
    }
    
    fileprivate func doSubscribe(_ stream: OTStream) {
        var error: OTError?
        defer {
            processError(error)
        }
        subscriber = OTSubscriber(stream: stream, delegate: self)
        
        session.subscribe(subscriber!, error: &error)
    }
    
    fileprivate func processError(_ error: OTError?) {
        if let err = error {
            DispatchQueue.main.async {
                let controller = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
}

extension VideoViewController: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("Stream Failed: \(error.localizedDescription)")
    }
    
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
        print("Stream Created: \(stream.streamId)")
    }
    
    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        print("Stream Destroyed: \(stream.streamId)")
    }
}

extension VideoViewController: OTSubscriberDelegate {
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("Subscriber failed: \(error.localizedDescription)")
    }
    
    func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        if let subsView = subscriber?.view {
            subsView.frame = CGRect(x: 0, y: 240, width: 340, height: 240)
            view.addSubview(subsView)
            print("Subscriber COnnected")
        }
    }
}

extension VideoViewController: OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        print("Client Connected to Session")
        print("This is the session Id: \(session.sessionId)")
        print("This is the client capabilities: \(session.capabilities)")
        doPublish()
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        print("Dis connected")
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("Stream created: \(stream.streamId)")
        if subscriber == nil {
            doSubscribe(stream)
        }
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("Stream Destroyed: \(stream.streamId)")
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("Error: \(error.localizedDescription)")
    }
}
