import Foundation

// MARK: - Substrings

extension String {
    
    func substring(to: Int) -> String {
        guard count > to else { return self }
        
        let toIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[...toIndex])
    }
    
    func substring(from: Int) -> String {
        guard count > from else { return "" }
        
        let fromIndex = self.index(self.startIndex, offsetBy: from)
        return String(self[fromIndex...])
    }
    
    func substring(from: Int, to: Int) -> String {
        guard count > to else { return self }
        guard count > from else { return "" }
        
        let toIndex = self.index(self.startIndex, offsetBy: to)
        let fromIndex = self.index(self.startIndex, offsetBy: from)
        return String(self[fromIndex...toIndex])
    }
}
