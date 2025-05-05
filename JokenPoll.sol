// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TeamAVoting.sol";
import "./TeamBVoting.sol";

contract JokenPoll {
    // Enum for the winner
    enum Winner { NONE, TEAM_A, TEAM_B, TIE }
    
    // Game state
    TeamAVoting public teamA;
    TeamBVoting public teamB;
    Winner public winner;
    bool public gameEnded;
    uint public totalGamesPlayed;
    uint public teamAWins;
    uint public teamBWins;
    uint public ties;
    
    // Event declarations
    event GameStarted(address teamAContract, address teamBContract);
    event GameEnded(Winner winner);
    
    // Constructor
    constructor() {
        teamA = new TeamAVoting();
        teamB = new TeamBVoting();
        gameEnded = false;
        totalGamesPlayed = 0;
        teamAWins = 0;
        teamBWins = 0;
        ties = 0;
        
        emit GameStarted(address(teamA), address(teamB));
    }
    
    // Function to end the game and determine the winner
    function endGame() public {
        require(!gameEnded, "Game has already ended");
        require(teamA.votingEnded() && teamB.votingEnded(), "Voting must be completed by both teams");
        
        TeamAVoting.Choice teamAChoice = teamA.getFinalChoice();
        TeamBVoting.Choice teamBChoice = teamB.getFinalChoice();
        
        // Convert enums to uint for comparison
        uint teamAValue = uint(teamAChoice);
        uint teamBValue = uint(teamBChoice);
        
        // Rock = 1, Paper = 2, Scissors = 3
        if (teamAValue == teamBValue) {
            // It's a tie
            winner = Winner.TIE;
            ties++;
        } else if (
            (teamAValue == 1 && teamBValue == 3) || // Rock beats Scissors
            (teamAValue == 2 && teamBValue == 1) || // Paper beats Rock
            (teamAValue == 3 && teamBValue == 2)    // Scissors beats Paper
        ) {
            // Team A wins
            winner = Winner.TEAM_A;
            teamAWins++;
        } else {
            // Team B wins
            winner = Winner.TEAM_B;
            teamBWins++;
        }
        
        gameEnded = true;
        totalGamesPlayed++;
        
        emit GameEnded(winner);
    }
    
    // Function to reset the game for a new round
    function resetGame() public {
        require(gameEnded, "Current game has not ended yet");
        
        teamA.resetVoting();
        teamB.resetVoting();
        winner = Winner.NONE;
        gameEnded = false;
    }
    
    // Getter functions
    function getTeamChoices() public view returns (uint, uint) {
        require(gameEnded, "Game has not ended yet");
        
        return (uint(teamA.getFinalChoice()), uint(teamB.getFinalChoice()));
    }
    
    function getGameStats() public view returns (uint, uint, uint, uint) {
        return (totalGamesPlayed, teamAWins, teamBWins, ties);
    }
    
    // Helper function to get the name of the choice
    function getChoiceName(uint choice) public pure returns (string memory) {
        if (choice == 1) return "Rock";
        if (choice == 2) return "Paper";
        if (choice == 3) return "Scissors";
        return "None";
    }
} 