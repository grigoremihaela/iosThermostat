//
//  RegisterViewController.swift
//  ios
//
//  Created by Ivan Chau on 1/20/16.
//  Copyright © 2016 Ivan Chau & Peter Soboyejo. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var username : UITextField!
    @IBOutlet weak var password : UITextField!
    @IBOutlet weak var email : UITextField!
    @IBOutlet weak var desc : UITextView!
    @IBOutlet weak var register : UIButton!
    
    let keychain = Keychain()
    var reg = false
    @IBAction func register(sender : UIButton){
        print("register")
        username.resignFirstResponder()
        password.resignFirstResponder()
        email.resignFirstResponder()
        //desc.resignFirstResponder()
        let headers = [
            "cache-control": "no-cache",
            "content-type": "application/x-www-form-urlencoded"
        ]
        
        let usernameString = "username=" + self.username.text!
        let passwordString = "&password=" + self.password.text!
        let emailString = "&email=" + self.email.text!
        let descriptionString = "&desc=" + self.desc.text!
        let postData = NSMutableData(data: usernameString.dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(passwordString.dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(emailString.dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(descriptionString.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        //let request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:1337/register")!,
        let request = NSMutableURLRequest(URL: NSURL(string: "http://thermostat-v1.herokuapp.com/register")!,
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
                        //segue to main view, etc.
                        if(self.reg == false){
                            self.keychain.setPasscode("MPPassword", passcode: self.password.text!)
                            self.keychain.setPasscode("MPUsername", passcode: self.username.text!)
                            self.keychain.setPasscode("MPEmail", passcode: self.email.text!)
                            self.performSegueWithIdentifier("LogSeg", sender: self)
                            self.reg = true
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
    override func viewDidLoad() {
        super.viewDidLoad()
        //Hide keyboard on press return
        username.delegate = self;
        password.delegate = self;
        email.delegate = self;
        //
        self.register.layer.cornerRadius = 0.5 * register.bounds.size.width
        self.navigationItem.hidesBackButton = true;
        self.desc.delegate = self

        // Do any additional setup after loading the view.
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if(textView.text == "Description"){
            textView.text = "";
        }
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
