import Observation

@MainActor
@Observable
final class NavigationModelStore<Value: RouteRepresentable> {
    var path: [Value.Route] = [] {
        didSet {
            let activeRoutes = Set(path)
            values = values.filter { activeRoutes.contains($0.key) }
        }
    }

    private var values: [Value.Route: Value] = [:]

    func value(for route: Value.Route) -> Value? {
        values[route]
    }

    func replacePath(with models: [Value]) {
        values = Dictionary(uniqueKeysWithValues: models.map { ($0.route, $0) })
        path = models.map(\.route)
    }

    func push(_ value: Value) {
        values[value.route] = value
        path.append(value.route)
    }

    func reset() {
        path = []
    }
}
