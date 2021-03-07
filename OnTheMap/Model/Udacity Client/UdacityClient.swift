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
        case createSession
        
        var stringValue: String {
            switch self {
            case .createSession: return "https://onthemap-api.udacity.com/v1/session"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func createSession(username: String, password: String, complition: @escaping (Error?) -> Void ) {
        let body = CreateSessionRequest(udacity: Udacity(username: username, password: password))
        
        taskForPOSTRequest(url: Endpoints.createSession.url, body: body, responseType: CreateSessionResponse.self) { (response, error) in
            if let response = response {
                Auth.sessionId = response.session.id
                print("createSession: ", response)
                    
                complition(nil)
            } else {
                complition(error)
            }
        }
    }
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, body: RequestType, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let newData = data.subdata(in: 5..<data.count)
            
            let decoder = JSONDecoder()
            
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                
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
