// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {DAOVoting} from "../src/DAOVoting.sol";

contract DAOVotingScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Get initial members from environment or use empty array
        string memory initialMembersStr = vm.envOr("INITIAL_MEMBERS", string(""));
        address[] memory initialMembers;

        if (bytes(initialMembersStr).length > 0) {
            // Split string manually since we can't use parseString
            bytes memory strBytes = bytes(initialMembersStr);
            uint256 count = 1;
            for (uint256 i = 0; i < strBytes.length; i++) {
                if (strBytes[i] == bytes1(",")) count++;
            }

            initialMembers = new address[](count);
            uint256 lastIndex = 0;
            uint256 currentIndex = 0;

            for (uint256 i = 0; i <= strBytes.length; i++) {
                if (i == strBytes.length || strBytes[i] == bytes1(",")) {
                    string memory addrStr;
                    if (i == strBytes.length) {
                        addrStr = substring(initialMembersStr, lastIndex, i - lastIndex);
                    } else {
                        addrStr = substring(initialMembersStr, lastIndex, i - lastIndex);
                        lastIndex = i + 1;
                    }
                    initialMembers[currentIndex] = vm.parseAddress(addrStr);
                    currentIndex++;
                }
            }
        } else {
            initialMembers = new address[](0);
        }

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the contract with initial members
        DAOVoting dao = new DAOVoting(initialMembers);

        // Stop broadcasting transactions
        vm.stopBroadcast();

        // Log the deployed contract address
        console2.log("DAOVoting deployed to:", address(dao));
    }

    // Helper function to get substring
    function substring(string memory str, uint256 startIndex, uint256 length) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(length);
        for (uint256 i = 0; i < length; i++) {
            result[i] = strBytes[startIndex + i];
        }
        return string(result);
    }
}
