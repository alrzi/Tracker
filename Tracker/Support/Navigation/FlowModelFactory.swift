@MainActor
protocol FlowModelFactory<RouteModel> {
    associatedtype RouteModel: RouteRepresentable

    func makeRouteModel(for route: RouteModel.Route) -> RouteModel
}
