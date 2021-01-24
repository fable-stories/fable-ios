public protocol AutoEquatable {}
public protocol AutoHashable {}

// Model
public protocol ModelObject: Codable {}
public protocol EquatableModel {}
public protocol HashableModel {}
public protocol WireableModel {}

// Mutable Model
public protocol MutableModelObject: Codable {}
public protocol EquatableMutableModel {}
public protocol HashableMutableModel {}
public protocol WireableMutableModel {}

// Wire
public protocol WireObject {}
public protocol EquatableWire {}
public protocol HashableWire {}
public protocol InitializableWireObject {}

