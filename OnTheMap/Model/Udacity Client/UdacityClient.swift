//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Galina Niukhalova on 7/3/21.
//

import Foundation

class UdacityClient {
    static var accountId: String = ""
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case session
        case studentLocation(String? = nil)
        case user(String)
        
        var stringValue: String {
            switch self {
            case .session: return Endpoints.base + "/session"
            case .studentLocation(let objectId):
                if let objectId = objectId {
                    return Endpoints.base + "/StudentLocation/\(objectId)"
                } else {
                    return Endpoints.base + "/StudentLocation?order=-updatedAt"
                }
            case .user(let id): return Endpoints.base + "/users/\(id)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func createSession(username: String, password: String, complition: @escaping (Error?) -> Void) {
        let body = CreateSessionRequest(udacity: Udacity(username: username, password: password))
        
        taskForPOSTRequest(url: Endpoints.session.url,
                           body: body, responseType: CreateSessionResponse.self,
                           optional: TaskForPOSTRequestOptionalParams(headers: ["application/json" : "Accept"], firstNCharactersToSkip: 5)) {
            (response, error) in
            if let response = response {
                accountId = response.account.key
                
                complition(nil)
            } else {
                complition(error)
            }
        }
    }
    
    class func deleteSession(complition: @escaping (Error?) -> Void) {
        var request = URLRequest(url: Endpoints.session.url)
        
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                complition(error)
            }
        }
        task.resume()
    }
    
    class func getStudentLocations(complition: @escaping ([StudentLocation], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.studentLocation().url, responseType: GetStudentLocationsResponse.self, optional: nil) { (response, error) in
            if let response = response {
                complition(response.results, nil)
            } else {
                complition([], error)
            }
        }
    }
    
    class func postStudentLocation(studentLocation: StudentLocation, completion: @escaping (Bool, Error?) -> Void) {
        let body = studentLocation
        taskForPOSTRequest(url: Endpoints.studentLocation().url,
                           body: body,
                           responseType: PostStudentLocationResponse.self,
                           optional: nil) {
            (response, error) in
            if let response = response {
                completion(response.objectId != "", nil)
            } else {
                completion(false, error)
            }
        }
    }
    
//    TODO
    class func putStudentLocation(studentLocation: StudentLocation, completion: @escaping (Error?) -> Void) {
//        let body = studentLocation

//        var request = URLRequest(url: Endpoints.studentLocation(studentLocation.objectId).url)
        
//        request.httpMethod = "PUT"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = try! JSONEncoder().encode(body)
//        let session = URLSession.shared
//        let task = session.dataTask(with: request) { data, response, error in
//            DispatchQueue.main.async {
//                completion(error)
//            }
//        }
//        task.resume()
    }

    class func getUserData(completion: @escaping (UserDataResponse?, Error?) -> Void) {
        taskForGETRequest(url: Endpoints.user(accountId).url, responseType: UserDataResponse.self, optional: TaskForGETRequestOptionalParams(firstNCharactersToSkip: 5)) { (response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
            
            if let response = response {
                DispatchQueue.main.async {
                    completion(response, nil)
                }
            }
        }
    }
    
    struct TaskForGETRequestOptionalParams {
        let firstNCharactersToSkip: Int
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, optional: TaskForGETRequestOptionalParams?, completion: @escaping (ResponseType?, Error?) -> Void) -> Void {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard var data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            if let firstNCharactersToSkip = optional?.firstNCharactersToSkip {
                data = data.subdata(in: firstNCharactersToSkip..<data.count)
            }
            
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    struct TaskForPOSTRequestOptionalParams {
        let headers: [String: String]
        let firstNCharactersToSkip: Int
    }
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, body: RequestType, responseType: ResponseType.Type, optional: TaskForPOSTRequestOptionalParams?, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        let json = try! JSONEncoder().encode(body)
        print("taskForPOSTRequest, json: \(json)")
        request.httpBody = json
        if let headers = optional?.headers {
            for (key, value) in headers {
                request.addValue(key, forHTTPHeaderField: value)
            }
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard var data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            if let firstNCharactersToSkip = optional?.firstNCharactersToSkip {
                data = data.subdata(in: firstNCharactersToSkip..<data.count)
            }
            
            let decoder = JSONDecoder()
            
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        
        task.resume()
    }
}
