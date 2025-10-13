// This file contains the JavaScript code for the game logic, handling user interactions and game mechanics.

const gameBoard = document.getElementById('game-board');
const scoreDisplay = document.getElementById('score');
let score = 0;
let tiles = [];

// Initialize the game board
function initGame() {
    tiles = createTiles();
    renderBoard();
}

// Create tiles for the game
function createTiles() {
    const tileCount = 64; // 8x8 board
    const tileTypes = ['red', 'blue', 'green', 'yellow', 'purple'];
    const tilesArray = [];

    for (let i = 0; i < tileCount; i++) {
        const tile = {
            type: tileTypes[Math.floor(Math.random() * tileTypes.length)],
            id: i
        };
        tilesArray.push(tile);
    }
    return tilesArray;
}

// Render the game board
function renderBoard() {
    gameBoard.innerHTML = '';
    tiles.forEach(tile => {
        const tileElement = document.createElement('div');
        tileElement.className = `tile ${tile.type}`;
        tileElement.dataset.id = tile.id;
        tileElement.addEventListener('click', handleTileClick);
        gameBoard.appendChild(tileElement);
    });
}

// Handle tile click event
function handleTileClick(event) {
    const tileId = event.target.dataset.id;
    const tile = tiles[tileId];

    // Logic for matching tiles and updating score
    // For simplicity, we will just increase the score on click
    score += 10; // Increment score
    scoreDisplay.innerText = `Score: ${score}`;
    console.log(`Tile clicked: ${tile.type}, Score: ${score}`);
}

// Start the game
initGame();