//
//  LocationPickerMapView.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/22/24.
//

import MapKit
import os
import SwiftUI

struct LocationPickerMapView: UIViewRepresentable {
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @Environment(\.presentationMode) var presentationMode

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: LocationPickerMapView.self)
    )

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = context.coordinator

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        mapView.addGestureRecognizer(tapGesture)

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: LocationPickerMapView

        init(_ parent: LocationPickerMapView) {
            self.parent = parent
        }

        @objc func handleTap(gesture: UITapGestureRecognizer) {
            let mapView = gesture.view as! MKMapView
            let location = gesture.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)

            parent.selectedLocation = coordinate
            parent.logger.trace("[LocationPickerMapView] - Selected location: \(coordinate.latitude) \(coordinate.longitude)")

            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(annotation)
        }
    }
}
