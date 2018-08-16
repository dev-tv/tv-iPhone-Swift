//
//  BackendUtilities.swift
//  Menud
//
//  Copyright © 2016 Macbook Pro. All rights reserved.
//

import AFNetworking
import CoreLocation

class BackendUtilities: NSObject {
    
    static var userAtr : LBModel = LBModel()
    
    var initTime: Date!
    var endTime: Date!
    
    static let planningQueue = OperationQueue()
    
    class func phoneIdLogin(_ phoneId: String, completionHandler:@escaping (String?, NSNumber?, Profile?, Error?)->()){
        
        let userRepository:LBModelRepository  = AppStorage.shared.adapter.repository(withModelName: "Accounts/login")
        
        let dict: NSMutableDictionary = NSMutableDictionary()
        dict.setValue(phoneId, forKey: "phoneId")
        let errorBlock: SLFailureBlock = { (error: Error?) in
            NSLog("Error on load phoneIdLogin %@", error?.localizedDescription ?? "")
            completionHandler(nil, nil,nil, error)
        }
        let successBlock: SLSuccessBlock = {
            (models: Any) -> () in
            if let response = models as? [String: Any], let token = response["id"] as? String, let user = response["user"] as? [String: Any], let userId = user["id"] as? NSNumber {
                AppStorage.shared.adapter.accessToken = token
                guard let httpManager = BackendUtilities.getHTTPManager() else { return }
                let url = Constant.serverUrl + "profiles?filter[where][accountId]=\(userId.stringValue)"
                
                httpManager.get(url, parameters: nil,
                                success: { (_, data) in
                                    if let response = data as? [[String: Any]], let profileJSON = response.first {
                                        let profile = Profile.init(json: profileJSON)
                                        completionHandler(token, userId, profile, nil)
                                    }
                },
                                failure: { (_, error) in
                                    completionHandler(nil, nil,nil, error)
                }
                )
                
            }
        }
        userRepository.invokeStaticMethod("code", parameters: dict as! [String: Any], success: successBlock, failure: errorBlock)
    }
    
    class func getSearch(_ stringQuery: String, limit: Int, skip: Int, latitude: String, longitude: String, completionHandler:@escaping (NSMutableArray?,Int, Error?)->()) {
        let adapter :  LBRESTAdapter! = AppStorage.shared.adapter
        let venuesRepository:LBModelRepository  = adapter.repository(withModelName: Constant.VenuesSearchModel)
        
        let encodedQueryString : String = stringQuery.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        var parameter: [String: Any] = [
            "limit": limit,
            "skip": skip,
            "geopoint": [
                "lat": 0,
                "lon": 0
            ],
            "where": ["name" : encodedQueryString ,"influencers" :NSMutableArray()],
            "filter": []
        ]
        
        if (latitude != "NULL") {
            parameter["geopoint"] = [
                "lat": latitude,
                "lon": longitude
            ]
        }
        
        let errorBlock: SLFailureBlock = {
            (error: Error!) -> Void in
            NSLog("Error on load getSearch %@", error.localizedDescription)
            completionHandler(nil,0, error)
        }
        let successBlock = {
            (models: Any) -> () in
            if let responseJSON = models as? [String: Any], let searchResult = responseJSON["venues"] as? [[String: Any]], let venuesTotal = responseJSON["count"] as? Int {
                let venuesArr : NSMutableArray = NSMutableArray()
                for venueItem in searchResult {
                    let venue : Venue = Venue.init(json: venueItem )
                    venuesArr.add(venue)
                }
                completionHandler(venuesArr, venuesTotal, nil);
            }
        }
        venuesRepository.invokeStaticMethod("recommendations" , parameters: parameter, success: successBlock, failure: errorBlock)
    }
    
    class func getRecommendationForInfluencer(_ influencer: Tag, limit: Int, skip: Int, filter: FilterHolder?, completionHandler:@escaping (NSMutableArray?,Int, Error?)->()) {
        let adapter :  LBRESTAdapter! = AppStorage.shared.adapter
        let venuesRepository:LBModelRepository  = adapter.repository(withModelName: Constant.VenuesSearchModel)
        
        var parameter: [String: Any] = [
            "limit": limit,
            "skip": skip,
            "geopoint": [
                "lat": 0,
                "lon": 0
            ],
            "where": ["name" : "","influencers" :[influencer.uid]],
            "filter": []
        ]
        
        if let filter = filter {
            parameter["filter"] = filter.toQuery()
        }
        
        if let currentLocation = UserLocationManager.SharedManager.currentLocation as CLLocation? {
            parameter["geopoint"] = [
                "lat": currentLocation.coordinate.latitude.description,
                "lon": currentLocation.coordinate.longitude.description
            ]
        }
        
        let errorBlock: SLFailureBlock = {
            (error: Error!) -> Void in
            NSLog("Error on load getRecommendationForInfluencer %@", error.localizedDescription)
            completionHandler(nil,0, error)
        }
        let successBlock: SLSuccessBlock = {
            (models: Any) -> () in
            if let responseJSON = models as? [String: Any], let searchResult = responseJSON["venues"] as? [[String: Any]], let venuesTotal = responseJSON["count"] as? Int {
                let venuesArr : NSMutableArray = NSMutableArray()
                for venueItem in searchResult {
                    let venue : Venue = Venue.init(json: venueItem )
                    venuesArr.add(venue)
                }
                completionHandler(venuesArr, venuesTotal, nil);
            }
        }
        venuesRepository.invokeStaticMethod("recommendations" , parameters: parameter, success: successBlock, failure: errorBlock)
    }
    
    
    class func getRecommendation(_ stringQuery: String, limit: Int, skip: Int,latitude: String, longitude: String, filter: FilterHolder?, completionHandler:@escaping ([Venue]?, Int, Error?)->()){
        let adapter :  LBRESTAdapter! = AppStorage.shared.adapter
        let venuesRepository:LBModelRepository  = adapter.repository(withModelName: Constant.VenuesSearchModel)
        
        let influencers  = NSMutableArray()
        var influencersStr : String = "["
        influencersStr =  influencersStr + "]"
        
        let str : String = stringQuery.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        var parameter: [String: Any] = [
            "limit": limit,
            "skip": skip,
            "geopoint": [
                "lat": 0,
                "lon": 0
            ],
            "where": ["name" : str ,"influencers" :influencers],
            "filter": []
        ]
        
        if (latitude != "NULL") {
            parameter["geopoint"] = [
                "lat": latitude,
                "lon": longitude
            ]
        }
        
        if (filter != nil) {
            parameter["filter"] = filter?.toQuery()
        }
        
        let errorBlock: SLFailureBlock = {
            (error: Error!) -> Void in
            NSLog("Error on load getRecommendation %@", error.localizedDescription)
            completionHandler(nil,0, error)
        }
        let successBlock: SLSuccessBlock = {
            (models: Any) -> () in
            if let responseJSON = models as? [String: Any], let searchResult = responseJSON["venues"] as? [[String: Any]], let venuesTotal = responseJSON["count"] as? Int {
                var venuesArr : [Venue] = [Venue]()
                for venueItem in searchResult {
                    let venue : Venue = Venue.init(json: venueItem )
                    venuesArr.append(venue)
                }
                completionHandler(venuesArr, venuesTotal, nil);
            }
        }
        venuesRepository.invokeStaticMethod("recommendations" , parameters: parameter, success: successBlock, failure: errorBlock)
    }
    
    class func getFilters(_ latitude: String, longitude: String, completionHandler:@escaping ([String: Any]?, Error?)->()){
        let adapter :  LBRESTAdapter! = AppStorage.shared.adapter
        let venuesRepository:LBModelRepository  = adapter.repository(withModelName: Constant.VenuesSearchModel)
        
        let parameter: [String: Any]
        
        parameter = [
            "geopoint": [
                "lat": latitude,
                "lng": longitude
            ],
        ]
        
        let errorBlock: SLFailureBlock = {
            (error: Error!) -> Void in
            NSLog("Error on load getFilters %@", error.localizedDescription)
            completionHandler(nil, error)
        }
        let successBlock: SLSuccessBlock = {
            (filters: Any) -> () in
            if let filters = filters as? [String: Any] {
                completionHandler(filters, nil);
            }
            
        }
        venuesRepository.invokeStaticMethod("filter_options", parameters: parameter, success: successBlock, failure: errorBlock)
    }
    
    class func getFavorites(_ profileId: NSNumber?, completionHandler:@escaping (NSMutableArray?, Error?)->()){
        let adapter :  LBRESTAdapter! = AppStorage.shared.adapter
        
        let url = "filter={\"include\":[{\"menu\":[{\"venue\":[\"styleProperties\"] }]},\"category\",\"tags\"]}"
        let favoritesRepository:LBModelRepository  = adapter.repository(withModelName: "profiles/" + (profileId?.stringValue)! + "/dishes?" + url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! )
        
        let errorBlock: SLFailureBlock = {
            (error: Error!) -> Void in
            NSLog("Error on load getFavorites %@", error.localizedDescription)
            completionHandler(nil, error)
        }
        
        let successBlock: LBModelAllSuccessBlock = {
            (models: [Any]!) in
            let favorites : NSMutableArray = NSMutableArray();
            for model in models {
                if let favoriteItem = model as? LBModel, let favoriteJSON = favoriteItem.toDictionary() as? [String: Any] {
                    let item = Item.init(json: favoriteJSON)
                    if let categoryJSON = favoriteJSON["category"] as? [String: Any] {
                        item.category = Category.init(json: categoryJSON)
                    }
                    if let menu = favoriteJSON["menu"] as? [String: Any], let venueJSON = menu["venue"] as? [String: Any] {
                        item.venue = Venue.initWithRealm(venueJSON)
                    }
                    favorites.add(item)
                }
            }
            completionHandler(favorites, nil);
        }
        favoritesRepository.all (success: successBlock, failure: errorBlock)
    }
    
    class func addToFavorites(_ profileId: NSNumber?, itemId: String?, completionHandler:@escaping (Menu?, Error?)->()){
        let userRepository:LBModelRepository  = AppStorage.shared.adapter.repository(withModelName: "profiles/" + (profileId?.stringValue)! + "/dishes/" + (itemId)! )
        
        let dict: NSMutableDictionary = NSMutableDictionary()
        let user = userRepository.model(with: dict as! [String: Any])
        
        let errorBlock = {
            (error: Error!) -> Void in
            NSLog("Error on load addToFavorites %@", error.localizedDescription)
            completionHandler(nil, error)
        }
        let successBlock = {
            () -> () in
            completionHandler(nil, nil)
        }
        user?.save(success: successBlock, failure: errorBlock)
    }
    
    class func searchInfluencer(_ stringQuery: String, limit: Int, skip: Int, completionHandler:@escaping ([Tag]?, Error?)->()){
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
        let url = Constant.serverUrl + "tags/influencers"
        let str : String = stringQuery.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let parameter: [String: Any]
        parameter = [
            "skip": skip,
            "where": ["name" :  str],
            "onlyPremium": false
        ]
        
        httpManager.post(url, parameters: parameter,
                         success: { (_, models) in
                            if let responseJSON = models as? [String: Any], let searchResult = responseJSON["tags"] as? [[String: Any]] {
                                let tags : NSMutableArray = NSMutableArray()
                                for tagItem in searchResult  {
                                    let tag =  Tag(json: tagItem)
                                    tags.add(tag)
                                }
                                completionHandler(tags as NSArray as? [Tag] , nil)
                            }
        },
                         failure: { (operation: AFHTTPRequestOperation?, error: Error?) in
                            completionHandler(nil, error)
        })
    }
    
    
    class func getItem(_ itemId: String, completionHandler:@escaping (Item?, Error?)->()){
        
        let adapter : LBRESTAdapter! = AppStorage.shared.adapter
        
        let venuesRepository:LBModelRepository  = adapter.repository(withModelName: Constant.ItemModel)
        let errorBlock: SLFailureBlock = {
            (error: Error!) -> Void in
            NSLog("Error on load getItem %@", error.localizedDescription)
            completionHandler(nil, error)
        }
        let successBlock: LBModelFindSuccessBlock = {
            (model: LBModel?) -> () in
            if let itemJSON = model?.toDictionary() as? [String: Any] {
                let item = Item.init(json: itemJSON)
                completionHandler(item, nil)
            }
        }
        venuesRepository.find(byId: itemId, success: successBlock, failure: errorBlock)
    }
    
    
    
    class func getHTTPManager () -> AFHTTPRequestOperationManager?{
        let  manager: AFHTTPRequestOperationManager =  AFHTTPRequestOperationManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        let securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.none)
        manager.securityPolicy = securityPolicy;
        if (AppStorage.shared.adapter.accessToken != nil) {
            manager.requestSerializer.setValue(String(format:"%@", AppStorage.shared.adapter.accessToken), forHTTPHeaderField:"Authorization" );
        } else if let user = Utilities.getCurrentUser(), let accessToken = user.accessToken {
            manager.requestSerializer.setValue(String(format:"%@", accessToken), forHTTPHeaderField:"Authorization" );
        }
        
        return manager;
    }
    
    class func getVerifyResetAccessTokenHTTPManager(Token:String) -> AFHTTPRequestOperationManager?{
        let  manager: AFHTTPRequestOperationManager =  AFHTTPRequestOperationManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        let securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.none)
        manager.securityPolicy = securityPolicy;
        manager.requestSerializer.setValue(String(format:"%@", Token), forHTTPHeaderField:"Authorization" );
        return manager;
    }
    
    class func delUserInfluencer(_ profileId: NSNumber?, completionHandler:@escaping (Error?)->()){
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
        let url = Constant.serverUrl + "profiles/" + (profileId?.stringValue)! + "/influencers"
        
        httpManager.delete(url, parameters: nil, success: { (operation, error) in
            completionHandler(nil)
        }, failure: { (operation, error) in
            completionHandler(error)
        })
    }
    
    
    class func delUserFavorite(_ profileId: NSNumber?, itemId: String?, completionHandler:@escaping (Error?)->()){
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
        let url = Constant.serverUrl + "profiles/" + (profileId?.stringValue)! + "/dishes/rel/" + (itemId)!
        
        httpManager.delete(url, parameters: nil, success: { (operation, error) in
            completionHandler(nil)
        }, failure: { (operation: AFHTTPRequestOperation?, error: Error?) in
            completionHandler(error)
        })
    }
    
    
    class func addUserInfluencer(_ profileId: NSNumber?, influencerId: NSNumber?, completionHandler:@escaping (Error?)->()){
        let userRepository:LBModelRepository  = AppStorage.shared.adapter.repository(withModelName: "profiles/" + (profileId?.stringValue)! + "/influencers/" + (influencerId?.stringValue)! )
        
        let dict: NSMutableDictionary = NSMutableDictionary()
        let userInfluencer = userRepository.model(with: dict as! [String: Any])
        
        let errorBlock: SLFailureBlock = {
            (error: Error!) -> Void in
            NSLog("Error on addUserInfluencer %@", error.localizedDescription)
            completionHandler(error)
        }
        let successBlock = {
            () -> () in
            completionHandler(nil)
        }
        userInfluencer?.save(success: successBlock, failure: errorBlock)
    }
    
    class func pinUserMeal(_ profileId: NSNumber, mealId: String, completionHandler:@escaping (Error?)->()){
        let userRepository: LBModelRepository = AppStorage.shared.adapter.repository(withModelName: "profiles/\(profileId)/meals/\(mealId)")
        
        let dict: NSMutableDictionary = NSMutableDictionary()
        let userInfluencer = userRepository.model(with: dict as! [String: Any])
        
        let errorBlock: SLFailureBlock = {
            (error: Error!) -> Void in
            NSLog("Error on addUserInfluencer %@", error.localizedDescription)
            completionHandler(error)
        }
        let successBlock = {
            () -> () in
            completionHandler(nil)
        }
        userInfluencer?.save(success: successBlock, failure: errorBlock)
    }
    
    class func delUserMeal(_ profileId: NSNumber, mealId: String, completionHandler:@escaping (Error?)->()){
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
        let url = Constant.serverUrl + "profiles/\(profileId)/meals/rel/\(mealId)"
        
        httpManager.delete(url, parameters: nil, success: { (operation, error) in
            completionHandler(nil)
        }, failure: { (operation: AFHTTPRequestOperation?, error: Error?) in
            completionHandler(error)
        })
    }
    
    class func unPinAllUserMeals(_ profileId: NSNumber, completionHandler:@escaping (Error?)->()){
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
        let url = Constant.serverUrl + "profiles/current/remove-all-pinned"
        httpManager.delete(url, parameters: nil, success: { (operation, error) in
            completionHandler(nil)
        }, failure: { (operation: AFHTTPRequestOperation?, error: Error?) in
            completionHandler(error)
        })
    }
    
    class func getUserInfluencers(_ profileId: NSNumber?, completionHandler:@escaping ([Tag]?, Error?)->()){
        let adapter :  LBRESTAdapter! = AppStorage.shared.adapter
        let favoritesRepository:LBModelRepository  = adapter.repository(withModelName: "profiles/" + (profileId?.stringValue)! + "/influencers")
        let errorBlock: SLFailureBlock = {
            (error: Error!) -> Void in
            NSLog("Error on getUserInfluencers %@", error.localizedDescription)
            completionHandler(nil, error)
        }
        
        let successBlock: LBModelAllSuccessBlock = {
            (models: [Any]!) in
            var influencers: [Tag] = [Tag]()
            for model in models {
                if let influencer = model as? LBModel, let influencerJSON = influencer.toDictionary() as? [String: Any] {
                    let influencer = Tag.init(json: influencerJSON)
                    influencers.append(influencer)
                }
            }
            completionHandler(influencers, nil);
        }
        favoritesRepository.all (success: successBlock, failure: errorBlock)
    }
    
    class func getUserMeals(_ profileId: NSNumber?, completionHandler:@escaping ([Meal]?, Error?)->()){
        let adapter :  LBRESTAdapter! = AppStorage.shared.adapter
        let favoritesRepository:LBModelRepository  = adapter.repository(withModelName: "profiles/" + (profileId?.stringValue)! + "/meals?filter[include]=recipes")
        let errorBlock: SLFailureBlock = {
            (error: Error!) -> Void in
            NSLog("Error on getUserInfluencers %@", error.localizedDescription)
            completionHandler(nil, error)
        }
        
        let successBlock: LBModelAllSuccessBlock = {
            (models: [Any]!) in
            var meals: [Meal] = [Meal]()
            for model in models {
                if let meal = model as? LBModel, let mealJSON = meal.toDictionary() as? [String: Any] {
                    let meal = Meal(json: mealJSON)
                    meals.append(meal)
                }
            }
            completionHandler(meals, nil)
        }
        favoritesRepository.all (success: successBlock, failure: errorBlock)
    }
    
    class func getUserPreferences(_ profileId: NSNumber, _ completion: @escaping (Bool, [Tag], [Meal])->()) {
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
    
       let url = Constant.serverUrl + "profiles/\(profileId)?filter[include]=influencers&filter[include][meals][recipes]=mealTimes"

        httpManager.get(url, parameters: nil,
                        success: { (_, data) in
                            var tags = [Tag]()
                            var meals = [Meal]()
                            if let response = data as? [String: Any] {
                                if let tagsResponse = response["influencers"] as? [[String: Any]] {
                                    for json in tagsResponse {
                                        tags.append(Tag(json: json))
                                    }
                                }
                                if let mealsResponse = response["meals"] as? [[String: Any]] {
                                    for json in mealsResponse {
                                        meals.append(Meal(json: json))
                                    }
                                }
                                
                                
                                completion(true, tags, meals)
                            } else {
                                completion(false, [], [])
                            }
        },
                        failure: { (_, error) in
                            completion(false, [], [])
        }
        )
    }
    
    class func getSharedSecret(_ completion: @escaping (Bool, String)->()) {
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
        let url = Constant.serverUrl + "accounts/get_shared_secret"
        
        httpManager.get(url, parameters: nil,
                        success: { (_, data) in
                            if let response = data as? [String: String], let sharedSecret = response["shared_secret"] as String? {
                                completion(true, sharedSecret)
                            } else {
                                completion(false, "")
                            }
        },
                        failure: { (_, error) in
                            completion(false, "")
        }
        )
    }
    
    class func getInfluencerProfile(_ influencerId: NSNumber, completion: @escaping (Bool, Tag?)->()) {
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
        let url = Constant.serverUrl + "tags/influencer/" + influencerId.stringValue
        
        httpManager.get(url, parameters: nil,
                        success: { (_, data) in
                            if let response = data as? [String: AnyObject] {
                                let tag = Tag(json: response)
                                completion(true, tag)
                            } else {
                                completion(false, nil)
                            }
        },
                        failure: { (_, error) in
                            completion(false, nil)
        }
        )
    }
    
    class func getTags(_ completion: @escaping (Bool, [Tag])->()) {
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
        let url = Constant.serverUrl + "publics/tags"
        
        httpManager.get(url, parameters: nil,
                        success: { (_, data) in
                            var tags = [Tag]()
                            if let response = data as? [[String: Any]] {
                                for json in response {
                                    tags.append(Tag(json: json))
                                }
                                
                                completion(true, tags)
                            } else {
                                completion(false, [])
                            }
        },
                        failure: { (_, error) in
                            completion(false, [])
        }
        )
    }
    
    class func getUserPreferences(_ completion: @escaping (Bool, [UserPreference])->()) {
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
        let url = Constant.serverUrl + "publics/user_preferences"
        
        httpManager.get(url, parameters: nil,
                        success: { (_, data) in
                            var preferences = [UserPreference]()
                            if let response = data as? [[String: Any]] {
                                for json in response {
                                    preferences.append(UserPreference(json: json))
                                }
                                
                                completion(true, preferences)
                            } else {
                                completion(false, [])
                            }
        },
                        failure: { (_, error) in
                            completion(false, [])
        }
        )
    }
    
    class func getInfluencersFromPreferences(_ preferences: [UserPreference], completion: @escaping (Bool, [Tag])->()) {
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
        let url = Constant.serverUrl + "publics/suggest_influencers"
        
        var parameters: [String: Any]?
        var preferencesIds: [String] = [String]()
        for preference in preferences {
            preferencesIds.append(preference.uid.stringValue)
        }
        if (preferencesIds.count > 0) {
            parameters = ["preferences" : preferencesIds as Any]
        }
        
        httpManager.get(url, parameters: parameters,
                        success: { (_, data) in
                            var tags: [Tag] = [Tag]()
                            if let response = data as? [[String: Any]] {
                                for json in response {
                                    tags.append(Tag.init(json: json))
                                }
                            }
                            completion(true, tags)
        },
                        failure: { (_, error) in
                            completion(false, [])
        }
        )
    }
    
    class func signUp(_ email: String, username: String, password: String, completion: @escaping (Bool, [String: AnyObject]?, [String: AnyObject]?, Error?) -> ()) {
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
        let url = Constant.authUrl + Constant.signUpAuthURL
        let parameter = [
            "email": email,
            "username": username,
            "password": password
        ]
        httpManager.post(url, parameters: parameter,
                         success: { (_, data) in
                            if let result = data as? [String: AnyObject], let accessToken = result["accessToken"] as? [String: AnyObject], let profile = result["profile"] as? [String: AnyObject] {
                                completion(true, accessToken, profile, nil)
                            }
        },
                         failure: {(_, error) in
                            completion(false, nil, nil, error)
        }
        )
    }
    class func changePwd(_ nEmail: String, oEmail: String, completion: @escaping (Bool, Error?) -> ()) {
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
        let url = Constant.serverUrl + Constant.changePwd
               let parameter = [
            "newPassword": nEmail,
            "oldPassword": oEmail
            ]
        httpManager.post(url, parameters: parameter,
                         success: { (_, data) in
                            completion(true,nil)
        },
                         failure: {(_, error) in
                            completion(false, error)
        }
        )
    }
    class func forgotPwd(_ email: String, completion: @escaping (Bool, Error?) -> ()) {
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
        let url = Constant.serverUrl + Constant.forgotPwd
        let parameter = [
            "email": email,
            ]
        httpManager.post(url, parameters: parameter,
                         success: { (_, data) in
                            completion(true,nil)
        },
                         failure: {(_, error) in
                            completion(false, error)
        }
        )
    }
    class func resetPwd(_ pwd: String, completion: @escaping (Bool, Error?) -> ()) {
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
        let url = Constant.serverUrl + Constant.resetPwd
        let parameter = [
            "newPassword": pwd,
            "confirmPassword": pwd
        ]
        httpManager.post(url, parameters: parameter,
                         success: { (_, data) in
                             completion(true, nil)
                           
        },
                         failure: {(_, error) in
                            completion(false, error)
        }
        )
    }
    
    class func signIn(_ username: String, password: String, completion: @escaping (Bool, [String: AnyObject]?, [String: AnyObject]?, Error?) -> ()) {
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
        let url = Constant.authUrl + Constant.signInAuthURL
        let parameter = [
            "username": username,
            "password": password
        ]
        httpManager.post(url, parameters: parameter,
                         success: { (_, data) in
                            if let result = data as? [String: AnyObject], let accessToken = result["accessToken"] as? [String: AnyObject], let profile = result["profile"] as? [String: AnyObject] {
                                
                                completion(true, accessToken, profile, nil)
                            }
        },
                         failure: {(_, error) in
                            completion(false, nil, nil, error)
        }
        )
    }
    
    class func getAccessToken(_ completion: @escaping (Bool, [String: AnyObject]?, Int?) -> ()) {
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
        let url = Constant.authUrl + Constant.tokenAuthURL
        httpManager.post(url, parameters: nil,
                         success: { (_, data) in
                            if let result = data as? [String: AnyObject], let accessToken = result["accessToken"] as? [String: AnyObject] {
                                completion(true, accessToken, nil)
                            }
        },
                         failure: {(operation, error) in
                            completion(false, nil, operation?.response?.statusCode)
        }
        )
    }
    
    class func checkAccessTokenValid(_ token:String, completion: @escaping (Bool, [String: AnyObject]?, Int?) -> ()) {
        guard let httpManager = BackendUtilities.getVerifyResetAccessTokenHTTPManager(Token: token) else { return }
        let url = Constant.authUrl + Constant.tokenAuthURL
        httpManager.post(url, parameters: nil,
                         success: { (_, data) in
                            if let result = data as? [String: AnyObject], let accessToken = result["accessToken"] as? [String: AnyObject] {
                                completion(true, accessToken, nil)
                            }
        },
                         failure: {(operation, error) in
                            completion(false, nil, operation?.response?.statusCode)
        }
        )
    }
    
    class func getMealTimes(_ completion: @escaping (Bool, [MealTime]?) -> ()) {
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
        let url = Constant.serverUrl + "mealTimes"
        
        httpManager.get(url, parameters: nil,
                        success: { (_, data) in
                            if let results = data as? [Any] {
                                var mealTimes = [MealTime]()
                                for result in results {
                                    if let resultJSON = result as? [String: Any] {
                                        mealTimes.append(MealTime(json: resultJSON))
                                    }
                                }
                                completion(true, mealTimes)
                            }
        },
                        failure: {(_, error) in
                            completion(false, nil)
        }
        )
    }
    
    
    class func getMeals(influencers: [Tag]?, mealTime: MealTime?, offset: Int = 0, limit: Int = 10, _ completion: @escaping (Bool, [Meal]?) -> ()) {
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
        let url = Constant.serverUrl + "meals/recommendations/"
        
        var params: [String: Any] = [
            "offset": offset,
            "limit": 100
        ]
        
        if let influencers = influencers {
            var ids = influencers.map({ (tag: Tag) -> Int in
                return Int(tag.uid) ?? 0
            })
            if ids.count == 0 {
                ids = [-1]
            }
            params["influencers"] = ids
        }
        
        if let mealTime = mealTime {
            params["mealTime"] = Int(mealTime.uid) ?? 0
        }
        
        httpManager.post(url, parameters: params,
                         success: { (_, data) in
                            if let results = data as? [Any] {
                                var meals = [Meal]()
                                for result in results {
                                    if let resultJSON = result as? [String: Any] {
                                        meals.append(Meal(json: resultJSON))
                                    }
                                }
                                
                                completion(true, meals)
                            }
        },
                         failure: {(_, error) in
                            completion(false, nil)
        }
        )
    }
    
    class func getMealDetails(mealId: String, completion: @escaping (Meal?, Error?)->()) {
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
        let url = Constant.serverUrl + "meals/\(mealId)?filter[include]=tags&filter[include][recipes]=instructions&filter[include][recipes]=ingredients"
        
        httpManager.get(url, parameters: nil,
                        success: { (_, data) in
                            if let response = data as? [String: AnyObject] {
                                let tag = Meal(json: response)
                                completion(tag, nil)
                            } else {
                                completion(nil, nil)
                            }
        },
                        failure: {(_, error) in
                            completion(nil, error)
        }
        )
    }
    
    class func getPlanDays(_ completion: @escaping ([PlanDay]?)->()) {
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
        let url = Constant.serverUrl + "profiles/current/plan-days"
        let operation = httpManager.httpRequestOperation(with: createUrlRequest(url, nil, "get") ,
                                                         success: { (_, data) in
                                                            var planDays = [PlanDay]()
                                                            if let response = data as? [[String: Any]] {
                                                                for json in response {
                                                                    planDays.append(PlanDay(json: json))
                                                                }
                                                                completion(planDays)
                                                            } else {
                                                                completion(nil)
                                                            }
        },
                                                         failure: { (_, error) in
                                                            completion(nil)
        }
        )
        planningQueue.addOperation(operation!)
    }
    
    class func getGroceryList(_ completion: @escaping ([IngredientCategory]?)->()) {
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
        let url = Constant.serverUrl + "profiles/current/grocery-list"
        
        httpManager.get(url, parameters: nil,
                        success: { (_, data) in
                            var gategories = [IngredientCategory]()
                            if let response = data as? [[String: Any]] {
                                for json in response {
                                    gategories.append(IngredientCategory(json: json))
                                }
                                completion(gategories)
                            } else {
                                completion(nil)
                            }
        },
                        failure: { (_, error) in
                            completion(nil)
        }
        )
    }
    
    class func deleteGroceryList(_ completion: @escaping (Bool)->()) {
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
        let url = Constant.serverUrl + "profiles/current/grocery-list"
        
        httpManager.delete(
            url,
            parameters: nil,
            success: { _, _ in
                completion(true)
            },
            failure: { _,_ in
                completion(false)
            }
        )
    }
    
    class func createGroceryItem(_ item: GroceryItem, _ completion: @escaping (GroceryItem?)->()) {
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
        let url = Constant.serverUrl + "profiles/current/grocery-list/add"
        
        let params = item.asDict()
        httpManager.post(url, parameters: params,
                         success: { (_, data) in
                            if let response = data as? [String: Any] {
                                completion(GroceryItem(json: response))
                            } else {
                                completion(nil)
                            }
        },
                         failure: { (_, error) in
                            completion(nil)
        }
        )
    }
    
    class func deleteGroceryItem(_ item: GroceryItem, _ completion: @escaping (Bool)->()) {
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
        let url = Constant.serverUrl + "profiles/current/grocery-list/grocery-item/" + String(item.id)
        httpManager.delete(url, parameters: [],
                           success: { (_, _) in
                            completion(true)
        },
                           failure: { (_, error) in
                            completion(false)
        }
        )
    }
    
    private class func createUrlRequest(_ url: String, _ params: [String: Any]?, _ method: String = "post" ) -> URLRequest{
        var urlRequest = URLRequest(url: URL(string: url)!)
        if let params = params {
            let data = try? JSONSerialization.data(withJSONObject: params)
            urlRequest.httpBody = data
        }
        urlRequest.httpMethod = method
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue(AppStorage.shared.adapter.accessToken, forHTTPHeaderField: "Authorization")
        return urlRequest
    }
    
    class func removeMealFromPlanningDay(_ date: Date, _ mealId: String, _ timestamp: String , _ completion: @escaping (Bool)->()) {
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
        let url = Constant.serverUrl + "profiles/current/plan-days/remove"
        let params: [String: Any] = [
            "date": date.dateStringWithFormat("YYYY-MM-dd"),
            "mealId": mealId,
            "timestamp": timestamp
        ]
        let operation = httpManager.httpRequestOperation(with: createUrlRequest(url, params) ,
                                                         success: { (_, data) in
                                                            completion(true)
        },
                                                         failure: { (_, error) in
                                                            completion(false)
        }
        )
        planningQueue.addOperation(operation!)
    }
    
    class func addMealToPlanningDay(_ date: Date, _ mealId: String, _ completion: @escaping (String?)->()) {
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
        let url = Constant.serverUrl + "profiles/current/plan-days/add"
        let params: [String: Any] = [
            "date": date.dateStringWithFormat("YYYY-MM-dd"),
            "mealId": mealId
        ]
        let operation = httpManager.httpRequestOperation(with: createUrlRequest(url, params),
                                                         success: { (_, data) in
                                                            if let response = data as? [String: Any] {
                                                                completion(response["timestamp"] as? String)
                                                            } else {
                                                                completion(nil)
                                                            }
        },
                                                         failure: { (_, error) in
                                                            completion(nil)
        })
        planningQueue.addOperation(operation!)
    }
    
    class func updateGroceryItem(_ item: GroceryItem, _ completion: @escaping (GroceryItem?)->()) {
        guard let httpManager = BackendUtilities.getHTTPManager() else { return }
        let url = Constant.serverUrl + "profiles/current/grocery-list/grocery-item/" + String(item.id)
        let params = item.asDict()
        httpManager.put(url, parameters: params,
                        success: { (_, data) in
                            if let response = data as? [String: Any] {
                                completion(GroceryItem(json: response))
                            } else {
                                completion(nil)
                            }
        },
                        failure: { (_, error) in
                            completion(nil)
        }
        )
    }
    

    
    class func getMailChimpHTTPManager () -> AFHTTPRequestOperationManager?{
        let  manager: AFHTTPRequestOperationManager =  AFHTTPRequestOperationManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        let securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.none)
        manager.securityPolicy = securityPolicy;
        return manager;
    }
    
    class func subscribeChimpLists(email:String,completion: @escaping ([String: AnyObject]?, Error?,Int?)->()) {
        guard let httpManager = BackendUtilities.getMailChimpHTTPManager() else { return }
        let url = Constant.mailChimpUrl() + Constant.listIdMailChimp + Constant.members
        let param : [String: Any] = [
            "email_address": email,
            "status": "subscribed"
        ]
       httpManager.requestSerializer.setAuthorizationHeaderFieldWithUsername("user", password: Constant.mailChimpKey)
       httpManager.post(url, parameters: param, success: {(_, data) in
        if let response = data as? [String: AnyObject] {
            completion(response, nil,nil)
        } else {
            completion(nil, nil,nil)
        }
         }, failure: {(operation, error) in
        completion(nil, error,operation?.response.statusCode)
       })
    }
    
    class func getSubscribeStatusMailChimp(memberid:String,completion: @escaping ([String: AnyObject]?, Error?,Int?)->()) {
        guard let httpManager = BackendUtilities.getMailChimpHTTPManager() else { return }
        let url = Constant.mailChimpUrl() + Constant.listIdMailChimp +  Constant.members + "\(memberid)"
               httpManager.requestSerializer.setAuthorizationHeaderFieldWithUsername("user", password: Constant.mailChimpKey)
        httpManager.get(url, parameters: nil, success: {(_, data) in
            if let response = data as? [String: AnyObject] {
                completion(response, nil, nil)
            } else {
                completion(nil, nil,nil)
            }
        }, failure: {(operation, error) in
            completion(nil, error,operation?.response.statusCode)
        })

    }
    
    class func updateSubscribeStatusMailChimp(memberid:String,status: String,completion: @escaping ([String: AnyObject]?, Error?,Int?)->()) {
        guard let httpManager = BackendUtilities.getMailChimpHTTPManager() else { return }
        let url = Constant.mailChimpUrl() + Constant.listIdMailChimp +  Constant.members + "\(memberid)"
        httpManager.requestSerializer.setAuthorizationHeaderFieldWithUsername("user", password: Constant.mailChimpKey)
        let param : [String: Any] = ["status": status]
        httpManager.patch(url, parameters: param, success: {(_, data) in
            if let response = data as? [String: AnyObject] {
                completion(response, nil,nil)
            } else {
                completion(nil, nil,nil)
            }
        }, failure: {(operation, error) in
            completion(nil, error,operation?.response.statusCode)
        })
    }
    
}
