//
//  OrderListViewModel.swift
//  ShoB
//
//  Created by Dara Beng on 8/4/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


class OrderListViewModel: ObservableObject {
    
    @Published var currentSegment = OrderListView.Segment.today
    
    let segmentOptions: [OrderListView.Segment] = [.today, .tomorrow, .past7Days]
}
