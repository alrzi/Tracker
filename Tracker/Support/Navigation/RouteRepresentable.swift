protocol RouteRepresentable {
    associatedtype Route: Hashable

    var route: Route { get }
}
