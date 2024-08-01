# Foundry Smart Contract

This repository contains the Foundry smart contract, a Solidity-based system for user registration, daily check-ins, XP point management, and booster purchases.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Contract Details](#contract-details)
- [Usage](#usage)
- [Owner Functions](#owner-functions)
- [Security](#security)
- [License](#license)

## Overview

The Foundry contract implements a gamified system where users can register, perform daily check-ins to earn XP points, purchase boosters to increase their XP earnings, and convert their XP points to ETH.

## Features

- User registration
- Daily check-ins with increasing rewards for consecutive days
- Booster system to multiply XP earnings
- XP to ETH conversion
- Owner-controlled pricing and conversion rates

## Contract Details

- Solidity Version: ^0.8.16
- License: MIT

## Usage

### User Functions

1. **Register User**
   ```solidity
   function registerUser() public
   ```
   Registers a new user in the system.

2. **Daily Check-in**
   ```solidity
   function dailyCheckIn() public
   ```
   Allows users to check in daily and earn XP points.

3. **Purchase Booster**
   ```solidity
   function purchaseBooster(uint256 plan) public payable
   ```
   Enables users to purchase a booster plan to increase XP earnings.

4. **Withdraw XP**
   ```solidity
   function withdrawXP() public
   ```
   Converts user's XP points to ETH and transfers it to their account.

5. **Fetch User Info**
   ```solidity
   function fetchUserInfo(address _address) public view returns(User memory)
   ```
   Retrieves user information for a given address.

### Owner Functions

1. **Change Booster Prices**
   ```solidity
   function changeBoosterPrices(uint256[5] memory newPrices) public onlyOwner
   ```

2. **Change XP Conversion Rate**
   ```solidity
   function changeXpConversionRate(uint256 newRate) public onlyOwner
   ```

3. **Deposit ETH**
   ```solidity
   function depositNZT() public payable onlyOwner
   ```

4. **Withdraw ETH**
   ```solidity
   function withdrawNZT(uint256 amount) public onlyOwner
   ```

## Security

- The contract uses `onlyOwner` modifier to restrict access to sensitive functions.
- Booster duration is set to 28 days and is checked before application.
- Proper checks are implemented to prevent reentrancy and other common vulnerabilities.

## License

This project is licensed under the MIT License.
