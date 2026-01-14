// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

contract MerkelAirdrop is EIP712 {
    // Enable SafeERC20 functions (safeTransfer, safeTransferFrom) on all IERC20 tokens
    using SafeERC20 for IERC20;

    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address claimerAddress => bool claimed) private s_hasClaimed;

    event AirdropClaimed(address indexed account, uint256 amount);

    bytes32 private constant AIRDROP_CLAIM_TYPEHASH = keccak256("AirdropClaim(address account,uint256 amount)"); // EIP-712 type hash for claim signature

    struct AirdropClaim {
        address account; // Address claiming the airdrop
        uint256 amount; // Amount of tokens to claim
    }

    error MerkelAirdrop__InvalidProof();
    error MerkelAirdrop__AlreadyClaimed();
    error MerkelAirdrop__InvalidSignature();

    constructor(bytes32 _merkleRoot, IERC20 _airdropToken) EIP712("MerkelAirdrop", "1") {
        i_merkleRoot = _merkleRoot;
        i_airdropToken = _airdropToken;
    }

    /**
     * @notice Allows a user to claim their airdrop tokens by providing a valid Merkle proof
     * @param _account The address of the account claiming the airdrop
     * @param _amount The amount of tokens to claim
     * @param _merkleProof The Merkle proof array to verify the claim
     * @dev We use `calldata` instead of `memory` for `_merkleProof` because:
     *      - `calldata` is more gas-efficient as it reads directly from transaction calldata without copying to memory
     *      - Since we only need to read the proof (not modify it), `calldata` is the optimal choice
     *      - Using `memory` would require copying the entire array to memory, which incurs additional gas costs
     *      - `calldata` is read-only and perfect for external function parameters that are only read
     */
    function claim(address _account, uint256 _amount, bytes32[] calldata _merkleProof, uint8 _v, bytes32 _r, bytes32 _s)
        external
    {
        if (s_hasClaimed[_account]) {
            revert MerkelAirdrop__AlreadyClaimed();
        }

        /**
         * Verify the signature to ensure the claim is authorized by the account owner
         * @dev This prevents unauthorized claims by requiring cryptographic proof that
         *      the account owner has signed the claim request
         * @param _account The address making the claim
         * @param getMessageHash(_account, _amount) The EIP-712 typed data hash of the claim
         * @param _v, _r, _s ECDSA signature components from the account owner
         */
        if (!_isValidSignature(_account, getMessageHash(_account, _amount), _v, _r, _s)) {
            revert MerkelAirdrop__InvalidSignature();
        }

        /**
         * Create Merkle tree leaf node:
         * 1. abi.encode(_account,_amount) - encodes both values with type safety.
         *    We use abi.encode() instead of abi.encodePacked() because encodePacked()
         *    can cause hash collisions when dynamic types are involved.
         * 2. keccak256(abi.encode(...)) - first hash to create a clean leaf value
         * 3. bytes.concat(...) - properly concatenates the hash as bytes
         * 4. keccak256(bytes.concat(...)) - second hash prevents second-preimage attacks
         *    (where someone finds a different input that hashes to same value)
         */
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_account, _amount))));

        if (!MerkleProof.verify(_merkleProof, i_merkleRoot, leaf)) {
            revert MerkelAirdrop__InvalidProof();
        }

        s_hasClaimed[_account] = true;

        emit AirdropClaimed(_account, _amount);
        i_airdropToken.safeTransfer(_account, _amount);
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }

    /**
     * @notice Creates an EIP-712 typed data hash for the airdrop claim
     * @dev This function generates a standardized message hash that includes:
     *      - Domain separator (contract name, version, chain ID, contract address)
     *      - Structured claim data (account and amount)
     *      This ensures the signature is specific to this contract and prevents replay attacks
     * @param _account The address claiming the airdrop
     * @param _amount The amount of tokens being claimed
     * @return The EIP-712 compliant message hash to be signed
     */
    function getMessageHash(address _account, uint256 _amount) public view returns (bytes32) {
        return _hashTypedDataV4(
            keccak256(abi.encode(AIRDROP_CLAIM_TYPEHASH, AirdropClaim({account: _account, amount: _amount})))
        );
    }

    /**
     * @notice Verifies that the provided signature is valid for the given digest and signer
     * @dev Uses ECDSA signature recovery to extract the signer address from the signature
     *      and compares it against the expected account address
     * @param _account The expected signer address
     * @param _digest The message hash that was signed
     * @param _v, _r, _s The ECDSA signature components (v is recovery id, r and s are signature parts)
     * @return bool True if the signature is valid and matches the account, false otherwise
     */
    function _isValidSignature(address _account, bytes32 _digest, uint8 _v, bytes32 _r, bytes32 _s)
        internal
        pure
        returns (bool)
    {
        (address actualSigner,,) = ECDSA.tryRecover(_digest, _v, _r, _s);
        return actualSigner == _account;
    }
}
