# STX Reward Draw - Smart Contract README

## Overview

A decentralized Clarity smart contract implementing a monthly raffle system for open-source contributors on the Stacks blockchain. Contributors earn raffle entries for valid pull requests, with winners receiving STX rewards selected via block hash entropy.

## Features

- **Monthly Raffle Rounds** - Automated round-based participant management
- **Participant Registration** - Contributors register once per round with duplicate prevention
- **Random Winner Selection** - Uses block hash entropy for fair, verifiable randomness
- **Reward Claims** - Winners claim STX rewards on-demand
- **Role-Based Access** - Admin controls fund management and winner selection
- **Comprehensive Validation** - Error handling for all edge cases

## Contract Functions

### Public Functions

#### `register-entry`
Register the caller as a participant in the current raffle round.

**Returns:** `(ok index)` on success, error code on failure

**Errors:**
- `ERR_ALREADY_REGISTERED` - User already registered this round

#### `claim-reward (round uint)`
Claim STX reward for winning a specific raffle round.

**Parameters:**
- `round` - The raffle round number to claim from

**Returns:** `(ok "Reward claimed successfully")` on success

**Errors:**
- `ERR_NO_WINNER` - No winner declared for this round
- `ERR_NOT_WINNER` - Caller is not the round winner

### Read-Only Functions

- `get-current-round-id` - Returns current raffle round ID
- `get-participant-count` - Returns total participants in current round
- `is-registered (user principal)` - Check if user registered this round
- `get-winner (round uint)` - Get winner of specified round
- `get-reward-pool` - Get current reward pool amount in STX

## Error Codes

| Code | Name | Description |
|------|------|-------------|
| 100 | ERR_UNAUTHORIZED | Caller lacks required permissions |
| 101 | ERR_ROUND_NOT_ACTIVE | Round is not accepting entries |
| 102 | ERR_ALREADY_REGISTERED | User already registered this round |
| 103 | ERR_NO_PARTICIPANTS | No participants registered |
| 104 | ERR_NOT_WINNER | Caller is not the winner |
| 105 | ERR_ALREADY_DRAWN | Winner already drawn for round |
| 106 | ERR_NO_WINNER | No winner exists for round |

## Installation

```bash
cd stx-reward-draw
```

