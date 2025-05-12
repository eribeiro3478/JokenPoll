// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RockPaperScissors {
    enum Choice { None, Rock, Paper, Scissors }
    enum Team { None, A, B }
    
    struct Vote {
        Choice choice;
        Team team;
        bool hasVoted;
    }
    
    mapping(address => Vote) private votes;
    address[] private voters; // arr track all voters
    
    uint256 private rockVotes;
    uint256 private paperVotes;
    uint256 private scissorsVotes;
    uint256 private teamAVotes;
    uint256 private teamBVotes;
    
    // tracking votes by team and choice
    uint256 private teamARockVotes;
    uint256 private teamAPaperVotes;
    uint256 private teamAScissorsVotes;
    uint256 private teamBRockVotes;
    uint256 private teamBPaperVotes;
    uint256 private teamBScissorsVotes;
    
    // tracking if team choices were random
    bool private teamAChoiceRandom;
    bool private teamBChoiceRandom;
    
    address public owner;
    bool public votingOpen = true;
    
    Choice private winningChoice;
    Team private winningTeam;
    
    // Store the most popular choice for each team
    Choice private teamAChoice;
    Choice private teamBChoice;
    
    event VoteCast(address indexed voter);
    event VotingClosed();
    event GameResult(string winningTeam, string details);
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier votingIsOpen() {
        require(votingOpen, "Voting is closed");
        _;
    }
    
    modifier votingIsOver() {
        require(!votingOpen, "Voting is still open");
        _;
    }
    
    // convert string to Choice enum
    function stringToChoice(string memory _choice) internal pure returns (Choice) {
        bytes32 hashChoice = keccak256(abi.encodePacked(_choice));
        
        if (hashChoice == keccak256(abi.encodePacked("Rock"))) {
            return Choice.Rock;
        } else if (hashChoice == keccak256(abi.encodePacked("Paper"))) {
            return Choice.Paper;
        } else if (hashChoice == keccak256(abi.encodePacked("Scissors"))) {
            return Choice.Scissors;
        } else {
            revert("Invalid choice. Use 'Rock', 'Paper', or 'Scissors'");
        }
    }
    
    // convert string to Team enum
    function stringToTeam(string memory _team) internal pure returns (Team) {
        bytes32 hashTeam = keccak256(abi.encodePacked(_team));
        
        if (hashTeam == keccak256(abi.encodePacked("A"))) {
            return Team.A;
        } else if (hashTeam == keccak256(abi.encodePacked("B"))) {
            return Team.B;
        } else {
            revert("Invalid team. Use 'A' or 'B'");
        }
    }
    
    // convert Choice enum to string
    function choiceToString(Choice _choice) internal pure returns (string memory) {
        if (_choice == Choice.Rock) {
            return "Rock";
        } else if (_choice == Choice.Paper) {
            return "Paper";
        } else if (_choice == Choice.Scissors) {
            return "Scissors";
        } else {
            return "None";
        }
    }
    
    // convert Team enum to string
    function teamToString(Team _team) internal pure returns (string memory) {
        if (_team == Team.A) {
            return "Team A";
        } else if (_team == Team.B) {
            return "Team B";
        } else {
            return "None";
        }
    }
    
    // Voting
    function castVote(string memory _choice, string memory _team) external votingIsOpen {
        require(!votes[msg.sender].hasVoted, "Already voted");
        
        Choice choice = stringToChoice(_choice);
        Team team = stringToTeam(_team);
        
        votes[msg.sender] = Vote(choice, team, true);
        voters.push(msg.sender); // Track this voter
        
        // Update choice counts
        if (choice == Choice.Rock) {
            rockVotes++;
            if (team == Team.A) {
                teamARockVotes++;
            } else if (team == Team.B) {
                teamBRockVotes++;
            }
        } else if (choice == Choice.Paper) {
            paperVotes++;
            if (team == Team.A) {
                teamAPaperVotes++;
            } else if (team == Team.B) {
                teamBPaperVotes++;
            }
        } else if (choice == Choice.Scissors) {
            scissorsVotes++;
            if (team == Team.A) {
                teamAScissorsVotes++;
            } else if (team == Team.B) {
                teamBScissorsVotes++;
            }
        }
        
        // Update team counts
        if (team == Team.A) {
            teamAVotes++;
            updateTeamChoice(Team.A);
        } else if (team == Team.B) {
            teamBVotes++;
            updateTeamChoice(Team.B);
        }
        
        emit VoteCast(msg.sender);
    }
    
    // Update team choice based on votes
    function updateTeamChoice(Team team) private {
        if (team == Team.A) {
            // Check if there's a clear winner for Team A
            if (teamARockVotes > teamAPaperVotes && teamARockVotes > teamAScissorsVotes) {
                teamAChoice = Choice.Rock;
                teamAChoiceRandom = false;
            } else if (teamAPaperVotes > teamARockVotes && teamAPaperVotes > teamAScissorsVotes) {
                teamAChoice = Choice.Paper;
                teamAChoiceRandom = false;
            } else if (teamAScissorsVotes > teamARockVotes && teamAScissorsVotes > teamAPaperVotes) {
                teamAChoice = Choice.Scissors;
                teamAChoiceRandom = false;
            } else if (teamARockVotes > 0 || teamAPaperVotes > 0 || teamAScissorsVotes > 0) {
                // There's a tie, but we'll resolve it at the end of voting
                teamAChoiceRandom = true;
            }
        } else if (team == Team.B) {
            // Check if there's a clear winner for Team B
            if (teamBRockVotes > teamBPaperVotes && teamBRockVotes > teamBScissorsVotes) {
                teamBChoice = Choice.Rock;
                teamBChoiceRandom = false;
            } else if (teamBPaperVotes > teamBRockVotes && teamBPaperVotes > teamBScissorsVotes) {
                teamBChoice = Choice.Paper;
                teamBChoiceRandom = false;
            } else if (teamBScissorsVotes > teamBRockVotes && teamBScissorsVotes > teamBPaperVotes) {
                teamBChoice = Choice.Scissors;
                teamBChoiceRandom = false;
            } else if (teamBRockVotes > 0 || teamBPaperVotes > 0 || teamBScissorsVotes > 0) {
                // There's a tie, but we'll resolve it at the end of voting
                teamBChoiceRandom = true;
            }
        }
    }
    
    // count votes for a specific choice and team
    function countTeamChoice(Choice choice, Team team) private view returns (uint256) {
        if (team == Team.A) {
            if (choice == Choice.Rock) return teamARockVotes;
            if (choice == Choice.Paper) return teamAPaperVotes;
            if (choice == Choice.Scissors) return teamAScissorsVotes;
        } else if (team == Team.B) {
            if (choice == Choice.Rock) return teamBRockVotes;
            if (choice == Choice.Paper) return teamBPaperVotes;
            if (choice == Choice.Scissors) return teamBScissorsVotes;
        }
        return 0;
    }
    
    function endVoting() external onlyOwner votingIsOpen {
        votingOpen = false;
        
        // Resolve any random selections needed for team choices
        resolveTeamChoices();
        
        // Determine winners
        determineWinners();
        
        string memory resultDetails = generateResultDetails();
        
        emit VotingClosed();
        emit GameResult(teamToString(winningTeam), resultDetails);
    }
    
    // Resolve team choices if there are ties
    function resolveTeamChoices() private {
        // Resolve Team A's choice if random
        if (teamAChoiceRandom && teamAVotes > 0) {
            uint256 randomA = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, "TeamA"))) % 3;
            
            // Create an array of choices that tied
            Choice[3] memory tiedChoices;
            uint8 tiedCount = 0;
            
            // Find tied choices
            uint256 maxVotes = 0;
            if (teamARockVotes >= maxVotes) {
                if (teamARockVotes > maxVotes) {
                    maxVotes = teamARockVotes;
                    tiedCount = 0;
                }
                tiedChoices[tiedCount++] = Choice.Rock;
            }
            
            if (teamAPaperVotes >= maxVotes) {
                if (teamAPaperVotes > maxVotes) {
                    maxVotes = teamAPaperVotes;
                    tiedCount = 0;
                }
                tiedChoices[tiedCount++] = Choice.Paper;
            }
            
            if (teamAScissorsVotes >= maxVotes) {
                if (teamAScissorsVotes > maxVotes) {
                    maxVotes = teamAScissorsVotes;
                    tiedCount = 0;
                }
                tiedChoices[tiedCount++] = Choice.Scissors;
            }
            
            // Select a random choice from tied options
            teamAChoice = tiedChoices[randomA % tiedCount];
        }
        
        // Resolve Team B's choice if random
        if (teamBChoiceRandom && teamBVotes > 0) {
            uint256 randomB = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, "TeamB"))) % 3;
            
            // Create an array of choices that tied
            Choice[3] memory tiedChoices;
            uint8 tiedCount = 0;
            
            // Find tied choices
            uint256 maxVotes = 0;
            if (teamBRockVotes >= maxVotes) {
                if (teamBRockVotes > maxVotes) {
                    maxVotes = teamBRockVotes;
                    tiedCount = 0;
                }
                tiedChoices[tiedCount++] = Choice.Rock;
            }
            
            if (teamBPaperVotes >= maxVotes) {
                if (teamBPaperVotes > maxVotes) {
                    maxVotes = teamBPaperVotes;
                    tiedCount = 0;
                }
                tiedChoices[tiedCount++] = Choice.Paper;
            }
            
            if (teamBScissorsVotes >= maxVotes) {
                if (teamBScissorsVotes > maxVotes) {
                    maxVotes = teamBScissorsVotes;
                    tiedCount = 0;
                }
                tiedChoices[tiedCount++] = Choice.Scissors;
            }
            
            // Select a random choice from tied options
            teamBChoice = tiedChoices[randomB % tiedCount];
        }
    }
    
    function determineWinners() private {
        // Determine winning choice (overall most popular choice)
        if (rockVotes > paperVotes && rockVotes > scissorsVotes) {
            winningChoice = Choice.Rock;
        } else if (paperVotes > rockVotes && paperVotes > scissorsVotes) {
            winningChoice = Choice.Paper;
        } else if (scissorsVotes > rockVotes && scissorsVotes > paperVotes) {
            winningChoice = Choice.Scissors;
        } else {
            // There's a tie, select randomly
            uint256 randomValue = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % 3;
            if (randomValue == 0) {
                winningChoice = Choice.Rock;
            } else if (randomValue == 1) {
                winningChoice = Choice.Paper;
            } else {
                winningChoice = Choice.Scissors;
            }
        }
        
        // Determine winning team based on Rock-Paper-Scissors rules
        if (teamAChoice == teamBChoice) {
            // If both teams chose the same, the team with more votes wins
            winningTeam = teamAVotes > teamBVotes ? Team.A : Team.B;
            if (teamAVotes == teamBVotes) {
                // If votes are equal too, random tiebreaker
                winningTeam = uint256(keccak256(abi.encodePacked(block.timestamp))) % 2 == 0 ? Team.A : Team.B;
            }
        } else {
            // Apply Rock-Paper-Scissors rules
            if (
                (teamAChoice == Choice.Rock && teamBChoice == Choice.Scissors) ||
                (teamAChoice == Choice.Paper && teamBChoice == Choice.Rock) ||
                (teamAChoice == Choice.Scissors && teamBChoice == Choice.Paper)
            ) {
                winningTeam = Team.A; // Team A's choice beats Team B's choice
            } else {
                winningTeam = Team.B; // Team B's choice beats Team A's choice
            }
        }
    }
    
    // Generate detailed result information
    function generateResultDetails() private view returns (string memory) {
        string memory teamAChoiceStr = choiceToString(teamAChoice);
        string memory teamBChoiceStr = choiceToString(teamBChoice);
        string memory winningTeamStr = teamToString(winningTeam);
        
        // Start with the winning team
        string memory result = string(abi.encodePacked(
            winningTeamStr, " wins! "
        ));
        
        // Add team choices with random selection info if applicable
        string memory teamAInfo = teamAChoiceRandom ? 
            string(abi.encodePacked("Team A selected ", teamAChoiceStr, " (chosen randomly due to a tie in voting). ")) :
            string(abi.encodePacked("Team A selected ", teamAChoiceStr, ". "));
            
        string memory teamBInfo = teamBChoiceRandom ? 
            string(abi.encodePacked("Team B selected ", teamBChoiceStr, " (chosen randomly due to a tie in voting). ")) :
            string(abi.encodePacked("Team B selected ", teamBChoiceStr, ". "));
            
        result = string(abi.encodePacked(result, teamAInfo, teamBInfo));
        
        // Add winner explanation
        if (winningTeam == Team.A) {
            if (
                (teamAChoice == Choice.Rock && teamBChoice == Choice.Scissors) ||
                (teamAChoice == Choice.Paper && teamBChoice == Choice.Rock) ||
                (teamAChoice == Choice.Scissors && teamBChoice == Choice.Paper)
            ) {
                result = string(abi.encodePacked(
                    result, "Team A's ", teamAChoiceStr, " beats Team B's ", teamBChoiceStr, ". "
                ));
            } else if (teamAChoice == teamBChoice) {
                result = string(abi.encodePacked(
                    result, "Both teams chose ", teamAChoiceStr, ", so Team A won based on having more votes. "
                ));
            }
        } else { // Team B won
            if (
                (teamBChoice == Choice.Rock && teamAChoice == Choice.Scissors) ||
                (teamBChoice == Choice.Paper && teamAChoice == Choice.Rock) ||
                (teamBChoice == Choice.Scissors && teamAChoice == Choice.Paper)
            ) {
                result = string(abi.encodePacked(
                    result, "Team B's ", teamBChoiceStr, " beats Team A's ", teamAChoiceStr, ". "
                ));
            } else if (teamAChoice == teamBChoice) {
                result = string(abi.encodePacked(
                    result, "Both teams chose ", teamBChoiceStr, ", so Team B won based on having more votes. "
                ));
            }
        }
        
        // Add vote counts
        result = string(abi.encodePacked(
            result, "Votes - Team A: ", toString(teamAVotes), ", Team B: ", toString(teamBVotes)
        ));
        
        return result;
    }
    
    // Helper function to convert uint to string
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        
        uint256 temp = value;
        uint256 digits;
        
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        
        return string(buffer);
    }
    
    function resetGame() external onlyOwner {
        require(!votingOpen, "Cannot reset while voting is open");
        
        // Reset voting status
        votingOpen = true;
        
        // Reset vote counts
        rockVotes = 0;
        paperVotes = 0;
        scissorsVotes = 0;
        teamAVotes = 0;
        teamBVotes = 0;
        
        // Reset team choice votes
        teamARockVotes = 0;
        teamAPaperVotes = 0;
        teamAScissorsVotes = 0;
        teamBRockVotes = 0;
        teamBPaperVotes = 0;
        teamBScissorsVotes = 0;
        
        // Reset randomness flags
        teamAChoiceRandom = false;
        teamBChoiceRandom = false;
        
        // Reset winners
        winningChoice = Choice.None;
        winningTeam = Team.None;
        teamAChoice = Choice.None;
        teamBChoice = Choice.None;
        
        // Reset all voter records
        for (uint i = 0; i < voters.length; i++) {
            delete votes[voters[i]];
        }
        
        // Clear the voters array
        delete voters;
    }
    
    // Public functions - accessible to everyone
    
    // Check if an address has voted and what they voted for (modified function name)
    function checkIfAddressHasVoted(address voter) external view onlyOwner returns (bool, string memory choice, string memory team) {
        Vote memory voterInfo = votes[voter];
        return (
            voterInfo.hasVoted,
            choiceToString(voterInfo.choice), 
            teamToString(voterInfo.team)
        );
    }
    
    // Get the winning team after voting is closed
    function getWinningTeam() external view votingIsOver returns (string memory) {
        return teamToString(winningTeam);
    }
    
    // Get a public version of the game result with limited information
    function getPublicGameResult() external view votingIsOver returns (string memory) {
        string memory teamAChoiceStr = choiceToString(teamAChoice);
        string memory teamBChoiceStr = choiceToString(teamBChoice);
        string memory winningTeamStr = teamToString(winningTeam);
        
        // Start with the winning team
        string memory result = string(abi.encodePacked(
            winningTeamStr, " wins! "
        ));
        
        // Add team choices with random selection info if applicable
        string memory teamAInfo = teamAChoiceRandom ? 
            string(abi.encodePacked("Team A selected ", teamAChoiceStr, " (chosen randomly due to a tie in voting). ")) :
            string(abi.encodePacked("Team A selected ", teamAChoiceStr, ". "));
            
        string memory teamBInfo = teamBChoiceRandom ? 
            string(abi.encodePacked("Team B selected ", teamBChoiceStr, " (chosen randomly due to a tie in voting). ")) :
            string(abi.encodePacked("Team B selected ", teamBChoiceStr, ". "));
            
        result = string(abi.encodePacked(result, teamAInfo, teamBInfo));


        if (winningTeam == Team.A) {
            if (
                (teamAChoice == Choice.Rock && teamBChoice == Choice.Scissors) ||
                (teamAChoice == Choice.Paper && teamBChoice == Choice.Rock) ||
                (teamAChoice == Choice.Scissors && teamBChoice == Choice.Paper)
            ) {
                result = string(abi.encodePacked(
                    result, "Team A's ", teamAChoiceStr, " beats Team B's ", teamBChoiceStr, "."
                ));
            } else if (teamAChoice == teamBChoice) {
                result = string(abi.encodePacked(
                    result, "Both teams chose ", teamAChoiceStr, ", so Team A won based on having more votes."
                ));
            }
        } else { // Team B won
            if (
                (teamBChoice == Choice.Rock && teamAChoice == Choice.Scissors) ||
                (teamBChoice == Choice.Paper && teamAChoice == Choice.Rock) ||
                (teamBChoice == Choice.Scissors && teamAChoice == Choice.Paper)
            ) {
                result = string(abi.encodePacked(
                    result, "Team B's ", teamBChoiceStr, " beats Team A's ", teamAChoiceStr, "."
                ));
            } else if (teamAChoice == teamBChoice) {
                result = string(abi.encodePacked(
                    result, "Both teams chose ", teamBChoiceStr, ", so Team B won based on having more votes."
                ));
            }
        }
        
        return result;
    }
    
    // accessible only to the contract owner
    
    function getGameState() external view onlyOwner returns (
        bool isVotingOpen,
        uint256 totalRockVotes,
        uint256 totalPaperVotes,
        uint256 totalScissorsVotes,
        uint256 totalTeamAVotes,
        uint256 totalTeamBVotes,
        string memory currentWinningChoice,
        string memory currentWinningTeam
    ) {
        return (
            votingOpen,
            rockVotes,
            paperVotes,
            scissorsVotes,
            teamAVotes,
            teamBVotes,
            choiceToString(winningChoice),
            teamToString(winningTeam)
        );
    }
    
    function getVoteDetails(address voter) external view onlyOwner returns (bool hasVoted, string memory choice, string memory team) {
        Vote memory voterInfo = votes[voter];
        return (
            voterInfo.hasVoted,
            choiceToString(voterInfo.choice), 
            teamToString(voterInfo.team)
        );
    }
    
    function getDetailedGameResult() external view onlyOwner votingIsOver returns (string memory) {
        return generateResultDetails();
    }
}
