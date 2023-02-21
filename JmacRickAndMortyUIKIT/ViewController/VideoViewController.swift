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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .blue
        connectToSession()
    }
    
    @objc func goToTabView() {
        let nextScreen = CharacterViewController()
        nextScreen.title = "Character Screen"
        navigationController?.pushViewController(nextScreen, animated: true)
    }
    
    func connectToSession() {
        session.connect(withToken: token, error: nil)
    }
    
    fileprivate func doPublish() {
        var error: OTError?
        defer {
            processError(error)
        }
        
        session.publish(publisher, error: &error)
        
        if let pubView = publisher.view {
            pubView.frame = view.bounds
            view.addSubview(pubView)
            
            // add the button to the pubView
            let sessionButton = UIButton()
            sessionButton.configuration = .filled()
            sessionButton.configuration?.baseBackgroundColor = .systemRed
            sessionButton.configuration?.title = "Leave Session"
            sessionButton.addTarget(self, action: #selector(goToTabView), for: .touchUpInside)
            sessionButton.translatesAutoresizingMaskIntoConstraints = false
            
            pubView.addSubview(sessionButton)
            
            NSLayoutConstraint.activate([
                sessionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                sessionButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                sessionButton.widthAnchor.constraint(equalToConstant: 200),
                sessionButton.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
    }
    
    func addSubscriberView() {
        if let subscriberView = subscriber?.view {
            subscriberView.frame = CGRect(x: 50, y: 0, width: 200, height: 200)
            view.addSubview(subscriberView)
        }
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
        print("Stream Created for Publisher: \(stream.streamId)")

    }
    
    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        print("Stream Destroyed for Publisher: \(stream.streamId)")
    }
}

extension VideoViewController: OTSubscriberDelegate {
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("Subscriber failed for Subscriber: \(error.localizedDescription)")
    }
    
    func subscriberVideoDisabled(_ subscriber: OTSubscriberKit, reason: OTSubscriberVideoEventReason) {
        print("subscriber \(subscriber) Video Lost due to: \(reason)")
    }
    
    func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        addSubscriberView()
        print("Subscriber Connected to \(subscriberKit.session.streams)")
    }
    
    fileprivate func doSubscribe(_ stream: OTStream) {
        print("Subscribing to streamId: \(stream.streamId)")
        var error: OTError?
        defer {
            processError(error)
        }
        subscriber = OTSubscriber(stream: stream, delegate: self)
        
        print("Subscriber \(subscriber)")
        
        session.subscribe(subscriber!, error: &error)
    }
}

extension VideoViewController: OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        print("OTSession DidConnect: \(session.sessionId)")
        print("OTSession Capabilities: \(session.capabilities)")
        doPublish()
    }
    
    func session(_ session: OTSession, connectionCreated connection: OTConnection) {
        print("Session \(session.sessionId) detected a new connection \(connection.connectionId)")
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        print("Dis connected")
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("Session created streamId: \(stream.connection.connectionId)")
        if subscriber == nil {
            doSubscribe(stream)
        }
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("Destroying Stream ID: \(stream.streamId)")
        print("Destroying OTSessionID: \(stream.session.sessionId)")
        print("Destroying Stream connectionID: \(stream.session.connection?.connectionId)")
        if subscriber?.stream?.streamId == stream.streamId {
            
            subscriber?.view?.removeFromSuperview()
            subscriber = nil
        }
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("Error: \(error.localizedDescription)")
    }
}
