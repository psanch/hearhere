//
//  ViewController.swift
//  hearhere
//
//  Created by Pedro Sanchez on 12/26/18.
//  Copyright © 2018 Pedro Sanchez. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate {
    
    var peerID:MCPeerID!
    var mcSession:MCSession!
    var mcAdvertiserAssistant:MCAdvertiserAssistant!
    
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var connectionButton: UIBarButtonItem!
    
    var rmsg:String!
    var smsg:String!
    var hosting:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID)
        mcSession.delegate = self
        
        //creates a recognizer that will remove the keyboard if the user clicks on NOT the keyboard
        let tap = UITapGestureRecognizer(target: self,  action: #selector(self.removeKeyboard(_:)))
        view.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view, typically from a nib.
        
        sendButton.isEnabled = false
        chatTextView.isEditable = false
        hosting = false
        mcSession.disconnect()
        
    }
    
    @objc func removeKeyboard(_ sender: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        if inputTextField.text != "" {
            smsg = "\n\(peerID.displayName): \(inputTextField.text)\n"
            let message = smsg.data(using: String.Encoding.utf8, allowLossyConversion: false)
            
            do{
                try self.mcSession.send(message!, toPeers: self.mcSession.connectedPeers, with: .reliable)
                
            }
            catch{
                print("Error sending message :(")
            }
            
            chatTextView.text = chatTextView.text + "\nMe: \(inputTextField.text)\n"
            inputTextField.text = ""
        }
        else{
            let emptyAlert = UIAlertController(title: "You haven't entered anything to send!", message: nil, preferredStyle: .alert)
            emptyAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(emptyAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func connectionButtonTapped(_ sender: Any) {
        if mcSession.connectedPeers.count == 0 && !hosting {
            
            let connectActionSheet = UIAlertController(title: "Our chat", message: "Do you want to Host or Join a chat?", preferredStyle: .actionSheet)
            
            connectActionSheet.addAction(UIAlertAction(title: "Host Chat", style: .default, handler: {
                (action: UIAlertAction) in
                //What does DiscoveryInfo do?
                self.mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "doesnt-matter", discoveryInfo: nil, session: self.mcSession)
                self.mcAdvertiserAssistant.start()
                self.hosting = true
                
            }))
            
            connectActionSheet.addAction(UIAlertAction(title: "Join Chat", style: .default, handler: {
                (action: UIAlertAction) in
                
                let mcBrowser = MCBrowserViewController(serviceType: "doesnt-matter", session: self.mcSession)
                mcBrowser.delegate = self
                
                //shows the MPCF browser with available connections
                self.present(mcBrowser, animated: true, completion: nil)
                
            }))
            
            connectActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(connectActionSheet, animated: true, completion: nil)
            
        }
        else if mcSession.connectedPeers.count == 0 && hosting {
            
            let waitActionSheet = UIAlertController(title: "Waiting...", message: "Waiting for peers to join the chat", preferredStyle: .actionSheet)
            
            waitActionSheet.addAction(UIAlertAction(title: "Disconnect", style: .destructive, handler: {
                    (action) in
                    self.mcSession.disconnect()
                    self.hosting = false
            }))
            
            waitActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(waitActionSheet, animated: true, completion: nil)
            
        }
        else{
            
            let disconnectActionSheet = UIAlertController(title: "Are you sure you want to disconnect", message: nil, preferredStyle: .actionSheet)
            disconnectActionSheet.addAction(UIAlertAction(title: "Disconnect", style: .destructive
                , handler: {(action:UIAlertAction) in
                    self.mcSession.disconnect()
            }))
            
            disconnectActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(disconnectActionSheet, animated: true, completion: nil)
            
        }
        
        
    }
    
    //MultiPeer
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state{
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
        
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
        
        case MCSessionState.notConnected:
            print("Disconnected: \(peerID.displayName)")
        
        }
        
        if mcSession.connectedPeers.count == 0
        {
            sendButton.isEnabled = false
        }
        else
        {
            sendButton.isEnabled = true
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        DispatchQueue.main.async{
            self.rmsg = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)! as String
            self.chatTextView.text = self.chatTextView.text + self.rmsg
            
        }
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    


}
