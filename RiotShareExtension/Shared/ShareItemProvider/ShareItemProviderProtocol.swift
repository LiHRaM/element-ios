// 
// Copyright 2021 New Vector Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

@objc public enum ShareItemType: UInt {
    case fileURL, text, URL, image, video, movie, voiceMessage, unknown
}

@objc public protocol ShareItemProtocol {
    var type: ShareItemType { get }
}

@objc public protocol ShareItemProviderProtocol {
    var items: [ShareItemProtocol] { get }
    
    func areAllItemsImages() -> Bool
    
    func areAllItemsLoaded() -> Bool
    
    func loadItem(_ item: ShareItemProtocol, completion: @escaping (Any?, Error?) -> Void)
}
