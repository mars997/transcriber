//
//  Category.swift
//  transcriber
//
//  Created by Hamed Ansari on 6/7/20.
//  Copyright © 2020 exoptima. All rights reserved.
//

import Foundation
import RealmSwift

class  Category: Object {
    @objc dynamic var title:String = ""
    let records = List<Record>()
}
