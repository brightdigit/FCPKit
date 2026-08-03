internal struct TestCodingKey: CodingKey {
  internal let stringValue: String
  internal let intValue: Int? = nil

  internal init(_ stringValue: String) {
    self.stringValue = stringValue
  }

  internal init?(stringValue: String) {
    self.init(stringValue)
  }

  internal init?(intValue: Int) {
    nil
  }
}
