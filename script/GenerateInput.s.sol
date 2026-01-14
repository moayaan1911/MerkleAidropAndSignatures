// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {console} from "forge-std/console.sol";

/**
 * @title GenerateInput
 * @author moayaan.eth
 * @notice Generates JSON input file for Merkle tree airdrop
 * @dev Creates input.json with whitelisted addresses and their token allocations
 *      This file is used to generate the Merkle root and proofs for the airdrop contract
 */
contract GenerateInput is Script {
    // Amount each whitelisted address will receive (25 tokens with 18 decimals)
    uint256 private constant AMOUNT = 25 * 1e18;

    // JSON schema types for the Merkle tree input: [address _account, uint256 _amount]
    string[] types = new string[](2);

    // Number of whitelisted addresses
    uint256 count;

    // Array of whitelisted addresses that can claim the airdrop
    string[] whitelist = new string[](4);

    // Path where the generated JSON file will be saved
    string private constant INPUT_PATH = "/script/target/input.json";

    /**
     * @notice Main function that generates the Merkle tree input JSON file
     * @dev Sets up the whitelist addresses and creates the JSON structure
     */
    function run() public {
        // Define the data types for Merkle tree leaves: address and uint256
        types[0] = "address";
        types[1] = "uint";

        // Whitelist of addresses eligible for the airdrop
        whitelist[0] = "0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D";
        whitelist[1] = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
        whitelist[2] = "0x2ea3970Ed82D5b30be821FAAD4a731D35964F7dd";
        whitelist[3] = "0xf6dBa02C01AF48Cf926579F77C9f874Ca640D91D";

        // Store the count of whitelisted addresses
        count = whitelist.length;

        // Generate the JSON string with all whitelist data
        string memory input = _createJSON();

        // Write the JSON to file in the project directory
        vm.writeFile(string.concat(vm.projectRoot(), INPUT_PATH), input);

        // Log completion message with file path
        console.log("DONE: The output is found at %s", INPUT_PATH);
    }

    /**
     * @notice Creates the JSON structure for Merkle tree input
     * @dev Builds JSON manually using string concatenation since Solidity doesn't have built-in JSON
     * @return The complete JSON string with types, count, and all whitelist data
     *
     * JSON Structure:
     * {
     *   "types": ["address", "uint"],           // Data types for Merkle leaves
     *   "count": 4,                             // Number of whitelist entries
     *   "values": {                             // The actual data entries
     *     "0": {"0": "address1", "1": "amount"}, // Index -> {address_index: address, amount_index: amount}
     *     "1": {"0": "address2", "1": "amount"},
     *     ...
     *   }
     * }
     */
    function _createJSON() internal view returns (string memory) {
        // Convert numbers to strings for JSON
        string memory countString = vm.toString(count);
        string memory amountString = vm.toString(AMOUNT);

        // Start building JSON: types array, count, and opening values object
        string memory json = string.concat('{ "types": ["address", "uint"], "count":', countString, ',"values": {');

        // Loop through each whitelisted address and add to JSON
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (i == whitelist.length - 1) {
                // Last entry: no comma after closing brace
                json = string.concat(
                    json,
                    '"',
                    vm.toString(i),
                    '"',
                    ': { "0":',
                    '"',
                    whitelist[i],
                    '"',
                    ', "1":',
                    '"',
                    amountString,
                    '"',
                    " }"
                );
            } else {
                // Not last entry: add comma after closing brace
                json = string.concat(
                    json,
                    '"',
                    vm.toString(i),
                    '"',
                    ': { "0":',
                    '"',
                    whitelist[i],
                    '"',
                    ', "1":',
                    '"',
                    amountString,
                    '"',
                    " },"
                );
            }
        }

        // Close the values object and root object
        json = string.concat(json, "} }");

        return json;
    }
}
