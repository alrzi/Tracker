import Foundation
import TrackerDomain

enum TrackerFormFlowRoute: Hashable {
    case sections(selectedID: UUID?, token: UUID)
    case sectionEditor(section: TrackerSection?, token: UUID)
}
