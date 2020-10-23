//
//  Results.swift
//  Movies
//
//  Created by Anuj Pande on 22/10/20.
//

import Foundation

struct Results {
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    init() {
        self.data = nil
        self.response = nil
        self.error = nil
    }
    
    init(withData data: Data?, response: URLResponse?, error: Error?) {
        self.data = data
        self.response = response
        self.error = error
    }
 
    init(withError error: Error) {
        self.error = error
    }
}
