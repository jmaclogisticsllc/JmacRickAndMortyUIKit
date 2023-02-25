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
        .sendLogsToDatadog(true)
        .set(loggerName: "ios")
        .set(serviceName: "ios-app")
        .printLogsToConsole(true, usingFormat: .shortWith(prefix: "[iOS App] "))
        .build()
    
    override func viewDidLoad() {
        let span = Global.sharedTracer.startSpan(operationName: "DidLoad()")
        span.setTag(key: "class", value: "VideoViewController")
        span.finish()
        
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
        let span = Global.sharedTracer.startSpan(operationName: "connectToSession()")
        span.setTag(key: "class", value: "VideoViewController")
        defer { span.finish() }
        logger.info("Connect to session")
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
        logger.info("Publisher Stream created, new stream is created: \(stream.streamId)")
        
        let span = Global.sharedTracer.startSpan(operationName: "streamCreated.event")
        span.setTag(key: "class", value: "VideoViewController")
        defer { span.finish() }
        
        addPublisherView()
    }
    
    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        logger.info("Publisher Stream Destroyed: \(stream.streamId)")
    }
    
    fileprivate func doPublish() {
        var error: OTError?
        defer { processError(error) }
        
        let span = Global.sharedTracer.startSpan(operationName: "doPublisher()")
        span.setTag(key: "class", value: "VideoViewController")
        defer { span.finish() }
        
        logger.info("Publisher started publisher: \(String(describing: publisher.name))")
        session.publish(publisher, error: &error)
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
        let span = Global.sharedTracer.startSpan(operationName: "subscriberDidConnect()")
        span.setTag(key: "class", value: "VideoViewController")
        defer { span.finish() }
        
        logger.info("Subscriber View Added to this stream Id: \(String(describing: subscriberKit.stream?.streamId))")
        addSubscriberView()
    }
    
    fileprivate func doSubscribe(_ stream: OTStream) {
        var error: OTError?
        defer { processError(error) }
        
        subscriber = OTSubscriber(stream: stream, delegate: self)
        subscriber?.networkStatsDelegate = self
        
        let span = Global.sharedTracer.startSpan(operationName: "doSubscribe()")
        span.setTag(key: "class", value: "VideoViewController")
        defer { span.finish() }
        
        logger.info("Subscriber added to stream id: \(stream.streamId)")
        
        session.subscribe(subscriber!, error: &error)
    }
    
    func addSubscriberView() {
        if let subscriberView = subscriber?.view {
            subscriberView.frame = CGRect(x: 50, y: 0, width: 200, height: 200)
            view.addSubview(subscriberView)
        }
    }
}

extension VideoViewController: OTPublisherKitNetworkStatsDelegate {
    func publisher(_ publisher: OTPublisherKit, videoNetworkStatsUpdated stats: [OTPublisherKitVideoNetworkStats]) {
        if let publisherStats = stats.first {
            // You can now access the publisher's network stats here
            let videoPacketsLost = publisherStats.videoPacketsLost
            let videoPacketReceived = publisherStats.videoBytesSent
            
            let span = Global.sharedTracer.startSpan(operationName: "publisher.VideoNetworkStatsUpdated.Event")
            span.setTag(key: "class", value: "VideoViewController")
            span.setTag(key: "video_packets_lost", value: videoPacketsLost)
            span.setTag(key: "video_packets_received", value: videoPacketReceived)
            defer { span.finish() }
        }
    }
}

extension VideoViewController: OTSubscriberKitNetworkStatsDelegate {
    func subscriber(_ subscriber: OTSubscriberKit, videoNetworkStatsUpdated stats: OTSubscriberKitVideoNetworkStats) {
        let videoPacketsLost = stats.videoPacketsLost
        let videoPacketReceived = stats.videoBytesReceived
        
        let span = Global.sharedTracer.startSpan(operationName: "subscriber.VideoNetworkStatsUpdated.Event")
        span.setTag(key: "class", value: "VideoViewController")
        span.setTag(key: "video_packets_lost", value: videoPacketsLost)
        span.setTag(key: "video_packets_received", value: videoPacketReceived)
        defer { span.finish() }
    }
}

extension VideoViewController {
    func traceEvent(operationName: String, tags: [String: String]) -> OTSpan {
        let span = Global.sharedTracer.startSpan(operationName: operationName)
        span.setTag(key: "class", value: "VideoViewController")
        for (key, value) in tags {
            span.setTag(key: key, value: value)
        }
        
        return span
    }
}

extension VideoViewController: OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        let span = traceEvent(operationName: "sessionDidConnect()", tags: [:])
        defer { span.finish() }
        
        doPublish()
    }
    
    func session(_ session: OTSession, connectionCreated connection: OTConnection) {
        let span = Global.sharedTracer.startSpan(operationName: "connectionCreated.event")
        span.setTag(key: "class", value: "VideoViewController")
        defer { span.finish() }
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        let span = Global.sharedTracer.startSpan(operationName: "streamCreated.event")
        span.setTag(key: "class", value: "VideoViewController")
        defer { span.finish() }
    }
        
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        if subscriber == nil {
            doSubscribe(stream)
            logger.info("Subscriber connected: \(stream.streamId)")
        }
        
        let span = Global.sharedTracer.startSpan(operationName: "streamCreated.event")
        span.setTag(key: "class", value: "VideoViewController")
        defer { span.finish() }
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        
        let span = Global.sharedTracer.startSpan(operationName: "streamDestroyed.event")
        span.setTag(key: "class", value: "VideoViewController")
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
