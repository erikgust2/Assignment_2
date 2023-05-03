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
    if (key == CODED && red_tank1.userControl) {
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
    if (key == CODED && red_tank1.userControl) {
        switch (keyCode) {
            case UP:
                keyUP = false;
                red_tank1.moveUp();
                break;
            case DOWN:
                keyDOWN = false;
                red_tank1.moveDown();
                break;
            case LEFT:
                keyLEFT = false;
                red_tank1.moveLeft();
                break;
            case RIGHT:
                keyRIGHT = false;
                red_tank1.moveRight();
                break;
        }
    }
}