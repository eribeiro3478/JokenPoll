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
    uint256 private rockVotes;
    uint256 private paperVotes;
    uint256 private scissorsVotes;
    uint256 private teamAVotes;
    uint256 private teamBVotes;
    
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
    
    // Helper function to convert string to Choice enum
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
    
    // Helper function to convert string to Team enum
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
    
    // Helper function to convert Choice enum to string
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
    
    // Helper function to convert Team enum to string
    function teamToString(Team _team) internal pure returns (string memory) {
        if (_team == Team.A) {
            return "Team A";
        } else if (_team == Team.B) {
            return "Team B";
        } else {
            return "None";
        }
    }
    
    // Vote with string inputs
    function castVote(string memory _choice, string memory _team) external votingIsOpen {
        require(!votes[msg.sender].hasVoted, "Already voted");
        
        Choice choice = stringToChoice(_choice);
        Team team = stringToTeam(_team);
        
        votes[msg.sender] = Vote(choice, team, true);
        
        // Update choice counts
        if (choice == Choice.Rock) {
            rockVotes++;
            if (team == Team.A && (teamAChoice == Choice.None || rockVotes > countTeamChoice(Choice.Rock, Team.A))) {
                teamAChoice = Choice.Rock;
            } else if (team == Team.B && (teamBChoice == Choice.None || rockVotes > countTeamChoice(Choice.Rock, Team.B))) {
                teamBChoice = Choice.Rock;
            }
        } else if (choice == Choice.Paper) {
            paperVotes++;
            if (team == Team.A && (teamAChoice == Choice.None || paperVotes > countTeamChoice(Choice.Paper, Team.A))) {
                teamAChoice = Choice.Paper;
            } else if (team == Team.B && (teamBChoice == Choice.None || paperVotes > countTeamChoice(Choice.Paper, Team.B))) {
                teamBChoice = Choice.Paper;
            }
        } else if (choice == Choice.Scissors) {
            scissorsVotes++;
            if (team == Team.A && (teamAChoice == Choice.None || scissorsVotes > countTeamChoice(Choice.Scissors, Team.A))) {
                teamAChoice = Choice.Scissors;
            } else if (team == Team.B && (teamBChoice == Choice.None || scissorsVotes > countTeamChoice(Choice.Scissors, Team.B))) {
                teamBChoice = Choice.Scissors;
            }
        }
        
        // Update team counts
        if (team == Team.A) {
            teamAVotes++;
        } else if (team == Team.B) {
            teamBVotes++;
        }
        
        emit VoteCast(msg.sender);
    }
    
    // Helper function to count votes for a specific choice and team
    function countTeamChoice(Choice choice, Team team) private view returns (uint256) {
        uint256 count = 0;
        if (choice == Choice.Rock && team == Team.A) {
            count = rockVotes;
        } else if (choice == Choice.Paper && team == Team.A) {
            count = paperVotes;
        } else if (choice == Choice.Scissors && team == Team.A) {
            count = scissorsVotes;
        } else if (choice == Choice.Rock && team == Team.B) {
            count = rockVotes;
        } else if (choice == Choice.Paper && team == Team.B) {
            count = paperVotes;
        } else if (choice == Choice.Scissors && team == Team.B) {
            count = scissorsVotes;
        }
        return count;
    }
    
    function endVoting() external onlyOwner votingIsOpen {
        votingOpen = false;
        determineWinners();
        
        string memory resultDetails = generateResultDetails();
        
        emit VotingClosed();
        emit GameResult(teamToString(winningTeam), resultDetails);
    }
    
    function determineWinners() private {
        // Determine winning choice
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
        
        // Determine winning team
        winningTeam = teamAVotes > teamBVotes ? Team.A : Team.B;
        if (teamAVotes == teamBVotes) {
            // Tie-breaker based on the random hash
            winningTeam = uint256(keccak256(abi.encodePacked(block.timestamp))) % 2 == 0 ? Team.A : Team.B;
        }
    }
    
    // Generate detailed result information
    function generateResultDetails() private view returns (string memory) {
        string memory teamAChoiceStr = choiceToString(teamAChoice);
        string memory teamBChoiceStr = choiceToString(teamBChoice);
        
        if (winningTeam == Team.A) {
            if (
                (teamAChoice == Choice.Rock && teamBChoice == Choice.Scissors) ||
                (teamAChoice == Choice.Paper && teamBChoice == Choice.Rock) ||
                (teamAChoice == Choice.Scissors && teamBChoice == Choice.Paper)
            ) {
                return string(abi.encodePacked(
                    "Team A won with ", teamAChoiceStr, " beating Team B's ", teamBChoiceStr, ". ",
                    "Votes - Team A: ", toString(teamAVotes), ", Team B: ", toString(teamBVotes)
                ));
            } else if (teamAChoice == teamBChoice) {
                return string(abi.encodePacked(
                    "Team A won based on vote count. Both teams chose ", teamAChoiceStr, ". ",
                    "Votes - Team A: ", toString(teamAVotes), ", Team B: ", toString(teamBVotes)
                ));
            } else {
                return string(abi.encodePacked(
                    "Team A won based on vote count, even though Team B's ", teamBChoiceStr, 
                    " would beat Team A's ", teamAChoiceStr, ". ",
                    "Votes - Team A: ", toString(teamAVotes), ", Team B: ", toString(teamBVotes)
                ));
            }
        } else { // Team B won
            if (
                (teamBChoice == Choice.Rock && teamAChoice == Choice.Scissors) ||
                (teamBChoice == Choice.Paper && teamAChoice == Choice.Rock) ||
                (teamBChoice == Choice.Scissors && teamAChoice == Choice.Paper)
            ) {
                return string(abi.encodePacked(
                    "Team B won with ", teamBChoiceStr, " beating Team A's ", teamAChoiceStr, ". ",
                    "Votes - Team A: ", toString(teamAVotes), ", Team B: ", toString(teamBVotes)
                ));
            } else if (teamAChoice == teamBChoice) {
                return string(abi.encodePacked(
                    "Team B won based on vote count. Both teams chose ", teamBChoiceStr, ". ",
                    "Votes - Team A: ", toString(teamAVotes), ", Team B: ", toString(teamBVotes)
                ));
            } else {
                return string(abi.encodePacked(
                    "Team B won based on vote count, even though Team A's ", teamAChoiceStr, 
                    " would beat Team B's ", teamBChoiceStr, ". ",
                    "Votes - Team A: ", toString(teamAVotes), ", Team B: ", toString(teamBVotes)
                ));
            }
        }
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
        
        // Reset winners
        winningChoice = Choice.None;
        winningTeam = Team.None;
        teamAChoice = Choice.None;
        teamBChoice = Choice.None;
    }
    
    // Public functions - accessible to everyone
    
    // Check if an address has voted
    function hasVoted() external view returns (bool) {
        return votes[msg.sender].hasVoted;
    }
    
    // Get the current voting status
    function isVotingOpen() external view returns (bool) {
        return votingOpen;
    }
    
    // Get the winning team after voting is closed
    function getWinningTeam() external view votingIsOver returns (string memory) {
        return teamToString(winningTeam);
    }
    
    // Get a public version of the game result with limited information
    function getPublicGameResult() external view votingIsOver returns (string memory) {
        string memory teamAChoiceStr = choiceToString(teamAChoice);
        string memory teamBChoiceStr = choiceToString(teamBChoice);
        
        if (winningTeam == Team.A) {
            if (
                (teamAChoice == Choice.Rock && teamBChoice == Choice.Scissors) ||
                (teamAChoice == Choice.Paper && teamBChoice == Choice.Rock) ||
                (teamAChoice == Choice.Scissors && teamBChoice == Choice.Paper)
            ) {
                return string(abi.encodePacked(
                    "Team A won with ", teamAChoiceStr, " beating Team B's ", teamBChoiceStr
                ));
            } else if (teamAChoice == teamBChoice) {
                return string(abi.encodePacked(
                    "Team A won. Both teams chose ", teamAChoiceStr
                ));
            } else {
                return string(abi.encodePacked(
                    "Team A won based on vote count, even though Team B's ", teamBChoiceStr, 
                    " would beat Team A's ", teamAChoiceStr
                ));
            }
        } else { // Team B won
            if (
                (teamBChoice == Choice.Rock && teamAChoice == Choice.Scissors) ||
                (teamBChoice == Choice.Paper && teamAChoice == Choice.Rock) ||
                (teamBChoice == Choice.Scissors && teamAChoice == Choice.Paper)
            ) {
                return string(abi.encodePacked(
                    "Team B won with ", teamBChoiceStr, " beating Team A's ", teamAChoiceStr
                ));
            } else if (teamAChoice == teamBChoice) {
                return string(abi.encodePacked(
                    "Team B won. Both teams chose ", teamBChoiceStr
                ));
            } else {
                return string(abi.encodePacked(
                    "Team B won based on vote count, even though Team A's ", teamAChoiceStr, 
                    " would beat Team B's ", teamBChoiceStr
                ));
            }
        }
    }
    
    // Owner-only functions - accessible only to the contract owner
    
    // Get the complete game state with detailed information
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
    
    // Check if a specific address has voted and what they voted for
    function getVoteDetails(address voter) external view onlyOwner returns (bool hasVoted, string memory choice, string memory team) {
        Vote memory voterInfo = votes[voter];
        return (
            voterInfo.hasVoted,
            choiceToString(voterInfo.choice), 
            teamToString(voterInfo.team)
        );
    }
    
    // Get detailed game result information with vote counts
    function getDetailedGameResult() external view onlyOwner votingIsOver returns (string memory) {
        return generateResultDetails();
    }
} 