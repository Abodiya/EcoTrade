# Carbon Credit Trading Platform

## Overview
The **Carbon Credit Trading Platform** is a smart contract that enables the non-custodial trading of carbon credits. It is designed to provide a transparent, decentralized, and efficient marketplace for carbon credit transactions, supporting the global effort to reduce carbon emissions. The platform allows the creation, minting, transfer, and trading of carbon credits while maintaining accountability through governance settings and secure liquidity pools.

---

## Features
1. **Create and Mint Carbon Credits**  
   - Carbon credits can be created with details like name, region, and initial supply.
   - Additional credits can be minted by the owner.

2. **Transfer Credits**  
   - Credits can be transferred between users while ensuring proper validations.

3. **Trading Mechanism**  
   - Users can create buy and sell orders for credits at desired prices.
   - Orders are executed seamlessly, ensuring balance and price checks.

4. **Liquidity Pools**  
   - Users can add or remove liquidity for specific credits to support price stability.
   - Dynamic pricing based on liquidity changes ensures fair market value.

5. **Governance Settings**  
   - Administrators can manage governance parameters to ensure smooth operations.

6. **Error Handling**  
   - Extensive validation and error messages for secure and robust functionality.

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Getting Started](#getting-started)
3. [Contract Functions](#contract-functions)
    - [Public Functions](#public-functions)
    - [Read-Only Functions](#read-only-functions)
    - [Private Functions](#private-functions)
4. [Governance](#governance)
5. [Technical Details](#technical-details)
6. [Contribution](#contribution)
7. [License](#license)

---

## Prerequisites
- **Stacks Blockchain**: Ensure you have access to the Stacks blockchain and development tools.
- **Clarity Language Knowledge**: This contract is written in the Clarity language.
- **Stacks CLI**: Install the Stacks Command Line Interface for deployment and testing.

---

## Getting Started
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/carbon-credit-platform.git
   cd carbon-credit-platform
   ```
2. Install dependencies (if any):
   ```bash
   npm install
   ```
3. Deploy the contract:
   ```bash
   stacks-cli deploy contract-path
   ```
4. Interact with the contract using:
   - Stacks CLI
   - Frontend interface (if provided)

---

## Contract Functions

### Public Functions

1. **`create-credit`**  
   - Creates a new carbon credit with a name, region, and initial supply.  
   - **Parameters**:  
     - `name (string-ascii 32)`: Name of the credit.  
     - `region (string-ascii 10)`: Region for the credit.  
     - `initial-supply (uint)`: Initial supply of credits.  
   - **Returns**: New credit ID.  

2. **`mint-credits`**  
   - Mints additional supply for an existing credit.  
   - **Parameters**:  
     - `credit-id (uint)`: ID of the credit to mint.  
     - `amount (uint)`: Number of credits to mint.  
   - **Returns**: Confirmation of success.  

3. **`transfer`**  
   - Transfers credits between users.  
   - **Parameters**:  
     - `credit-id (uint)`: ID of the credit.  
     - `amount (uint)`: Number of credits to transfer.  
     - `sender (principal)`: Sender's address.  
     - `recipient (principal)`: Recipient's address.  
   - **Returns**: Confirmation of success.  

4. **`create-sell-order`**  
   - Creates a sell order for specific credits.  
   - **Parameters**:  
     - `credit-id (uint)`: ID of the credit.  
     - `amount (uint)`: Number of credits to sell.  
     - `price (uint)`: Price per credit.  
   - **Returns**: Order ID.  

5. **`create-buy-order`**  
   - Creates a buy order for specific credits.  
   - **Parameters**:  
     - `credit-id (uint)`: ID of the credit.  
     - `amount (uint)`: Number of credits to buy.  
     - `price (uint)`: Price per credit.  
   - **Returns**: Order ID.  

6. **`execute-order`**  
   - Executes a buy or sell order.  
   - **Parameters**:  
     - `order-id (uint)`: ID of the order to execute.  
   - **Returns**: Confirmation of success.  

7. **`add-liquidity`**  
   - Adds liquidity to a credit pool to stabilize its price.  
   - **Parameters**:  
     - `credit-id (uint)`: ID of the credit.  
     - `amount (uint)`: Liquidity amount.  
   - **Returns**: Confirmation of success.  

8. **`remove-liquidity`**  
   - Removes liquidity from a credit pool.  
   - **Parameters**:  
     - `credit-id (uint)`: ID of the credit.  
     - `amount (uint)`: Liquidity amount.  
   - **Returns**: Confirmation of success.  

---

### Read-Only Functions
1. **`get-credit-details`**  
   - Fetches details of a specific credit.  

2. **`get-balance`**  
   - Retrieves a user's balance for a specific credit.  

3. **`get-order`**  
   - Fetches details of a specific order.  

4. **`get-credit-pool`**  
   - Retrieves the liquidity pool details of a specific credit.  

---

### Private Functions
- **Validation Functions**:  
  Handle input validation, including string, region, and ID checks.  
- **Order Execution**:  
  Executes buy or sell orders, including credit transfer and payment.  
- **Price Calculation**:  
  Dynamically calculates price changes based on liquidity pool changes.  

---

## Governance
- Governance settings are managed through the `governance-settings` map.
- Admins can update these settings to adjust platform parameters.

---

## Technical Details
- **Language**: Clarity  
- **Key Maps**:  
  - `credits`: Stores credit details.  
  - `balances`: Tracks user balances.  
  - `orders`: Manages buy/sell orders.  
  - `credit-pools`: Manages liquidity pools for pricing stability.  

- **Error Handling**:  
  Uses custom error codes for secure and informative error management.

---

## Contribution
1. Fork the repository.  
2. Create a new branch for your feature.  
3. Commit your changes.  
4. Open a pull request with detailed information.  

