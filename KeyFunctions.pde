/* 
 * Authors:
 * - Erik Gustafsson
 * - August Hafvenström
 * - Petter Signell
 */

 /*
  * This class handles user input for the purpose
  * of moving the tank.
  */

boolean keyUP, keyDOWN, keyLEFT, keyRIGHT = false;

// Handles the pressing of keys.
void keyPressed() {
    if (key == CODED && tanks[0].userControl) {
        switch (keyCode) {
            case UP:
                keyUP = true;
                break;
            case DOWN:
                keyDOWN = true;
                break;
            case LEFT:
                keyLEFT = true;
                break;
            case RIGHT:
                keyRIGHT = true;
                break;
        }
    }
}

// Handles the release of keys, and thus movement of the tank.
void keyReleased() {
    if (key == CODED && tanks[0].userControl) {
        switch (keyCode) {
            case UP:
                keyUP = false;
                tanks[0].moveUp();
                break;
            case DOWN:
                keyDOWN = false;
                tanks[0].moveDown();
                break;
            case LEFT:
                keyLEFT = false;
                tanks[0].moveLeft();
                break;
            case RIGHT:
                keyRIGHT = false;
                tanks[0].moveRight();
                break;
        }
    }
}