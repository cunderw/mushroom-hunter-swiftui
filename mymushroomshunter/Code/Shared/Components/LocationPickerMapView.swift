//
//  LocationPickerMapView.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/22/24.
//

import MapKit
import SwiftUI

struct LocationPickerMapView: UIViewRepresentable {
    @Binding var selectedLocation: CLLocationCoordinate2D?
    var region: MKCoordinateRegion

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true

        let tapRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.mapTapped))
        mapView.addGestureRecognizer(tapRecognizer)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        if let selectedLocation = selectedLocation {
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedLocation
            uiView.removeAnnotations(uiView.annotations) // Remove existing annotations
            uiView.addAnnotation(annotation)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: LocationPickerMapView

        init(_ parent: LocationPickerMapView) {
            self.parent = parent
        }

        @objc func mapTapped(gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: gesture.view)
            if let mapView = gesture.view as? MKMapView {
                let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
                parent.selectedLocation = coordinate
            }
        }
    }
}
