// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Escrow with immutable #804 gate
/// @notice Release of funds is blocked until the Arweave anchor is verified on-chain.
contract EscrowWith804 {
    // State variables
    address public immutable owner;      // contract deployer / admin
    address public immutable multisig;   // multisig or trusted oracle
    bool public sync804;                 // gate flag

    // Events
    event Sync804Set(bool indexed value, address indexed caller);
    event Released(address indexed recipient, uint256 amount);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "owner only");
        _;
    }

    modifier onlyMultisig() {
        require(msg.sender == multisig, "multisig only");
        _;
    }

    // Constructor
    constructor(address _owner, address _multisig) {
        require(_owner != address(0), "owner zero");
        require(_multisig != address(0), "multisig zero");
        owner = _owner;
        multisig = _multisig;
        sync804 = false; // initially locked
    }

    // Gate management
    /// @notice Called by the multisig (or trusted oracle) after verifying Arweave TX
    function setSync804(bool v) external onlyMultisig {
        sync804 = v;
        emit Sync804Set(v, msg.sender);
    }

    // Release logic
    /// @notice Sends the entire contract balance to `recipient` once the gate is open
    function release(address payable recipient) external onlyOwner {
        require(sync804, "PHI-BRAID #804 not satisfied");
        uint256 bal = address(this).balance;
        require(bal > 0, "no balance");
        (bool ok, ) = recipient.call{value: bal}("");
        require(ok, "transfer failed");
        emit Released(recipient, bal);
    }

    // Allow contract to receive ETH
    receive() external payable {}
}