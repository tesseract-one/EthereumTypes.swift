import XCTest

import EthereumTests

var tests = [XCTestCaseEntry]()
tests += EthereumTests.__allTests()

XCTMain(tests)
