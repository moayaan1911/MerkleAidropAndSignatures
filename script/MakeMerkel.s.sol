// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {console} from "forge-std/console.sol";
import {Merkle} from "murky/src/Merkle.sol"; // Murky library for Merkle tree operations
import {ScriptHelper} from "murky/script/common/ScriptHelper.sol"; // Helper functions for string/bytes conversions

/**
 * @title MakeMerkle
 * @author moayaan.eth (modified from Cyfrin/Murky template)
 * @notice Generates Merkle root and proofs from input JSON file for airdrop claims
 * @dev Takes input.json and creates output.json with Merkle proofs for each whitelisted address
 *
 * Usage Flow:
 * 1. Run `forge script script/GenerateInput.s.sol` to generate input.json with whitelist
 * 2. Run `forge script script/MakeMerkel.s.sol` to generate Merkle proofs and root
 * 3. Output file in /script/target/output.json contains proofs needed for claiming
 */

/**
 * @title MakeMerkle
 * @author moayaan.eth (adapted from Cyfrin/Murky template)
 *
 * Original Work by:
 * @author Ciara Nightingale
 * @author Cyfrin
 * @author kootsZhin
 * @notice https://github.com/dmfxyz/murky
 */
contract MakeMerkle is Script, ScriptHelper {
    // Enable JSON parsing functions on strings (readUint, readAddress, etc.)
    using stdJson for string;

    // Murky library instance for all Merkle tree operations (generate proofs, get root)
    Merkle private m = new Merkle();

    // File paths for input (whitelist data) and output (Merkle proofs)
    string private inputPath = "/script/target/input.json";
    string private outputPath = "/script/target/output.json";

    // Read the entire input JSON file as a string
    string private elements = vm.readFile(string.concat(vm.projectRoot(), inputPath));

    // Extract data types from JSON (should be ["address", "uint"])
    string[] private types = elements.readStringArray(".types");

    // Extract number of whitelist entries from JSON
    uint256 private count = elements.readUint(".count");

    // Storage for Merkle tree leaf hashes (one per whitelist entry)
    bytes32[] private leafs = new bytes32[](count);

    // Storage for input values as strings (for JSON output)
    string[] private inputs = new string[](count);

    // Storage for complete JSON entries (proofs, root, leaf for each entry)
    string[] private outputs = new string[](count);

    // Final JSON output string that gets written to file
    string private output;

    /**
     * @dev Returns JSON path to access values in input.json structure
     * @param i Index of the whitelist entry (0, 1, 2, 3...)
     * @param j Field index (0 = address, 1 = amount)
     * @return JSON path like ".values.0.0" or ".values.1.1"
     *
     * JSON Structure Access:
     * .values.0.0 -> first entry's address
     * .values.0.1 -> first entry's amount
     * .values.1.0 -> second entry's address
     */
    function getValuesByIndex(uint256 i, uint256 j) internal pure returns (string memory) {
        return string.concat(".values.", vm.toString(i), ".", vm.toString(j));
    }

    /**
     * @dev Creates JSON entry for each whitelist address with all claim data
     * @param _inputs Original input values [address, amount] as JSON array string
     * @param _proof Merkle proof as JSON array string
     * @param _root Merkle root hash as hex string
     * @param _leaf Leaf hash as hex string
     * @return Complete JSON object string for this entry
     *
     * Output JSON Structure:
     * {
     *   "inputs": ["0x123...", "25000000000000000000"],  // [address, amount]
     *   "proof": ["0xabcd...", "0xefgh..."],               // Merkle proof array
     *   "root": "0x1234...",                              // Merkle root
     *   "leaf": "0x5678..."                               // Leaf hash
     * }
     */
    function generateJsonEntries(string memory _inputs, string memory _proof, string memory _root, string memory _leaf)
        internal
        pure
        returns (string memory)
    {
        string memory result = string.concat(
            "{",
            "\"inputs\":",
            _inputs,
            ",",
            "\"proof\":",
            _proof,
            ",",
            "\"root\":\"",
            _root,
            "\",",
            "\"leaf\":\"",
            _leaf,
            "\"",
            "}"
        );

        return result;
    }

    /**
     * @dev Main function that processes input.json and generates output.json with Merkle proofs
     * @notice Reads whitelist data, generates Merkle tree, creates proofs for each address
     *
     * Process Overview:
     * 1. Loop through each whitelist entry, convert to bytes32, hash to create leaves
     * 2. Generate Merkle proofs and root for each leaf
     * 3. Create JSON output with all claim data
     * 4. Write complete output.json file
     */
    function run() public {
        console.log("Generating Merkle Proof for %s", inputPath);

        // FIRST LOOP: Process each whitelist entry and create Merkle leaves
        for (uint256 i = 0; i < count; ++i) {
            // Temporary arrays to hold data for this entry (address + amount)
            string[] memory input = new string[](types.length); // String versions for JSON output
            bytes32[] memory data = new bytes32[](types.length); // Bytes32 versions for hashing

            // Convert each field (address, amount) from JSON to proper types
            for (uint256 j = 0; j < types.length; ++j) {
                if (compareStrings(types[j], "address")) {
                    // Read address from JSON and convert to bytes32
                    address value = elements.readAddress(getValuesByIndex(i, j));
                    // Address (20 bytes) -> uint160 -> uint256 -> bytes32 (32 bytes)
                    data[j] = bytes32(uint256(uint160(value)));
                    input[j] = vm.toString(value); // String version for JSON
                } else if (compareStrings(types[j], "uint")) {
                    // Read amount from JSON and convert to bytes32
                    uint256 value = vm.parseUint(elements.readString(getValuesByIndex(i, j)));
                    data[j] = bytes32(value);
                    input[j] = vm.toString(value); // String version for JSON
                }
            }
            /**
             * Create Merkle leaf hash using same logic as airdrop contract:
             * 1. abi.encode(data) - encode address and amount as bytes32 array
             * 2. ltrim64() - remove offset/length prefix from memory array encoding
             * 3. keccak256() - first hash of the encoded data
             * 4. bytes.concat() - convert to bytes (removes padding issues)
             * 5. keccak256() - second hash to prevent preimage attacks
             */
            leafs[i] = keccak256(bytes.concat(keccak256(ltrim64(abi.encode(data)))));

            // Store string representation of inputs for JSON output
            inputs[i] = stringArrayToString(input);
        }

        // SECOND LOOP: Generate Merkle proofs for each leaf
        for (uint256 i = 0; i < count; ++i) {
            // Get Merkle proof for this leaf (array of sibling hashes needed for verification)
            string memory proof = bytes32ArrayToString(m.getProof(leafs, i));

            // Get the Merkle root (same for all entries in this tree)
            string memory root = vm.toString(m.getRoot(leafs));

            // Get this leaf's hash as string
            string memory leaf = vm.toString(leafs[i]);

            // Get the original input values [address, amount] as string
            string memory input = inputs[i];

            // Create complete JSON entry with all data needed for claiming
            outputs[i] = generateJsonEntries(input, proof, root, leaf);
        }

        // Convert array of JSON entries into single JSON array string
        output = stringArrayToArrayString(outputs);

        // Write the complete output JSON to file - this contains everything needed for claims!
        vm.writeFile(string.concat(vm.projectRoot(), outputPath), output);

        console.log("DONE: The output is found at %s", outputPath);
    }
}
