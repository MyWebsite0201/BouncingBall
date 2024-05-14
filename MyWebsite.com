<!DOCTYPE html>
<h2> If you are not sure how to move your table. These are the keyboards ArrowLeft and ArrowRight i will just say its under your shift button
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Bouncing Ball Game</title>
<style>
  /* Styling for the game canvas */
  canvas {
    border: 1px solid black;
    display: block;
    margin: 0 auto;
  }
</style>
</head>
<body>
<canvas id="gameCanvas" width="480" height="320"></canvas>
<script>
// Get the canvas element and its 2D context
var canvas = document.getElementById("gameCanvas");
var ctx = canvas.getContext("2d");

// Set up initial ball position and speed
var x = canvas.width / 2;
var y = canvas.height - 30;
var dx = 2;
var dy = -2;
var ballRadius = 10;

// Set up paddle variables
var paddleHeight = 10;
var paddleWidth = 75;
var paddleX = (canvas.width - paddleWidth) / 2;
var rightPressed = false;
var leftPressed = false;

// Set up brick variables
var brickRowCount = 3;
var brickColumnCount = 5;
var brickWidth = 75;
var brickHeight = 20;
var brickPadding = 10;
var brickOffsetTop = 30;
var brickOffsetLeft = 30;

var bricks = [];
for(var c = 0; c < brickColumnCount; c++) {
    bricks[c] = [];
    for(var r = 0; r < brickRowCount; r++) {
        bricks[c][r] = { x: 0, y: 0, status: 1 };
    }
}

// Event listeners for paddle movement
document.addEventListener("keydown", keyDownHandler, false);
document.addEventListener("keyup", keyUpHandler, false);

// Key down handler
function keyDownHandler(e) {
  if (e.key === "Right" || e.key === "ArrowRight") {
    rightPressed = true;
  } else if (e.key === "Left" || e.key === "ArrowLeft") {
    leftPressed = true;
  }
}

// Key up handler
function keyUpHandler(e) {
  if (e.key === "Right" || e.key === "ArrowRight") {
    rightPressed = false;
  } else if (e.key === "Left" || e.key === "ArrowLeft") {
    leftPressed = false;
  }
}

// Function to draw the ball
function drawBall() {
  ctx.beginPath();
  ctx.arc(x, y, ballRadius, 0, Math.PI*2);
  ctx.fillStyle = "#0095DD";
  ctx.fill();
  ctx.closePath();
}

// Function to draw the paddle
function drawPaddle() {
  ctx.beginPath();
  ctx.rect(paddleX, canvas.height - paddleHeight, paddleWidth, paddleHeight);
  ctx.fillStyle = "#0095DD";
  ctx.fill();
  ctx.closePath();
}

// Function to draw bricks
function drawBricks() {
    for(var c = 0; c < brickColumnCount; c++) {
        for(var r = 0; r < brickRowCount; r++) {
            if(bricks[c][r].status == 1) {
                var brickX = (c*(brickWidth+brickPadding))+brickOffsetLeft;
                var brickY = (r*(brickHeight+brickPadding))+brickOffsetTop;
                bricks[c][r].x = brickX;
                bricks[c][r].y = brickY;
                ctx.beginPath();
                ctx.rect(brickX, brickY, brickWidth, brickHeight);
                ctx.fillStyle = "#000000"; // Black color for bricks
                ctx.fill();
                ctx.closePath();
            }
        }
    }
}

// Function to update ball position and check for collisions
function updateBallPosition() {
  // Clear the canvas
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  // Draw the ball
  drawBall();

  // Draw the paddle
  drawPaddle();

  // Draw the bricks
  drawBricks();

  // Move the paddle based on key presses
  if (rightPressed && paddleX < canvas.width - paddleWidth) {
    paddleX += 7;
  } else if (leftPressed && paddleX > 0) {
    paddleX -= 7;
  }

  // Bounce off the walls
  if (x + dx > canvas.width - ballRadius || x + dx < ballRadius) {
    dx = -dx;
  }
  if (y + dy < ballRadius) {
    dy = -dy;
  } else if (y + dy > canvas.height - ballRadius) {
    // Check if the ball hits the paddle
    if (x > paddleX && x < paddleX + paddleWidth) {
      dy = -dy;
    } else {
      // Game over if the ball misses the paddle
      gameOver();
    }
  }

  // Collision detection for bricks
  collisionDetection();

  // Move the ball
  x += dx;
  y += dy;
}

// Function to detect collisions with bricks
function collisionDetection() {
    for(var c = 0; c < brickColumnCount; c++) {
        for(var r = 0; r < brickRowCount; r++) {
            var b = bricks[c][r];
            if(b.status == 1) {
                if(x > b.x && x < b.x+brickWidth && y > b.y && y < b.y+brickHeight) {
                    dy = -dy;
                    b.status = 0;
                }
            }
        }
    }
}

// Function to handle game over
function gameOver() {
  clearInterval(interval); // Stop the game loop
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  
  // Display "You Lose!" message
  ctx.font = "30px Arial";
  ctx.fillStyle = "#FF0000";
  ctx.textAlign = "center";
  ctx.fillText("You Lose!", canvas.width / 2, canvas.height / 2);
  
  // Display restart button
  var restartButton = document.createElement("button");
  restartButton.innerHTML = "Restart";
  restartButton.style.position = "absolute";
  restartButton.style.left = "50%";
  restartButton.style.top = "60%";
  restartButton.style.transform = "translateX(-50%)";
  restartButton.onclick = function() {
    document.location.reload();
  };
  document.body.appendChild(restartButton);
}

// Call updateBallPosition every 10 milliseconds
var interval = setInterval(updateBallPosition, 10);
</script>
</body>
</html>
