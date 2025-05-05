# JokenPoll - Rock Paper Scissors Voting Game

JokenPoll is a decentralized rock-paper-scissors game implemented on the Ethereum blockchain. It allows two teams to vote on their choice (rock, paper, or scissors), and then compares the results to determine the winner.

## How it Works

1. Two teams (A and B) vote for rock, paper, or scissors.
2. After voting is complete, the most voted option from each team is selected.
3. If there's a tie within a team, one of the options is randomly selected.
4. The two team choices compete, and a winner is determined according to traditional rock-paper-scissors rules.

## Smart Contracts

The project consists of three main contracts:

1. `TeamAVoting.sol` - Handles the voting for Team A
2. `TeamBVoting.sol` - Handles the voting for Team B
3. `JokenPoll.sol` - Coordinates the game and determines the winner

## Getting Started

### Prerequisites

- [Remix IDE](https://remix.ethereum.org/)
- [MetaMask](https://metamask.io/) or any Ethereum wallet
- A browser with Web3 support

### Deployment Steps

1. Open Remix IDE (https://remix.ethereum.org/)
2. Create three new files and copy the content from:
   - `TeamAVoting.sol`
   - `TeamBVoting.sol`
   - `JokenPoll.sol`
3. Compile the contracts using Solidity Compiler (v0.8.0 or higher)
4. Deploy the JokenPoll contract on the JavaScript VM for testing
   - Note: The JokenPoll contract will automatically deploy the TeamA and TeamB contracts
5. After deployment, you'll get the address of the JokenPoll contract
6. Use the JokenPoll contract's functions to get the addresses for TeamA and TeamB contracts
7. Update the contract addresses in the `index.html` file
8. Export the ABIs from Remix and add them to the corresponding variables in `index.html`
9. Open the `index.html` file in your browser to start playing

## Using the Web Interface

1. Connect to MetaMask by clicking the "Connect to MetaMask" button
2. Vote for your choice (Rock, Paper, or Scissors) with your team
3. End the voting for your team when all votes are cast
4. End the game to determine the winner
5. Reset the game to play another round

## Notes for Simulation

This project is designed as a simulation, so it doesn't require any real ETH to test:

- When running in Remix's JavaScript VM, no real transactions are made
- For local deployment, you can use Ganache or Hardhat
- For testnet deployment, use Sepolia or Goerli test networks with test ETH

## Game Logic

- Each voter (address) can only vote once per round
- The most upvoted choice from each team is selected
- In case of a tie, a random choice is made using blockchain data
- Traditional rock-paper-scissors rules apply:
  - Rock beats Scissors
  - Paper beats Rock
  - Scissors beats Paper

## Future Improvements

- Add timer-based voting periods
- Implement rewards for participants of the winning team
- Create more advanced game mechanics (e.g., rock-paper-scissors-lizard-spock)
- Add user authentication and profiles 