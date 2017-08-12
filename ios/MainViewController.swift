//
//  MainViewController.swift
//  ios
//
//  Created by Ivan Chau on 1/21/16.
//  Copyright © 2016 Ivan Chau & Peter Soboyejo. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var image : UIImageView!
    @IBOutlet weak var name : UILabel!
    @IBOutlet weak var username : UILabel!
    @IBOutlet weak var email : UILabel!
    @IBOutlet weak var desc : UITextView!
    @IBOutlet weak var profile : UITabBarItem!
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var tempLive: UILabel!
    @IBOutlet weak var tempLike: UITextField!
    @IBOutlet weak var tempExpected: UILabel!
    @IBOutlet weak var enterUsername: UITextField!
    
    var user = NSDictionary()

    override func viewDidLoad() {
        super.viewDidLoad()
        //Hide keyboard on press return
        tempLike.delegate = self;
        //
        self.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "blah.gif")?.imageWithRenderingMode(.AlwaysOriginal), selectedImage: UIImage(named: "145119083668802.gif"))
        self.tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.blackColor()], forState: UIControlState.Normal)
        self.tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.whiteColor()], forState: UIControlState.Selected)

        self.navigationItem.hidesBackButton = true;
        image.layer.masksToBounds = false
        image.layer.cornerRadius = image.frame.height/2
        image.clipsToBounds = true
        self.getUserData()
               // Do any additional setup after loading the view.
    }
    func getUserData(){
        let headers = [
            "cache-control": "no-cache",
        ]
        
        //let request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:1337/user/auth")!,
        let request = NSMutableURLRequest(URL: NSURL(string: "http://thermostat-v1.herokuapp.com/user/auth")!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.HTTPMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response as? NSHTTPURLResponse
                print(httpResponse)
                
                if (httpResponse?.statusCode == 200){
                    dispatch_async(dispatch_get_main_queue(), {
                        do {
                            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                            self.user = json
                            self.email.text = self.user.objectForKey("email") as? String
                            self.username.text = self.user.objectForKey("username") as? String
                            self.name.text = self.user.objectForKey("name") as? String
                            self.tempExpected.text = "\(self.user.objectForKey("temperatureLike")!)"  //int to string "\(x!)"
                            self.tempLive.text = "\(self.user.objectForKey("temperatureEntry")!)"  //int to string "\(x!)"
                            print(self.user.objectForKey("id"))
                            self.id.text = "\(self.user.objectForKey("id")!)"  //int to string "\(x!)"
                            //print(self.id.text)
                            self.desc.text = self.user.objectForKey("desc") as? String
                            let hash = self.user.objectForKey("email") as? String
                            self.getProfileImage(self.md5(string: (hash?.lowercaseString)!))
                            // use anyObj here
                        } catch {
                            print("json error: \(error)")
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
    func getProfileImage(string:String){
        let gravatarURL = "http://www.gravatar.com/avatar/" + string + "?s=480"
        let gravns = NSURL(string: gravatarURL)
        self.image.load(gravns!)
    }
    override func viewWillAppear(animated: Bool) {
        self.getUserData()
    }
    func md5(string string: String) -> String {
        var digest = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
        if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
            CC_MD5(data.bytes, CC_LONG(data.length), &digest)
        }
        
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        
        return digestHex
    }

    @IBAction func saveTempLike(sender: AnyObject) {
        //let request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:1337/user/edit/4")!)
        let request = NSMutableURLRequest(URL: NSURL(string: "http://thermostat-v1.herokuapp.com/user/edit/4")!)
        request.HTTPMethod = "POST"
        let postString =   "username=\(enterUsername.text!)&temperatureLike=\(tempLike.text!)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {
                // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {
                // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                //print("response = \(response)")
            }
            /*
            let responseString = String(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            */
        }
        self.tempExpected.text = tempLike.text
        self.username.text = enterUsername.text
        self.name.text = enterUsername.text
        tempLike.resignFirstResponder()       //hide-keyboard
        enterUsername.resignFirstResponder()  //hide-keyboard
        task.resume()
    }
    
    //Hide keyboard on press return
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.tempLike.text = tempExpected.text
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
