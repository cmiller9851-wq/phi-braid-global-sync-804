# Phi Braid Global Sync #804

This repository contains the `EscrowWith804` Solidity contract.  
It implements an on-chain **#804 gate** that prevents funds from being released until a verified trigger condition (e.g., an Arweave anchor) is satisfied.

---

## Features

- Funds can only be released after the **#804 gate** is set to `true`.
- `owner` controls fund release.
- `multisig` controls the #804 gate toggle.
- Fully compatible with **Remix** and **Hardhat** for deployment.
- Emits on-chain events for transparency:
  - `Sync804Set(bool value, address caller)`
  - `Released(address recipient, uint256 amount)`

---

## Deployment (iPhone / Remix)

1. Open [https://remix.ethereum.org](https://remix.ethereum.org) in your browser.
2. Create a new file `EscrowWith804.sol` and paste the contract code from this repo.
3. Compile with **Solidity 0.8.19**.
4. Connect **MetaMask Mobile** (Sepolia testnet recommended).
5. Deploy with constructor arguments:
   - `_owner`: your wallet address
   - `_multisig`: your wallet (or multisig) address
6. Test functions:
   - `sync804()` → initially `false`
   - `setSync804(true)` → flips the gate
   - `release()` → succeeds only after the gate flips

---

## License

This project is licensed under the **Apache 2.0 License**.