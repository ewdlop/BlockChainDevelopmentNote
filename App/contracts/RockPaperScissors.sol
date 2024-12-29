```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// This contract implements a Rock-Paper-Scissors game with betting and reveal mechanisms.
contract RockPaperScissors {
    enum Move { Rock, Paper, Scissors }
    enum GameState { Created, Joined, Reveal, Finished }

    struct Game {
        address player1;
        address player2;
        bytes32 player1MoveHash;
        bytes32 player2MoveHash;
        Move player1Move;
        Move player2Move;
        GameState state;
        uint256 betAmount;
        uint256 revealDeadline;
        uint256 joinDeadline;
    }

    mapping(uint256 => Game) public games;
    mapping(address => uint256) public balances;
    uint256 public gameCount;
    uint256 public revealTimeLimit = 1 hours; // Time limit to reveal moves
    uint256 public joinTimeLimit = 1 days; // Time limit to join a game

    event GameCreated(uint256 gameId, address indexed player1, uint256 betAmount);
    event GameJoined(uint256 gameId, address indexed player2);
    event MoveRevealed(uint256 gameId, address indexed player, Move move);
    event GameFinished(uint256 gameId, address indexed winner);
    event GameExpired(uint256 gameId);
    event FundsWithdrawn(address indexed player, uint256 amount);

    // Create a new game with a hashed move and a bet amount
    function createGame(bytes32 _moveHash) external payable {
        require(msg.value > 0, "Bet amount must be greater than zero");

        games[gameCount] = Game({
            player1: msg.sender,
            player2: address(0),
            player1MoveHash: _moveHash,
            player2MoveHash: bytes32(0),
            player1Move: Move.Rock, // Default value
            player2Move: Move.Rock, // Default value
            state: GameState.Created,
            betAmount: msg.value,
            revealDeadline: 0,
            joinDeadline: block.timestamp + joinTimeLimit
        });

        emit GameCreated(gameCount, msg.sender, msg.value);
        gameCount++;
    }

    // Join an existing game with a matching bet amount and hashed move
    function joinGame(uint256 _gameId, bytes32 _moveHash) external payable {
        Game storage game = games[_gameId];
        require(game.state == GameState.Created, "Game is not in Created state");
        require(msg.value == game.betAmount, "Bet amount must match");
        require(game.player1 != msg.sender, "Player cannot join their own game");
        require(block.timestamp <= game.joinDeadline, "Join time has expired");

        game.player2 = msg.sender;
        game.player2MoveHash = _moveHash;
        game.state = GameState.Joined;
        game.revealDeadline = block.timestamp + revealTimeLimit;

        emit GameJoined(_gameId, msg.sender);
    }

    // Reveal the player's move using the original move and secret
    function revealMove(uint256 _gameId, Move _move, string memory _secret) external {
        Game storage game = games[_gameId];
        require(game.state == GameState.Joined, "Game is not in Joined state");
        require(block.timestamp <= game.revealDeadline, "Reveal time has passed");

        bytes32 moveHash = keccak256(abi.encodePacked(_move, _secret));

        if (msg.sender == game.player1) {
            require(moveHash == game.player1MoveHash, "Invalid move or secret for player1");
            game.player1Move = _move;
        } else if (msg.sender == game.player2) {
            require(moveHash == game.player2MoveHash, "Invalid move or secret for player2");
            game.player2Move = _move;
        } else {
            revert("Invalid player");
        }

        emit MoveRevealed(_gameId, msg.sender, _move);

        if (game.player1Move != Move.Rock && game.player2Move != Move.Rock) {
            determineWinner(_gameId);
        }
    }

    // Determine the winner based on revealed moves and transfer the bet amount
    function determineWinner(uint256 _gameId) private {
        Game storage game = games[_gameId];
        require(game.state == GameState.Joined, "Game is not in Reveal state");

        address winner;
        if (game.player1Move == game.player2Move) {
            balances[game.player1] += game.betAmount;
            balances[game.player2] += game.betAmount;
        } else if ((game.player1Move == Move.Rock && game.player2Move == Move.Scissors) ||
                   (game.player1Move == Move.Paper && game.player2Move == Move.Rock) ||
                   (game.player1Move == Move.Scissors && game.player2Move == Move.Paper)) {
            winner = game.player1;
        } else {
            winner = game.player2;
        }

        if (winner != address(0)) {
            balances[winner] += 2 * game.betAmount;
            emit GameFinished(_gameId, winner);
        }

        game.state = GameState.Finished;
    }

    // Claim the bet amount if the opponent does not reveal their move in time
    function claimTimeout(uint256 _gameId) external {
        Game storage game = games[_gameId];
        require(game.state == GameState.Joined, "Game is not in Joined state");
        require(block.timestamp > game.revealDeadline, "Reveal time has not passed");

        if (game.player1Move == Move.Rock && game.player2Move == Move.Rock) {
            balances[game.player1] += game.betAmount;
            balances[game.player2] += game.betAmount;
        } else if (game.player1Move == Move.Rock) {
            balances[game.player2] += 2 * game.betAmount;
            emit GameFinished(_gameId, game.player2);
        } else if (game.player2Move == Move.Rock) {
            balances[game.player1] += 2 * game.betAmount;
            emit GameFinished(_gameId, game.player1);
        }

        game.state = GameState.Finished;
    }

    // Expire the game if no one joins within the join time limit
    function expireGame(uint256 _gameId) external {
        Game storage game = games[_gameId];
        require(game.state == GameState.Created, "Game is not in Created state");
        require(block.timestamp > game.joinDeadline, "Join time has not passed");

        balances[game.player1] += game.betAmount;
        game.state = GameState.Finished;

        emit GameExpired(_gameId);
    }

    // Withdraw the player's balance from the contract
    function withdrawFunds() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No funds to withdraw");

        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit FundsWithdrawn(msg.sender, amount);
    }
}
