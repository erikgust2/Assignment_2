/* 
 * Authors:
 * - Erik Gustafsson
 * - August Hafvenström
 * - Petter Signell
 */

 /*
 * This is the main class for the game. It contains the main method and the setup method.
 * The setup method is called once at the beginning of the game. The main method is called
 * every frame.
 */

int gridSize = 16;
Node gameBoard[][] = new Node[gridSize][gridSize];

color treeColor = color(0, 128, 0);
color natoColor = color(0, 0, 255);
color pactColor = color(255, 0, 0);
color exploredColor = color(128, 128, 128);
color emptyColor = color(0,0,0);

Tank red_tank1;
Tank red_tank2;
Tank red_tank3;
Tank blue_tank1;
Tank blue_tank2;
Tank blue_tank3;

Tree tree1;
Tree tree2;
Tree tree3;

Tank[] tanks = new Tank[6];

Timer timer;

void setup() {
    size(800, 800);
    for(int i = 0; i < gridSize; i++) {
        for(int j = 0; j < gridSize; j++) {
            gameBoard[i][j] = new Node(CellType.EMPTY, i, j);
        }
    }

    timer = new Timer();

    red_tank1 = new Tank(1, 1, Team.PACT);
    red_tank1.userControl = true;
    red_tank2 = new Tank(1, 3, Team.PACT);
    red_tank3 = new Tank(1, 5, Team.PACT);
    blue_tank1 = new Tank(14, 10, Team.NATO);
    blue_tank2 = new Tank(14, 12, Team.NATO);
    blue_tank3 = new Tank(14, 14, Team.NATO);

    tanks[0] = red_tank1;
    tanks[1] = red_tank2;
    tanks[2] = red_tank3;
    tanks[3] = blue_tank1;
    tanks[4] = blue_tank2;
    tanks[5] = blue_tank3;

    tree1 = new Tree(5, 12);
    tree2 = new Tree(6, 5);
    tree3 = new Tree(11, 10);

    setGameBoard();
    red_tank1.logic.addFrontierNodes(red_tank1.x, red_tank1.y);
}

void draw() {
    timer.tick();
    if(red_tank1.logic.stateMachine.currentState != tankRetreatState){
        
    }else{
        delay(50);
    }
    
    background(255);
    
    for(Tank tank : tanks) {
        tank.update();
        tank.draw();
    }

    tree1.draw();
    tree2.draw();
    tree3.draw();

    drawGrid();
    red_tank1.logic.knownWorld.draw();
}

void drawGrid() {
    for(int i = 0; i < gridSize; i++) {
        for(int j = 0; j < gridSize; j++) {
            gameBoard[i][j].draw();
        }
    }
}
