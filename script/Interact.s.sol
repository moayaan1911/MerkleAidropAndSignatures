// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkelAirdrop} from "../src/MerkelAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";

/**
 * @title ClaimAirdrop
 * @author moayaan.eth
 * @notice Interactive script to claim BagelToken airdrop from deployed MerkelAirdrop contract
 * @dev Claims airdrop tokens using Merkle proof and signature verification
 *
 * Usage Flow:
 * 1. Deploy MerkelAirdrop contract using DeployMerkelAidrop.s.sol
 * 2. Generate Merkle proofs using MakeMerkel.s.sol
 * 3. Run this script to claim tokens for whitelisted address
 * 4. Verify claim was successful by checking token balance
 */
contract ClaimAirdrop is Script {
    // Address claiming the airdrop (first anvil address by default)
    address public CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    // Amount of BagelTokens to claim (25 tokens with 18 decimals)
    uint256 public CLAIMING_AMOUNT = 25 * 1e18;

    // Merkle proof components extracted from output.json for the claiming address
    bytes32 proof1 = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 proof2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;

    // Complete Merkle proof array needed for claim verification
    bytes32[] MERKLE_PROOF = [proof1, proof2];

    // Custom error for signature validation
    error InteractScript__InvalidSignatureLength();

    /**
     * @dev Main entry point - finds most recent MerkelAirdrop deployment and claims tokens
     * @notice Automatically detects the latest deployed contract on current network
     */
    function run() external {
        // Get the most recently deployed MerkelAirdrop contract address for current chain
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkelAirdrop", block.chainid);
        claimAirdrop(mostRecentlyDeployed);
    }

    // Pre-signed message signature for claim verification (created off-chain)
    // Format: r (32 bytes) + s (32 bytes) + v (1 byte) = 65 bytes total
    bytes private SIGNATURE =
        hex"f5a9bd6cd964ddd38d1f86c4c2352c87563f75b22120c47b1336c98542956e03630e5a6181ba9b5fb7c203b543f1c9dbe0a6169e93c06977881c675c3b58aa071c";

    /**
     * @dev Claims airdrop tokens using Merkle proof and signature verification
     * @param _merkelAirdrop Address of the deployed MerkelAirdrop contract
     * @notice Broadcasts transaction to claim tokens for CLAIMING_ADDRESS
     *
     * Claim Process:
     * 1. Split signature into v, r, s components
     * 2. Log claim details for debugging
     * 3. Call claim() on MerkelAirdrop contract with proof and signature
     */
    function claimAirdrop(address _merkelAirdrop) public {
        vm.startBroadcast();

        // Split the 65-byte signature into its components (v, r, s)
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);

        // Log claim parameters for debugging and verification
        console.log("Claiming address:", CLAIMING_ADDRESS);
        console.log("Claiming amount:", CLAIMING_AMOUNT);
        console.log("v:", v);
        console.logBytes32(r);
        console.logBytes32(s);

        // Execute the claim transaction on the MerkelAirdrop contract
        MerkelAirdrop(_merkelAirdrop).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, MERKLE_PROOF, v, r, s);

        vm.stopBroadcast();
    }

    /**
     * @dev Splits a 65-byte Ethereum signature into its v, r, s components
     * @param sig The raw 65-byte signature (r: 32 bytes + s: 32 bytes + v: 1 byte)
     * @return v Recovery id (0 or 1 for Ethereum signatures)
     * @return r First 32 bytes of signature
     * @return s Second 32 bytes of signature
     * @notice Uses assembly for efficient byte manipulation
     *
     * Signature Structure:
     * [0:32]  - r value (32 bytes)
     * [32:64] - s value (32 bytes)
     * [64:65] - v value (1 byte, usually 27 or 28)
     */
    function splitSignature(bytes memory sig) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        // Validate signature length (must be exactly 65 bytes for Ethereum signatures)
        if (sig.length != 65) {
            revert InteractScript__InvalidSignatureLength();
        }

        // Use inline assembly to efficiently extract signature components
        // Memory layout: sig[0] = length, sig[32] = r, sig[64] = s, sig[96] = v
        assembly {
            r := mload(add(sig, 32))    // Load r from bytes 0-31 (after length prefix)
            s := mload(add(sig, 64))    // Load s from bytes 32-63
            v := byte(0, mload(add(sig, 96)))  // Load v from byte 64 (first byte of word at position 96)
        }
    }
}
