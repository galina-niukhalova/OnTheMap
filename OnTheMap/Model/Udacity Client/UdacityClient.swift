//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Galina Niukhalova on 7/3/21.
//

import Foundation

class UdacityClient {
    struct Auth {
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case session
        case studentLocation
        case user(String)
        
        var stringValue: String {
            switch self {
            case .session: return Endpoints.base + "/session"
            case .studentLocation: return Endpoints.base + "/StudentLocation"
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
                Auth.sessionId = response.session.id
                
                complition(nil)
            } else {
                complition(error)
            }
        }
    }
    
// TODO
    class func deleteSession() {}
    
    class func getStudentLocations(complition: @escaping ([StudentLocation], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.studentLocation.url, responseType: GetStudentLocationsResponse.self) { (response, error) in
            if let response = response {
                complition(response.results, nil)
            } else {
                complition([], error)
            }
        }
    }
    
    class func postStudentLocation(studentLocation: StudentLocation, completion: @escaping (Bool, Error?) -> Void) {
        let body = studentLocation
        taskForPOSTRequest(url: Endpoints.studentLocation.url,
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
    class func putStudentLocation() {}
    
//    TODO
    class func getUserData() {
        
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> Void {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
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
    
    struct TaskForPOSTRequestOptionalParams {
        let headers: [String: String]
        let firstNCharactersToSkip: Int
    }
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, body: RequestType, responseType: ResponseType.Type, optional: TaskForPOSTRequestOptionalParams?, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(body)
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
