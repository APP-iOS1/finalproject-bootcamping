//
//  FullMapView.swift
//  BootCamping
//
//  Created by 이소영 on 2023/02/01.
//

import SwiftUI
import CoreLocation
import MapKit

struct FullMapView: View {
    
    @State var annotatedItem: [AnnotatedItem]
    @State var region: MKCoordinateRegion
    var campingSpot: CampingSpot
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $region, annotationItems: annotatedItem) { item in
                MapMarker(coordinate: item.coordinate, tint: .blue)
            }
        }
        .onAppear {
            region.center = CLLocationCoordinate2D(latitude: Double(campingSpot.mapY)!, longitude: Double(campingSpot.mapX)!)
        }
        .navigationTitle("\(campingSpot.facltNm)")
        .toolbar(.hidden, for: .tabBar)
    }
}
