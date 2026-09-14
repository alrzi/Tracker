enum TrackerFormFlowRouteModel: RouteRepresentable {
    case sections(route: TrackerFormFlowRoute, viewModel: SectionsListViewModel)
    case sectionEditor(route: TrackerFormFlowRoute, viewModel: SectionCreationViewModel)

    var route: TrackerFormFlowRoute {
        switch self {
        case .sections(let route, _), .sectionEditor(let route, _): route
        }
    }
}
