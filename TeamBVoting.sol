// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TeamBVoting {
    // Options for voting
    enum Choice { NONE, ROCK, PAPER, SCISSORS }
    
    // Mapping of voter addresses to their choices
    mapping(address => Choice) public votes;
    
    // Vote counts
    uint public rockVotes;
    uint public paperVotes;
    uint public scissorsVotes;
    
    // Flag to check if voting has ended
    bool public votingEnded;
    
    // Final choice
    Choice public finalChoice;
    
    // Event declarations
    event VoteCast(address voter, Choice choice);
    event VotingEnded(Choice finalChoice);
    
    // Constructor
    constructor() {
        votingEnded = false;
    }
    
    // Function to cast a vote
    function vote(uint _choice) public {
        require(!votingEnded, "Voting has ended");
        require(_choice >= 1 && _choice <= 3, "Invalid choice");
        require(votes[msg.sender] == Choice.NONE, "Already voted");
        
        Choice choice = Choice(_choice);
        votes[msg.sender] = choice;
        
        if (choice == Choice.ROCK) {
            rockVotes++;
        } else if (choice == Choice.PAPER) {
            paperVotes++;
        } else if (choice == Choice.SCISSORS) {
            scissorsVotes++;
        }
        
        emit VoteCast(msg.sender, choice);
    }
    
    // Function to end voting and determine the final choice
    function endVoting() public {
        require(!votingEnded, "Voting has already ended");
        
        // Determine the winning choice
        if (rockVotes > paperVotes && rockVotes > scissorsVotes) {
            finalChoice = Choice.ROCK;
        } else if (paperVotes > rockVotes && paperVotes > scissorsVotes) {
            finalChoice = Choice.PAPER;
        } else if (scissorsVotes > rockVotes && scissorsVotes > paperVotes) {
            finalChoice = Choice.SCISSORS;
        } else {
            // Handle tie by random selection
            uint randomNumber = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % 3;
            if (randomNumber == 0) {
                finalChoice = Choice.ROCK;
            } else if (randomNumber == 1) {
                finalChoice = Choice.PAPER;
            } else {
                finalChoice = Choice.SCISSORS;
            }
        }
        
        votingEnded = true;
        emit VotingEnded(finalChoice);
    }
    
    // Function to reset voting for a new round
    function resetVoting() public {
        rockVotes = 0;
        paperVotes = 0;
        scissorsVotes = 0;
        finalChoice = Choice.NONE;
        votingEnded = false;
    }
    
    // Getter functions
    function getVoteCounts() public view returns (uint, uint, uint) {
        return (rockVotes, paperVotes, scissorsVotes);
    }
    
    function getFinalChoice() public view returns (Choice) {
        require(votingEnded, "Voting has not ended yet");
        return finalChoice;
    }
} 