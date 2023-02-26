//
//  VideoViewController.swift
//  JmacRickAndMortyUIKIT
//
//  Created by Tom on 2/10/23.
//

import UIKit
import OpenTok
import Datadog

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
    
    var subscriber: OTSubscriber!
    
    let logger = Logger.builder
        .sendNetworkInfo(true)
        .set(serviceName: "ios-App")
        .printLogsToConsole(true, usingFormat: .shortWith(prefix: "[iOS App] "))
        .build()
    
    override func viewDidLoad() {
        let span = traceEvent(operationName: "DidLoad()", tags: [:])
        defer { span.finish() }
        
        logger.info("ViewDidLoad()")

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
        let span = traceEvent(operationName: "connectToSession()", tags: [:])
        span.setTag(key: "SessionCreated", value: "LOGS WIP")
        defer { span.finish() }
        
        logger.info("Connected to Session:")

        session.connect(withToken: token, error: nil)
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
        logger.info("Publisher Failed")
    }
    
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
        let span = traceEvent(operationName: "streamCreated.event", tags: [:])
        defer { span.finish() }
        
        addPublisherView()
        
        logger.info("Publisher View Loaded")
    }
    
    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        logger.info("Publisher Stream Destroyed: \(stream.streamId)")
    }
    
    fileprivate func doPublish() {
        var error: OTError?
        defer { processError(error) }
        
        let span = traceEvent(operationName: "doPublisher()", tags: [:])
        defer { span.finish() }
        
        session.publish(publisher, error: &error)
        
        logger.info("Publisher Connected to session")
    }
    
    func addPublisherView() {
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
}

extension VideoViewController: OTSubscriberDelegate {
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("Subscriber failed for Subscriber: \(error.localizedDescription)")
    }
    
    func subscriberVideoDisabled(_ subscriber: OTSubscriberKit, reason: OTSubscriberVideoEventReason) {
        print("subscriber \(subscriber) Video Lost due to: \(reason)")
    }
        
    func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        let span = traceEvent(operationName: "subscriberDidConnect()", tags: [:])
        defer { span.finish() }
        
        addSubscriberView()
        
        logger.info("Subscriber View Added")
    }
    
    fileprivate func doSubscribe(_ stream: OTStream) {
        var error: OTError?
        defer { processError(error) }
        
        subscriber = OTSubscriber(stream: stream, delegate: self)
        //subscriber?.networkStatsDelegate = self
        
        let span = traceEvent(operationName: "doSubscribe()", tags: [:])
        defer { span.finish() }
        
        session.subscribe(subscriber!, error: &error)
        
        logger.info("Subscriber added to the session")
    }
    
    func addSubscriberView() {
        if let subscriberView = subscriber?.view {
            subscriberView.frame = CGRect(x: 50, y: 0, width: 200, height: 200)
            view.addSubview(subscriberView)
        }
    }
}

//extension VideoViewController: OTPublisherKitNetworkStatsDelegate {
//    func publisher(_ publisher: OTPublisherKit, videoNetworkStatsUpdated stats: [OTPublisherKitVideoNetworkStats]) {
//        if let publisherStats = stats.first {
//            // You can now access the publisher's network stats here
//            let videoPacketsLost = publisherStats.videoPacketsLost
//            let videoPacketReceived = publisherStats.videoBytesSent
//
//            let span = Global.sharedTracer.startSpan(operationName: "publisher.VideoNetworkStatsUpdated.Event")
//            span.setTag(key: "class", value: "VideoViewController")
//            span.setTag(key: "video_packets_lost", value: videoPacketsLost)
//            span.setTag(key: "video_packets_received", value: videoPacketReceived)
//
//            span.log(fields: ["PublisherNetworkLogs": String(describing: publisher.name)])
//            defer { span.finish() }
//
//        }
//    }
//}

//extension VideoViewController: OTSubscriberKitNetworkStatsDelegate {
//    func subscriber(_ subscriber: OTSubscriberKit, videoNetworkStatsUpdated stats: OTSubscriberKitVideoNetworkStats) {
//        let videoPacketsLost = stats.videoPacketsLost
//        let videoPacketReceived = stats.videoBytesReceived
//
//        let span = traceEvent(operationName: "doSubscribe()", tags: ["video_packets_lost": videoPacketsLost, "video_packets_received": videoPacketReceived])
//        span.log(fields: ["Subscriber Network Stats": "LOG WIP"])
//        defer { span.finish() }
//    }
//}

extension VideoViewController {
    func traceEvent(operationName: String, tags: [String: UInt64]) -> OTSpan {
        let span = Global.sharedTracer.startSpan(operationName: operationName)
        span.setActive()
        span.setTag(key: "class", value: "VideoViewController")
        for (key, value) in tags {
            span.setTag(key: key, value: value)
        }
        
        return span
    }
}

extension VideoViewController: OTSessionDelegate {
    
    func session(_ session: OTSession, receivedSignalType type: String?, from connection: OTConnection?, with string: String?) {
        
        guard let signalString = string else { return }
        if type == "subscribedConnected" {
            logger.info("Received signal from the subscriber: \(signalString)")
        }
    }
    func sessionDidConnect(_ session: OTSession) {
        let span = traceEvent(operationName: "sessionDidConnect()", tags: [:])
        defer { span.finish() }
        
        doPublish()
        
        logger.info("SessionDidConnect: \(session.sessionId)")
    }
    
    func session(_ session: OTSession, connectionCreated connection: OTConnection) {
        let span = traceEvent(operationName: "connectionCreated.event", tags: [:])
        defer { span.finish() }
        
        logger.info("ConnectionId Created \(connection.connectionId)")
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        let span = traceEvent(operationName: "sessionDidDisconnectt()", tags: [:])
        defer { span.finish() }
        
        logger.info("SessionDidConnect sessionId: \(session.sessionId)")
    }
        
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        let span = traceEvent(operationName: "streamCreated.event", tags: [:])
        defer { span.finish() }
        
        if subscriber == nil {
            doSubscribe(stream)
            logger.info("Subscriber connected: \(stream.streamId)")
        }
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        let span = traceEvent(operationName: "streamDestroyed.event", tags: [:])
        defer { span.finish() }

        if subscriber?.stream?.streamId == stream.streamId {
            subscriber?.view?.removeFromSuperview()
            subscriber = nil
        }
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("Error: \(error.localizedDescription)")
    }
}

