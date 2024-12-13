// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// @title Counter
/// @notice A simple counter contract for demonstration purposes
contract Counter {
    uint256 public number;

    /// @notice Sets the counter to a new number
    /// @param newNumber The value to set the counter to
    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    /// @notice Increments the counter by 1
    function increment() public {
        number++;
    }
}
