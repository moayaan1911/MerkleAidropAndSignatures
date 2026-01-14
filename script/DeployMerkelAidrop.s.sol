// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {MerkelAirdrop} from "src/MerkelAirdrop.sol";
import {BagelToken} from "src/BagelToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title DeployMerkelAirdrop
 * @author moayaan.eth
 * @notice Deployment script: deploys BagelToken and MerkelAirdrop, then funds airdrop with tokens
 */
// Deployment script: deploys BagelToken and MerkelAirdrop, then funds airdrop with tokens
contract DeployMerkelAirdrop is Script {
    bytes32 private s_merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 private s_amountToMint = (25 * 1e18) * 4;

    function deployMerkelAirdrop() public returns (MerkelAirdrop, BagelToken) {
        vm.startBroadcast();
        BagelToken bagelToken = new BagelToken();
        MerkelAirdrop merkelAirdrop = new MerkelAirdrop(s_merkleRoot, IERC20(address(bagelToken)));
        bagelToken.mint(bagelToken.owner(), s_amountToMint);
        bagelToken.transfer(address(merkelAirdrop), s_amountToMint);
        vm.stopBroadcast();
        console.log("MerkelAirdrop deployed to: ", address(merkelAirdrop));
        console.log("BagelToken deployed to: ", address(bagelToken));
        return (merkelAirdrop, bagelToken);
    }

    // Entry point for forge script
    function run() external returns (MerkelAirdrop, BagelToken) {
        return deployMerkelAirdrop();
    }
}
