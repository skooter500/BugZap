import ddf.minim.*;
import procontroll.*;
import de.ilu.movingletters.*;

Minim minim;//audio context
AudioPlayer explosion;
AudioPlayer shoot;
AudioPlayer bug;
AudioPlayer landed;

int gameState = 0;

int CENTRED = -1;
MovingLetters[] letters = new MovingLetters[3];

float bugX, bugY;
float bugWidth = 30;
float halfBugWidth = bugWidth / 2;
float playerX, playerY;
float playerWidth = 40;
float playerSpeed = 3;
int score;

boolean sketchFullScreen() {
  return true;
}

void playSound(AudioPlayer sound)
{
  if (sound == null)
  {
    return;
  }
  sound.rewind();
  sound.play(); 
}

void setup()
{
  size(displayWidth, displayHeight);
  noCursor();
  
  for (font_size size:font_size.values())
  {
    letters[size.index] = new MovingLetters(this, size.size, 1, 0);
  } 
  minim = new Minim(this);
  reset();        
  
  explosion = minim.loadFile("Explosion4.wav");
  shoot = minim.loadFile("laser1.wav");
  bug = minim.loadFile("blip.wav");
  landed = minim.loadFile("landed.wav");
}

void printText(String text, font_size size, int x, int y)
{
  if (x == CENTRED)
  {
    x = (width / 2) - (int) (size.size * (float) text.length() / 2.5f);
  }
  letters[size.index].text(text, x, y);  
}

void splash()
{
  background(0);
  stroke(255);
  printText("BugZap!", font_size.large, CENTRED, 100);  
  printText("Programmed by Bryan Duggan", font_size.large, CENTRED, 200);
  printText("Press SPACE to play", font_size.large, CENTRED, 300);  
  if (keyPressed && key == ' ')
  {
    reset();
    gameState = 1;
  }
}

void reset()
{
  score = 0;
  gameCount = 0;
  resetBug();
  playerX = width / 2;
  playerY = height - 50;
}

void drawBug(float x, float y)
{
    // Draw the bug
  stroke(255);
  float saucerHeight = bugWidth * 0.7f;
  line(bugX + halfBugWidth, bugY, bugX, bugY + saucerHeight);
  line(bugX + halfBugWidth, bugY, bugX + bugWidth, bugY + saucerHeight);
  line(bugX, bugY + saucerHeight, bugX + bugWidth, bugY + saucerHeight);
  float feet = bugWidth * 0.2f;
  line(bugX + feet, bugY + saucerHeight, bugX, bugY + bugWidth);
  line(bugX + bugWidth - feet, bugY + saucerHeight, bugX + bugWidth, bugY + bugWidth);
  feet = bugWidth * 0.4f;
  line(bugX + feet, bugY + saucerHeight, bugX, bugY + bugWidth);
  line(bugX + bugWidth - feet, bugY + saucerHeight, bugX + bugWidth, bugY + bugWidth);
  line(bugX + feet, bugY + feet, bugX + feet, bugY + feet * 1.1f);  
  line(bugX + bugWidth - feet, bugY + feet, bugX + bugWidth - feet, bugY + feet * 1.1f);
  line(bugX + feet, bugY + feet * 1.4f, bugX + bugWidth - feet, bugY + feet * 1.4f); 
}

void drawPlayer(float x, float y)
{
  float playerHeight = playerWidth / 2;
  line(playerX, playerY + playerHeight, playerX + playerWidth, playerY + playerHeight);
  line(playerX, playerY + playerHeight, playerX, playerY + playerHeight * 0.5f);
  line(playerX + playerWidth, playerY + playerHeight, playerX + playerWidth, playerY + playerHeight * 0.5f);
  
  line(playerX, playerY + playerHeight * 0.5f, playerX + playerWidth * 0.2f, playerY + playerHeight * 0.3f);
  line(playerX + playerWidth, playerY + playerHeight * 0.5f, playerX + playerWidth * 0.8f, playerY + playerHeight * 0.3f);
  line(playerX + playerWidth * 0.2f, playerY + playerHeight * 0.3f, playerX + playerWidth * 0.8f, playerY + playerHeight * 0.3f);
  line(playerX + playerWidth * 0.5f, playerY, playerX + playerWidth * 0.5f, playerY + playerHeight * 0.3f); 
}

/*
void keyPressed()
{
  if (gameState == 1)
  {    
    if (keyCode == LEFT)
    {      
      playerX -= 1;
    }
    if (keyCode == RIGHT)
    {
      playerX += 1;
    }
  }
}
*/

void resetBug()
{
  bugX = random(0, width);
  bugY = 10;
  frame = 60;
}

int frame;
int gameCount = 0;

void game()
{
   drawBug(bugX, bugY); 
   drawPlayer(playerX, playerY);
   if (keyPressed)
   {
     if (keyCode == LEFT)
     {
       playerX -= playerSpeed;
     }
     if (keyCode == RIGHT)
     {
       playerX += playerSpeed;
     }
     if (keyCode == UP)
     {
       // Check for colision
       float x = (int) playerX + playerWidth / 2;
       float y = 0;
       if ((x >= bugX) && (x <= bugX + bugWidth))
       {
         y = bugY + bugWidth;
         resetBug();
         score ++;
         playSound(explosion);
       } 
       else
       {
         playSound(shoot);
       }   
       line(x, playerY, x, y);
     }     
   }   
   
   if (gameCount % frame == 0)
   {
     bugX += random(-100, 100);
     bugY += 30;
     frame -= 1;
     playSound(bug);
   }
   
   gameCount ++;
   
   if (bugX < 0 )
   {
     bugX = 0;
   }
   
   if (bugX + bugWidth > width)
   {
     bugX = width - bugWidth;
   }
   
   if (bugY + bugWidth > playerY)
   {
     gameState = 2;
     playSound(landed);
   }

   printText("Score: " + score, font_size.small, 10, 10);
}

void gameOver()
{
  background(0);
  fill(255);
  stroke(255);
  printText("BugZap!", font_size.large, CENTRED, 200);
  printText("Score: " + score, font_size.large, CENTRED, 500);
  if (frameCount / 60 % 2 == 0)
  {
    printText("Game Over", font_size.large, CENTRED, 350);
    
  }
  stroke(255);  
  printText("Press SPACE to play", font_size.large, CENTRED, 650);  
  if (keyPressed && key == ' ')
  {
    gameState = 0;
  }
}

void draw()
{
  background(0);
  
  switch (gameState)
  {
    case 0:
      splash();
      break;
    case 1:
      game();
      break;
    case 2:
      gameOver();
      break;  
  }
}
