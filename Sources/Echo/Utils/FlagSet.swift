//
//  FlagSet.swift
//  Echo
//
//  Created by Alejandro Alonso on 8/15/19.
//

protocol FlagSet {
  associatedtype IntType: BinaryInteger
  
  var bits: IntType { get }
  
  func getField(at bit: IntType, bitWidth: IntType) -> IntType
  func getFlag(at bit: IntType) -> Bool
  func getLowMask(for bitWidth: IntType) -> IntType
  func getMask(for bit: IntType) -> IntType
}

extension FlagSet {
  func getField(at bit: IntType, bitWidth: IntType) -> IntType {
    (bits >> bit) & getLowMask(for: bitWidth)
  }
  
  func getFlag(at bit: IntType) -> Bool {
    bits & getMask(for: bit) != 0
  }
  
  func getLowMask(for bitWidth: IntType) -> IntType {
    (1 << bitWidth) - 1
  }
  
  func getMask(for bit: IntType) -> IntType {
    getLowMask(for: 1) << bit
  }
}
