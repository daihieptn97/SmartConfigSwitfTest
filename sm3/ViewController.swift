//
//  ViewController.swift
//  sm3
//
//  Created by Trần Hiệp on 9/2/20.
//  Copyright © 2020 Trần Hiệp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var SSID:String = ""
    var PASS:String = ""
    var BSSID:String = ""
    
    var isConfirmState: Bool!
    
    var condition:NSCondition!
    var esptouchTask: ESPTouchTask!
    
    var wifiPass = "hamhoc123"
    var wifiName = "Thu Hung"
    
    @IBAction func btnOnPress(_ sender: Any) {
        print("tapConfirmForResult")
        if isConnectWiFi() {
            if wifiPass != "" {
                SSID = getwifi().getSSID()!
                PASS = wifiPass
                BSSID = getwifi().getBSSID()!
                self.tapConfirmForResult()
                DispatchQueue.main.asyncAfter(deadline: .now() + 60.0) { // Change `2.0` to the desired number of seconds.
                   // Code you want to be delayed
                    print("End 15s")
                    self.cancel()
                    
                }
            } else {
                let title = NSLocalizedString("WIFI_INPUT_PASSWORD", comment: "")
                let butonTitle = NSLocalizedString("CONFIRM", comment: "")
                
                let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                let doneButton = UIAlertAction(title: butonTitle, style: .default, handler: nil)
                alert.addAction(doneButton)
                self.present(alert, animated: true, completion: nil)
            }
            
        } else {
//            let title = NSLocalizedString("WIFI_DISCONNECTED", comment: "")
//            let butonTitle = NSLocalizedString("Huỷ", comment: "")
//            let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
//            let doneButton = UIAlertAction(title: butonTitle, style: .default, handler: nil)
//            alert.addAction(doneButton)
//            self.present(alert, animated: true, completion: nil)
            print("wifi disconnected")
            return
        }
    }
    
    func isConnectWiFi() -> Bool {
        print("isConnectWiFi")
        let wifiSSID = getwifi().getSSID()
        return wifiSSID != nil ? true : false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化同步锁
        condition = NSCondition()
        
        // 初始化按钮配置状态
        self.isConfirmState = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 每次载入都刷新无线网络的状态
        print("viewWillAppear")
        loadingNetworkStatus()
    }
    
    override func didReceiveMemoryWarning() {
        print("didReceiveMemoryWarning")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadingNetworkStatus() {
        print("loadingNetworkStatus")
        let wifiSSID = getwifi().getSSID()
        
        guard wifiSSID != nil else {
            let text = NSLocalizedString("WIFI_DISCONNECTED", comment: "")
            wifiName = text
            return
        }
        let text = NSLocalizedString("WIFI_CONNECTED", comment: "")
        wifiName = text + wifiSSID!
    }
    
    
    func tapConfirmForResult() {
        print("tapConfirmForResult")
        if isConfirmState {
            
            print("Configuration in progress...")
            let queue = DispatchQueue.global(qos: .default)
            queue.async {
                print("Thread is working...")
                let esptouchResult: ESPTouchResult = self.executeForResult()
                DispatchQueue.main.async(execute: {
                    if !esptouchResult.isCancelled {
                        //                        UIAlertView(title: resultTitle, message: esptouchResult.description, delegate: nil, cancelButtonTitle: confirmSring).show()
                        print(" esptouchResult.description",  esptouchResult.description)
                        // IP拼接
                        
                        let strIP = String(esptouchResult.ipAddrData[0]) + "." + String(esptouchResult.ipAddrData[1]) + "." + String(esptouchResult.ipAddrData[2]) + "." + String(esptouchResult.ipAddrData[3])
                        print("⭕️\(strIP)")
                        
                    }
                })
            }
        } else {
            print("tapConfirmForResult else")
            self.isConfirmState = false;
            self.cancel()
        }
    }
    
    
    
    /* Configuration result */
    func executeForResult() -> ESPTouchResult {
        print("executeForResult")
        // Sync lock
        condition.lock()
        // Get the parameters required for configuration
        esptouchTask = ESPTouchTask(apSsid: SSID, andApBssid: BSSID, andApPwd: PASS)
        // Set up proxy
        condition.unlock()
        let esptouchResult: ESPTouchResult = self.esptouchTask.executeForResult()
        return esptouchResult
    }
    
    /* Cancel distribution network */
    func cancel() {
        print("cancel")
        condition.lock()
        if self.esptouchTask != nil {
            self.esptouchTask.interrupt()
        }
        condition.unlock()
    }
    
    
//    /* Click on the blank to hide the keyboard */
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("touchesBegan")
//        self.view.endEditing(true)
//    }
//    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        print("textFieldShouldReturn")
//        textField.resignFirstResponder()
//        return true
//    }
//    
    
}

