//
//  PurpleManager.swift
//  purpleAir
//
//  Created by jim kardach on 10/15/20.
//

import Foundation

protocol UpdatePurpleDelegate {
    func didUpdatePurple(_ purpleManager: PurpleManager, purple: PurpleModel)
    func didFailWithError(_ purpleManager: PurpleManager, error: Error)
}

class PurpleManager {
    let purpleURL = "https://www.purpleair.com/json?show=79963&key=PLAU2B5XC0FSICZR"
    var delegate: UpdatePurpleDelegate?
    
    func performRequest() {
        if let url = URL(string: purpleURL) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                    self.delegate?.didFailWithError(self, error: error!)
                    return
                }
                if let safeData = data {
                    if let purple = self.parseJSON(safeData) {
                        self.delegate?.didUpdatePurple(self, purple: purple)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ purpleData: Data) -> PurpleModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(PurpleData.self, from: purpleData)
            
            let purple = PurpleModel()
  
            let values = decodedData.results[0]
            let statString = values.Stats  // JSON String
            let dict = convertStringToDictionary(text: statString!)
            
            purple.humidity = values.humidity ?? "error"
            purple.temp = values.temp_f ?? "error"
            purple.pressure = values.pressure ?? "error"
            
            
            purple.PM = dict!["v"] as? Double ?? 0.0
            purple.PM10min = dict!["v1"] as? Double ?? 0.0
            purple.PM30min = dict!["v2"] as? Double ?? 0.0
            purple.PM1hr = dict!["v3"] as? Double ?? 0.0
            purple.PM6hr = dict!["v4"] as? Double ?? 0.0
            purple.PM24hr = dict!["v5"] as? Double ?? 0.0
            purple.PM1week = dict!["v6"] as? Double ?? 0.0
            
            return purple

            
        } catch {
            print(error)
            self.delegate?.didFailWithError(self, error: error)
            return nil
        }
    }
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    

    
}
