/* 
 * Authors:
 * - Erik Gustafsson
 * - August Hafvenström
 * - Petter Signell
 */

/*
 * This file holds some functions that are used to set up the game board.
 */

void setGameBoard() {
    setHomeBase();
    setTrees();
}

void setHomeBase() {
    for(int i = 0; i < 3; i++) {
        for(int j = 0; j < 7; j++){
            gameBoard[i][j].type = CellType.PACT;
        }
    }

    for(int i = 15; i > 12; i --) {
        for(int j = 15; j > 8; j--) {
            gameBoard[i][j].type = CellType.NATO;
        }
    }
}

void setTrees() {
    for(int i = 4; i < 6; i ++) {
        for(int j = 11; j < 13; j++) {
            gameBoard[i][j].type = CellType.TREE;
        }
    }

    for(int i = 5; i < 7; i ++) {
        for(int j = 4; j < 6; j++) {
            gameBoard[i][j].type = CellType.TREE;
        }
    }

    for(int i = 10; i < 12; i ++) {
        for(int j = 9; j < 11; j++) {
            gameBoard[i][j].type = CellType.TREE;
        }
    }
}