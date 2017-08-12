//
//  LoginViewController.swift
//  ios
//
//  Created by Ivan Chau on 1/19/16.
//  Copyright © 2016 Ivan Chau & Peter Soboyejo. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var password : UITextField!
    @IBOutlet weak var login : UIButton!
    @IBOutlet weak var register : UIButton!
    @IBOutlet weak var logo : UIImageView!
    @IBOutlet weak var email: UITextField!
    
    //let socket = SocketIOClient(socketURL: NSURL(string:"localhost:1337")!)
    let socket = SocketIOClient(socketURL: NSURL(string:"http://thermostat-v1.herokuapp.com")!)
    var loggedIn = false;
    let keychain = Keychain()
    var userData = NSDictionary()
    @IBAction func login(sender:UIButton){
        if (self.email.text == "" || self.password.text == ""){
            let alertView = UIAlertController(title: "UWOTM8", message: "Fam, what you tryna pull?", preferredStyle: .Alert)
            let OK = UIAlertAction(title: "Is it 2 l8 2 say sorry", style: .Default, handler: nil)
            alertView.addAction(OK)
            self.presentViewController(alertView, animated: true, completion: nil);
            return;
        }
        password.resignFirstResponder()
        email.resignFirstResponder()
        
        self.loginRequestWithParams(self.email.text!, passwordString: self.password.text!)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //Hide keyboard on press return
        password.delegate = self;
        email.delegate = self;
        //
        self.socket.connect()
        self.addSocketHandlers()
        self.loggedIn = false;
        logo.layer.masksToBounds = false
        logo.layer.cornerRadius = logo.frame.height/2
        logo.clipsToBounds = true
        
        //comment below to force login
        
        if(self.keychain.getPasscode("MPPassword")! != "" && self.keychain.getPasscode("MPEmail")! != ""){
            self.loginRequestWithParams(self.keychain.getPasscode("MPEmail") as! String, passwordString: self.keychain.getPasscode("MPPassword") as! String)
        }
        // Do any additional setup after loading the view.
    }
    func addSocketHandlers(){
            // Our socket handlers go here
        socket.on("connect") {data, ack in
            print("socket connected")
        }
    }
    func loginRequestWithParams(emailString : String, passwordString : String){
        let headers = [
            "cache-control": "no-cache",
            "content-type": "application/x-www-form-urlencoded"
        ]
        
        let emailStr = "email=" + emailString
        let passwordStr = "&password=" + passwordString
        let postData = NSMutableData(data: emailStr.dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(passwordStr.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        //let request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:1337/login")!,
        let request = NSMutableURLRequest(URL: NSURL(string: "http://thermostat-v1.herokuapp.com/login")!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.HTTPMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.HTTPBody = postData
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response as? NSHTTPURLResponse
                print(httpResponse)
                
                if (httpResponse?.statusCode == 200){
                    dispatch_async(dispatch_get_main_queue(), {
                        //segue to main view.
                        if(self.keychain.getPasscode("MPPassword") == "" || self.keychain.getPasscode("MPEmail") == ""){
                            self.keychain.setPasscode("MPPassword", passcode: passwordString)
                            self.keychain.setPasscode("MPEmail", passcode: emailString)
                        }
                        if (self.loggedIn == false){
                            self.performSegueWithIdentifier("LoginSegue", sender: self)
                            // use anyObj here
                            self.loggedIn = true;
                        }else{
                            
                        }
                    })
                }else{
                    print("error")
                }
                // use anyObj here
                print("json error: \(error)")
            }
        })
        
        dataTask.resume()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Hide keyboard on press return
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    
    
}
