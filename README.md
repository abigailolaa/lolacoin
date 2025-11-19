# lolacoin

A simple fungible token smart contract built with [Clarinet](https://github.com/hirosystems/clarinet) for the Stacks blockchain.

## Project structure

- `Clarinet.toml` – Clarinet project configuration
- `contracts/lolacoin.clar` – main lolacoin token contract (Clarity)
- `settings/*.toml` – network configuration (Devnet, Testnet, Mainnet)
- `tests/lolacoin.test.ts` – placeholder for TypeScript tests
- `package.json`, `tsconfig.json`, `vitest.config.ts` – JS tooling for tests

## Contract overview

The `lolacoin` contract implements a basic fungible token with:

- One-time initialization via `initialize` to set the owner and mint an initial supply
- Owner-only `mint` function to create new tokens
- `transfer` function to move tokens between principals
- Read-only helpers:
  - `get-name`
  - `get-symbol`
  - `get-decimals`
  - `get-total-supply`
  - `get-balance`

### Key data

- `total-supply` – running total of all minted lolacoin tokens
- `owner` – optional principal who is allowed to mint after initialization
- `balances` – map from principal to token balance

### Error codes

- `u100` – caller is not the owner
- `u101` – insufficient balance for transfer
- `u102` – contract already initialized
- `u103` – amount must be greater than zero

## Requirements

- Node.js (for running tests via npm)
- [Clarinet](https://docs.hiro.so/clarinet/install-clarinet) CLI (already installed)

## Usage

From the project root (`lolacoin` directory):

1. **Check contract syntax**

   ```bash path=null start=null
   clarinet check
   ```

2. **Initialize the token** (example)

   In the Clarinet console or via a transaction, call:

   ```clarity path=null start=null
   (contract-call? .lolacoin initialize tx-sender u1000000)
   ```

   This sets the caller as the owner and mints `1_000_000` lolacoin to `tx-sender`.

3. **Transfer tokens**

   ```clarity path=null start=null
   (contract-call? .lolacoin transfer u100 'ST3J2GVMMM2R07ZFBJDWTYEYAR8AB30E2V7ZTHW16)
   ```

4. **Mint additional tokens (owner only)**

   ```clarity path=null start=null
   (contract-call? .lolacoin mint 'ST3J2GVMMM2R07ZFBJDWTYEYAR8AB30E2V7ZTHW16 u500)
   ```

5. **Query balances and supply**

   ```clarity path=null start=null
   (contract-call? .lolacoin get-balance 'ST3J2GVMMM2R07ZFBJDWTYEYAR8AB30E2V7ZTHW16)
   (contract-call? .lolacoin get-total-supply)
   ```

## Running checks and tests

### Static checks

From the project root:

```bash path=null start=null
clarinet check
```

### Tests (optional)

To run the generated TypeScript tests:

```bash path=null start=null
npm install
npm test
```

You can extend `tests/lolacoin.test.ts` with scenarios that cover initialization,
transfers, minting, and error conditions.
