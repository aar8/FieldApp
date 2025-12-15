import Foundation
import Insieme

protocol MetadataService {
    func getObjectMetadata(for objectName: String) -> ObjectMetadataRecord?
    func getLayoutDefinition(for objectName: String, type layoutType: String, status layoutStatus: String) -> LayoutDefinitionRecord?
}

class DefaultMetadataService: MetadataService {
    private let databaseService: DatabaseService
    
    init(databaseService: DatabaseService) {
        self.databaseService = databaseService
    }
    
    func getObjectMetadata(for objectName: String) -> ObjectMetadataRecord? {
        guard case .success(let metadata) = databaseService.fetchObjectMetadata() else {
            return nil
        }
        let x: [ObjectMetadataRecord] = metadata
        
        return x.first {
            $0.objectName == objectName
        }
    }
    
    func getLayoutDefinition(for objectName: String, type objectType: String, status layoutStatus: String) -> LayoutDefinitionRecord? {
        guard case .success(let layouts) = databaseService.fetchLayoutDefinitions() else {
            return nil
        }
        
        let bestMatch = layouts
            .filter {
                $0.objectName == objectName &&
                ($0.objectType == objectType || $0.objectType == "*") &&
                ($0.status == layoutStatus || $0.status == "*")
            }
            .map { layout -> (score: Int, layout: LayoutDefinitionRecord) in
                var score = 0
                if layout.objectType == objectType { score += 100 }
                if layout.status == layoutStatus { score += 1 }
                return (score, layout)
            }
            .max { $0.score < $1.score }

        return bestMatch?.layout
    }
}
