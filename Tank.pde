/* 
 * Authors:
 * - Erik Gustafsson
 * - August Hafvenström
 * - Petter Signell
 */

/*
 * This class is used to represent tanks for both NATO and the Warsaw Pact.
 * It contains the logic for drawing the tanks and moving them around the map.
 */

// Enum for the two teams
enum Team {
    PACT, NATO
}

class Tank {
    // Coordinates of the tank on the game board
    int x, y;
    int xHome, yHome;

    // Real coordinates of the tank on the screen
    int xCoord, yCoord;

    // Rotation of the tank
    float rotation;

    // Team of the tank (PACT or NATO)
    Team team;

    // Instance of the logic class which is used for the AI
    Logic logic;

    // Boolean for if the tank is controlled by the user or AI
    boolean userControl;

    // Constructor for the tank class
    Tank(int x, int y, Team team) {
        this.x = x;
        this.y = y;
        this.xHome = x;
        this.yHome = y;
        this.team = team;

        xCoord = x * 50;
        yCoord = y * 50;

        if(team == Team.PACT) {
            rotation = 0;
        } else {
            rotation = 180;
        }

        this.logic = new Logic(this);
    }

    // Run every frame to update the tank's state
    void update() {
        /* for(int i = this.x - 1; i <= this.x + 1; i++) {
            for(int j = this.y - 1; j <= this.y + 1; j++) {
                if(i < 0 || i > 15 || j < 0 || j > 15)
                    continue;
                knownWorld.addNode(gameBoard[i][j]);
            }
        }*/
        logic.knownWorld.nodes[x][y].visited = true;
        this.logic.update();
    }

    // Move the tank in a given direction
    void moveRight() {
        if(!checkCollision(this.x + 1, this.y)) {
            this.x += 1;
            this.xCoord = x * 50;
            this.rotation = 0;
            logic.addFrontierNodes(this.x, this.y);
        }
    }

    void moveLeft() {
        if(!checkCollision(this.x - 1, this.y)) {
            this.x -= 1;
            this.xCoord = x * 50;
            this.rotation = 180;
            logic.addFrontierNodes(this.x, this.y);
        }
    }

    void moveUp() {
        if(!checkCollision(this.x, this.y - 1)) {
            this.y -= 1;
            this.yCoord = y * 50;
            this.rotation = 270;
            logic.addFrontierNodes(this.x, this.y);
        }
    }

    void moveDown() {
        if(!checkCollision(this.x, this.y + 1)) {
            this.y += 1;
            this.yCoord = y * 50;
            this.rotation = 90;
            logic.addFrontierNodes(this.x, this.y);
        }
    }

    // Check if a given move will collide with a tree or another tank
    boolean checkCollision(int targetX, int targetY) {
        if(targetX < 0 || targetX > 15 || targetY < 0 || targetY > 15) {
            return true;
        }

        Node targetNode = gameBoard[targetX][targetY];
        if(targetNode.type == CellType.TREE) {
            logic.knownWorld.nodes[targetX][targetY].type = CellType.TREE;
            logic.knownWorld.nodes[targetX][targetY].obstacle = true;
            return true;
        }

        for(Tank tank : tanks) {
            if(tank.x == targetX && tank.y == targetY) {
                logic.knownWorld.nodes[targetX][targetY].type = CellType.TANK;
                logic.knownWorld.nodes[targetX][targetY].obstacle = true;
                return true;
            }
        }

        return false;
    }

    // Draw the tank on the screen each frame
    void draw() {
        stroke(0);
        strokeWeight(2);
        if (team == Team.PACT) {
            fill(255, 0, 0);
        } else {
            fill(0, 0, 255);
        }

        ellipse(xCoord+25, yCoord+25, 50, 50);
        strokeWeight(3);
        line(xCoord + 25, yCoord + 25, xCoord + 25 + cos(radians(this.rotation)) * 25, yCoord + 25 + sin(radians(this.rotation)) * 25);
    }
    
}