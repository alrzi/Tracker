@MainActor
protocol FlowNavigating: AnyObject {
    associatedtype RouteModel: RouteRepresentable

    var navigationStore: NavigationModelStore<RouteModel> { get }
}

extension FlowNavigating {
    var navigationPath: [RouteModel.Route] {
        get { navigationStore.path }
        set { navigationStore.path = newValue }
    }

    func model(for route: RouteModel.Route) -> RouteModel? {
        navigationStore.value(for: route)
    }

    func push(_ routeModel: RouteModel) {
        navigationStore.push(routeModel)
    }

    func popLastRoute() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }

    func resetNavigation() {
        navigationStore.reset()
    }
}
