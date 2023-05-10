/* autogenerated by Processing revision 1292 on 2023-05-10 */
import processing.core.*;
import processing.data.*;
import processing.event.*;
import processing.opengl.*;

import java.util.HashMap;
import java.util.ArrayList;
import java.io.File;
import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;

public class Assignment_2 extends PApplet {

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

int treeColor = color(0, 128, 0);
int natoColor = color(0, 0, 255, 120);
int pactColor = color(255, 0, 0, 120);
int exploredColor = color(128, 128, 128);
int emptyColor = color(0,0,0);

Team redTeam;
Team blueTeam;

int[] redHomebase = {0,0,2,5};
int[] blueHomebase = {13,9,15,15};

Tree tree1;
Tree tree2;
Tree tree3;

Tank[] tanks = new Tank[6];

Timer timer;

public void setup() {
    /* size commented out by preprocessor */;
    for(int i = 0; i < gridSize; i++) {
        for(int j = 0; j < gridSize; j++) {
            gameBoard[i][j] = new Node(CellType.EMPTY, i, j);
        }
    }

    timer = new Timer();

    redTeam = new RedTeam(pactColor, redHomebase);
    blueTeam = new BlueTeam(natoColor, blueHomebase);

    //redTeam.tanks[0].userControl = true;
    //blueTeam.tanks[0].userControl = true;

    tanks[0] = redTeam.tanks[0];
    tanks[1] = redTeam.tanks[1];
    tanks[2] = redTeam.tanks[2];
    tanks[3] = blueTeam.tanks[0];
    tanks[4] = blueTeam.tanks[1];
    tanks[5] = blueTeam.tanks[2];

    blueTeam.init();

    tree1 = new Tree(5, 12);
    tree2 = new Tree(6, 5);
    tree3 = new Tree(11, 10);

    setGameBoard();
    //tanks[0].logic.addFrontierNodes(tanks[0].x, tanks[0].y);
    tanks[3].logic.addFrontierNodes(tanks[3].x, tanks[3].y);
}

public void draw() {
    timer.tick();
    if(tanks[0].logic.stateMachine.currentState != tankRetreatState
    || tanks[3].logic.stateMachine.currentState != tankRetreatState){
        
    }else{
        delay(50);
    }
    
    background(255);

    redTeam.updateLogic();
    blueTeam.updateLogic();
    
    for(Tank tank : tanks) {
        tank.draw();
    }

    tree1.draw();
    tree2.draw();
    tree3.draw();

    drawGrid();
    //tanks[0].logic.knownWorld.draw(pactColor);
    //tanks[3].logic.knownWorld.draw(natoColor);
    blueTeam.teamLogic.knownWorld.draw(); //<>//
}

public void drawGrid() {
    for(int i = 0; i < gridSize; i++) {
        for(int j = 0; j < gridSize; j++) {
            gameBoard[i][j].draw(color(0,0,0));
        }
    }
}

/*
    TODO:

    Assignment 2:
    - Steg 1:
        - 2/3 Tanks delar på kön för att utforska världen
    - Steg 2:
        - En prioritetskö per tank där vikterna sätts baserat på distans till närmaste tank
    - Steg 3:
        - Skjuta, Ladda om, Ta skada, etc


    - TeamLogic
    - 3 different tanks
    - How do the tanks communicate?
    - Split actions into different timings?
    - Chess?
    - 
    
    Assignment 3:
    - Shitty terrain
*/
class BlueTeam extends Team{

    BlueTeam(int _color, int[] _homebase){
        super(_color, _homebase);
        this.teamLogic = new TeamLogic(this);
        this.tanks[0] = new BlueTank(this.homebase[0] + 1, this.homebase[1] + 1, this);
        this.tanks[1] = new BlueScoutTank(this.homebase[0] + 1, this.homebase[1] + 3, this);
        this.tanks[2] = new BlueTank(this.homebase[0] + 1, this.homebase[1] + 5, this);
    }

    public void updateLogic(){
       this.teamLogic.update(); 
    }

    public void init(){
        // for(int i = this.homebase[0]; i <= this.homebase[2]; i++){
        //     for(int j = this.homebase[1]; j <= this.homebase[3]; j++){
        //         Node toAdd = new Node(i,j);
        //         toAdd.visited = true;
        //         teamLogic.knownWorld.addNode(toAdd);
        //         teamLogic.addFrontierNodes(i, j); //<>//
        //     }
        // }
    }

    class BlueTank extends Tank{
        BlueTank(int _x, int _y, Team _team){
            super(_x, _y, _team);
            this.logic = new BlueLogic(this);
        }
    }

    class BlueScoutTank extends Tank{
        BlueScoutTank(int _x, int _y, Team _team){
            super(_x, _y, _team);
            this.logic = new BlueScoutLogic(this);
            //this.logic.stateMachine = new StateMachine(scoutTankWanderState, teamLogic);
        }

        public void update(){
            teamLogic.knownWorld.nodes[x][y].visited = true;
            this.logic.update();
        }

        // Move the tank in a given direction
        public void moveRight() {
            if(!checkCollision(this.x + 1, this.y)) {
                this.x += 1;
                this.xCoord = x * 50;
                this.rotation = 0;
                //teamLogic.addFrontierNodes(this.x, this.y);
            }
        }

        public void moveLeft() {
            if(!checkCollision(this.x - 1, this.y)) {
                this.x -= 1;
                this.xCoord = x * 50;
                this.rotation = 180;
                //teamLogic.addFrontierNodes(this.x, this.y);
            }
        }

        public void moveUp() {
            if(!checkCollision(this.x, this.y - 1)) {
                this.y -= 1;
                this.yCoord = y * 50;
                this.rotation = 270;
                //teamLogic.addFrontierNodes(this.x, this.y);
            }
        }

        public void moveDown() {
            if(!checkCollision(this.x, this.y + 1)) {
                this.y += 1;
                this.yCoord = y * 50;
                this.rotation = 90;
                //teamLogic.addFrontierNodes(this.x, this.y);
            }
        }
    }

    class BlueLogic extends TankLogic{

        BlueLogic(Tank tank){
            super(tank);
        }

        public void update(){
            if(this.stateMachine.currentState == tankRetreatState){
                if(this.pathToTarget.size() == 0){
                    this.hasPath = false;
                    this.hasTarget = false;
                    this.stateMachine.changeState(tankReportState);
                }
            }else if(this.stateMachine.currentState == tankReportState){
                if(timer.getElapsedTime() >= this.logicTimer){
                    this.stateMachine.changeState(tankWanderState);
                }
            }

            this.stateMachine.update();

            if(this.hasPath && this.hasTarget){
                int[] node = this.pathToTarget.get(0);

                if(node[0] == this.tank.x
                && node[1] == this.tank.y){
                    this.pathToTarget.remove(node);
                }
                if(node[0] < this.tank.x){
                    this.tank.moveLeft();
                }else if(node[0] > this.tank.x){
                    this.tank.moveRight();
                }else if(node[1] < this.tank.y){
                    this.tank.moveUp();
                }else if(node[1] > this.tank.y){
                    this.tank.moveDown();
                }
            }
        }
    }

    class BlueScoutLogic extends BlueLogic{

        BlueScoutLogic(Tank tank){
            super(tank);
        }

        public void update(){
            if(this.stateMachine.currentState == tankRetreatState){
                if(this.pathToTarget.size() == 0){
                    this.hasPath = false;
                    this.hasTarget = false;
                    this.stateMachine.changeState(tankReportState);
                }
            }else if(this.stateMachine.currentState == tankReportState){
                if(timer.getElapsedTime() >= this.logicTimer){
                    this.stateMachine.changeState(scoutTankWanderState);
                }
            }

            this.stateMachine.update();

            if(this.hasPath && this.hasTarget){
                int[] node = this.pathToTarget.get(0);

                if(node[0] == this.tank.x
                && node[1] == this.tank.y){
                    this.pathToTarget.remove(node);
                }
                if(node[0] < this.tank.x){
                    this.tank.moveLeft();
                }else if(node[0] > this.tank.x){
                    this.tank.moveRight();
                }else if(node[1] < this.tank.y){
                    this.tank.moveUp();
                }else if(node[1] > this.tank.y){
                    this.tank.moveDown();
                }
            }
        }

        public Node getTarget(){
            if(!teamLogic.frontier.isEmpty()){
                do {
                    target = teamLogic.frontier.remove(0);
                } while (target.obstacle);
                if(target.visited == true){
                    target = this.getTarget();
                }
                if(target == null){
                    hasTarget = false;
                    stateMachine.changeState(tankIdleState);
                    return null;
                }
                println("Target: " + target.x + ", " + target.y);
                hasTarget = true;
                return target;
            }
            hasTarget = false;
            return null;
        }
    }
}
/* 
 * Authors:
 * - Erik Gustafsson
 * - August Hafvenström
 * - Petter Signell
 */

/*
 * This file holds some functions that are used to set up the game board.
 */

public void setGameBoard() {
    setHomeBase();
    setTrees();
}

public void setHomeBase() {
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

public void setTrees() {
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
public void keyPressed() {
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
public void keyReleased() {
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
/* 
 * Authors:
 * - Erik Gustafsson
 * - August Hafvenström
 * - Petter Signell
 */

 /*
  * This class is used to keep track of the nodes that have been explored.
  * It represents the tank's knowledge of the world.
  */

class KnownWorld {

    // Mirrors the world, but only contains known nodes.
    Node[][] nodes;

    // The node that the tank starts in.
    Node startNode;

    // The team
    Team team;

    // Constructor
    KnownWorld(Node startNode) {
        nodes = new Node[16][16];
        this.startNode = startNode;
        addNode(startNode);
    }

    KnownWorld(Team _team){
        this.team = _team;
        nodes = new Node[16][16];
        addBaseNodes(_team);
    }

    public void update(ArrayList<Node> newNodes) {
        for(Node node : newNodes) {
            addNode(node);
        }
    }

    // Adds a node to the known world.
    public void addNode(Node node) {
        if(nodes[node.x][node.y] == null) {
            nodes[node.x][node.y] = node;
            nodes[node.x][node.y].explored = true;
        }
    }

    public void addBaseNodes(Team team){
        for(int i = team.homebase[0]; i < team.homebase[2]; i++){
            for(int j = team.homebase[1]; j < team.homebase[3]; j++){
                if(team == redTeam){
                    nodes[i][j] = new Node(CellType.PACT, i, j);
                }else{
                    nodes[i][j] = new Node(CellType.NATO, i, j);
                }
                
            }
        }
    }

    // Draws the known world (for debugging)
    public void draw() {
        for(int i = 0; i < nodes.length; i++) {
            for(int j = 0; j < nodes[i].length; j++) {
                if(nodes[i][j] != null) {
                    nodes[i][j].draw(this.team.teamColor);
                }
            }
        }
    }
}
/* 
 * Authors:
 * - Erik Gustafsson
 * - August Hafvenström
 * - Petter Signell
 */

 /*
  * This class defines the logic of the tank.
  */

abstract class Logic {
    
    // Flags to indicate if the tank has a target and a path to the target.
    boolean hasTarget = false;
    boolean hasPath = false;

    // The target node and the path to the target.
    Node target;
    ArrayList<int[]> pathToTarget;
    ArrayList<Node> targets = new ArrayList<>();
    
    // The team that this logic is controlling
    Team team;

    // Object that contains the known world.
    KnownWorld knownWorld;

    // State machine that informs the tank of what actions to take
    StateMachine stateMachine;

    // Time to check
    int logicTimer;

    // Data structures holding the visited and frontier (known, but not yet visited) nodes.
    ArrayList<Node> visited;
    ArrayList<Node> frontier;

    Logic (){
        this.visited = new ArrayList<Node>();
        this.frontier = new ArrayList<Node>();
    }

    // Called every tick of the simulation
    public void update(){

    }

    
    
    //void getTeamPath(){
    //    pathToTarget = findPath(knownWorld.nodes[tank.x][tank.y], target);
    //    hasPath = true;
    //}

    
}
/* 
 * Authors:
 * - Erik Gustafsson
 * - August Hafvenström
 * - Petter Signell
 */

 /*
  * This class is used to represent a node on the game board.
  * It contains information about the type of node, its position on the board and if it has been explored or visited.
  */

// Enum that represents the different types of nodes on the board.
enum CellType {
    TREE, NATO, PACT, TANK, EMPTY
}

// The size of the cells on the board.
final int cellSize = 50;

class Node {

    // Enum that represents the different types of nodes on the board.
    CellType type;

    // The position of the node on the board.
    int x;
    int y;

    // Flags that represent if the node has been explored or visited.
    boolean explored = false;
    boolean visited = false;

    // Flag that represents if the node can be used as a path.
    boolean obstacle = false;

    // The weight of entering the node.
    int value = 1;

    // Constructor
    Node(CellType type, int x, int y) {
        this.type = type;
        this.x = x;
        this.y = y;
    }

    // Constructor
    Node(int x, int y){
        this.x = x;
        this.y = y;
    }

    // Method that draws the node on the board.
    // Draws it in different colors depending on the type of node.
    // If the node has been explored or visited it will also have a circle drawn on it for debugging purposes.
    public void draw(int _teamcolor) {
        if(!explored) {
            strokeWeight(1);
            if (type == CellType.TREE) {
                fill(treeColor, 50);
            } else if (type == CellType.NATO) {
                fill(natoColor, 80);
            } else if (type == CellType.PACT) {
                fill(pactColor, 90);
            } else if (type == CellType.EMPTY) {
                fill(exploredColor, 50);
            } else {
                fill(emptyColor, 50);
            }
            rect(x * cellSize, y * cellSize, cellSize, cellSize);
        } else {
            if(visited){
                fill(_teamcolor);
            }else if(explored){
                fill(0, 255 , 0, 120);
            }
            if(obstacle){
                fill(0, 0, 0, 120);
            }
            
            ellipse(x * cellSize + cellSize / 2, y * cellSize + cellSize / 2, cellSize / 2, cellSize / 2);
        }
    }
}
class RedTeam extends Team{
    RedTeam(int _color, int[] _homebase){
        super(_color, _homebase);
        this.tanks[0] = new RedTank(this.homebase[0] + 1, this.homebase[1] + 1, this);
        this.tanks[1] = new RedTank(this.homebase[0] + 1, this.homebase[1] + 3, this);
        this.tanks[2] = new RedTank(this.homebase[0] + 1, this.homebase[1] + 5, this);
    }

    public void updateLogic(){

    }

    class RedTank extends Tank{
        RedTank(int _x, int _y, Team _team){
            super(_x, _y, _team);
            this.logic = new RedLogic(this);
        }
    }

    class RedLogic extends TankLogic{

        RedLogic(Tank tank){
            super(tank);
        }

        public void update(){
            if(this.stateMachine.currentState == tankRetreatState){
                if(this.pathToTarget.size() == 0){
                    this.hasPath = false;
                    this.hasTarget = false;
                    this.stateMachine.changeState(tankReportState);
                }
            }else if(this.stateMachine.currentState == tankReportState){
                if(timer.getElapsedTime() >= this.logicTimer){
                    this.stateMachine.changeState(tankWanderState);
                }
            }

            this.stateMachine.update();

            if(this.hasPath && this.hasTarget){
                int[] node = this.pathToTarget.get(0);

                if(node[0] == this.tank.x
                && node[1] == this.tank.y){
                    this.pathToTarget.remove(node);
                }
                if(node[0] < this.tank.x){
                    this.tank.moveLeft();
                }else if(node[0] > this.tank.x){
                    this.tank.moveRight();
                }else if(node[1] < this.tank.y){
                    this.tank.moveUp();
                }else if(node[1] > this.tank.y){
                    this.tank.moveDown();
                }
            }
        }
    }
}
/* 
 * Authors:
 * - Erik Gustafsson
 * - August Hafvenström
 * - Petter Signell
 */

 /*
  * This class represents a state machine controlling the tank.
  * It works along with the logic class and the state classes to represent the artificial intelligence.
  */

class StateMachine {
    State currentState;
    TankLogic logic;

    StateMachine(State start, TankLogic logic) {
        this.currentState = start;
        this.logic = logic;
    }

    public void changeState(State newState) {
        if(currentState != newState) {
            currentState.onExit(logic);
            currentState = newState;
            currentState.onEnter(logic);
        }
    }

    public void update() {
        currentState.execute(logic);
    }

}

// Abstract class representing a state.
class State{

    public void onEnter(TankLogic logic) {}
    public void onExit(TankLogic logic) {}
    public void execute(Logic logic) {}
    public String toString() {return "";}
}

// State representing the exploring of the map.
class WanderState extends State {

    String name = "WanderState";

    public void onEnter(TankLogic logic) {
        println("WanderState onEnter");
        logic.knownWorld.nodes[logic.tank.x][logic.tank.y].visited = true;
        logic.visited.add(logic.knownWorld.nodes[logic.tank.x][logic.tank.y]);
        
        logic.addFrontierNodes(logic.tank.x, logic.tank.y);
    }

    public void onExit(TankLogic logic) {
        println("WanderState onExit");
    }

    public void execute(TankLogic logic) {
        //println("WanderState execute");

        if(!logic.hasTarget) {
            logic.getTarget();
        }
        if(logic.hasTarget){
            if(!logic.hasPath){
                logic.getPath();
            }
            if(logic.pathToTarget.size() == 0){
                logic.hasPath = false;
                logic.hasTarget = false;
            }
        }
        

    }

}

// State representing the retreat towards homebase.
class RetreatState extends State {

    String name = "RetreatState";

    public void onEnter(TankLogic logic) {
        println("RetreatState onEnter");
        logic.pathToTarget = logic.findPath(logic.knownWorld.nodes[logic.tank.x][logic.tank.y], logic.knownWorld.nodes[logic.tank.xHome][logic.tank.yHome]);
        logic.hasPath = true;
        logic.hasTarget = true;
    }

    public void onExit(TankLogic logic) {
        println("RetreatState onExit");
    }

    public void execute(TankLogic logic) {
        //println("WanderState execute");
    }

}

// State representing the tank reporting what it has seen
class ReportState extends State{
    
    String name = "ReportState";

    public void onEnter(TankLogic logic){
        logic.logicTimer = timer.setNewTimer(3000);
        println("ReportState onEnter");
    }

    public void onExit(TankLogic logic){
        println("ReportState onExit");
    }

    public void execute(TankLogic logic){

    }

}

// State representing the tank having no actions to take
class IdleState extends State{

    String name = "IdleState";

    public void onEnter(TankLogic logic){
        println("IdleState onEnter");

    }

    public void onExit(TankLogic logic){
        println("IdleState onExit");
    }

    public void execute(TankLogic logic){

    }
}

// State representing the exploring of the map.
class ScoutWanderState extends State {

    String name = "ScoutWanderState";

    public void onEnter(TankLogic logic) {
        println("ScoutWanderState onEnter");
    }

    public void onExit(TankLogic logic) {
        println("ScoutWanderState onExit");
    }

    public void execute(TankLogic logic) {
        //println("WanderState execute");

        if(!logic.hasTarget) {
            logic.getTarget();
        }
        if(logic.hasTarget){
            if(!logic.hasPath){
                logic.getPath();
            }
            if(logic.pathToTarget.size() == 0){
                logic.hasPath = false;
                logic.hasTarget = false;
            }
        }
        

    }

}

// Instances of the different tank states for use in the state machine
WanderState tankWanderState = new WanderState();
RetreatState tankRetreatState = new RetreatState();
IdleState tankIdleState = new IdleState();
ReportState tankReportState = new ReportState();
ScoutWanderState scoutTankWanderState = new ScoutWanderState();
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
    TankLogic logic;

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

        if(this.team == redTeam) {
            rotation = 0;
        } else {
            rotation = 180;
        }

        this.logic = new TankLogic(this);
    }

    // Run every frame to update the tank's state
    public void update() {
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
    public void moveRight() {
        if(!checkCollision(this.x + 1, this.y)) {
            this.x += 1;
            this.xCoord = x * 50;
            this.rotation = 0;
            logic.addFrontierNodes(this.x, this.y);
        }
    }

    public void moveLeft() {
        if(!checkCollision(this.x - 1, this.y)) {
            this.x -= 1;
            this.xCoord = x * 50;
            this.rotation = 180;
            logic.addFrontierNodes(this.x, this.y);
        }
    }

    public void moveUp() {
        if(!checkCollision(this.x, this.y - 1)) {
            this.y -= 1;
            this.yCoord = y * 50;
            this.rotation = 270;
            logic.addFrontierNodes(this.x, this.y);
        }
    }

    public void moveDown() {
        if(!checkCollision(this.x, this.y + 1)) {
            this.y += 1;
            this.yCoord = y * 50;
            this.rotation = 90;
            logic.addFrontierNodes(this.x, this.y);
        }
    }

    // Check if a given move will collide with a tree or another tank
    public boolean checkCollision(int targetX, int targetY) {
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
    public void draw() {
        stroke(0);
        strokeWeight(2);
        if (team == redTeam) {
            fill(255, 0, 0);
        } else {
            fill(0, 0, 255);
        }

        ellipse(xCoord+25, yCoord+25, 50, 50);
        strokeWeight(3);
        line(xCoord + 25, yCoord + 25, xCoord + 25 + cos(radians(this.rotation)) * 25, yCoord + 25 + sin(radians(this.rotation)) * 25);
    }
    
}
class TankLogic extends Logic {

    

    // The tank that this logic is controlling.
    Tank tank;

    // Constructor.
    public TankLogic(Tank tank) {
        super();
        this.tank = tank;
        this.knownWorld = new KnownWorld(new Node(tank.x, tank.y));
        this.stateMachine = new StateMachine(tankWanderState, this);
    }
  
    // Finds the next target node.
    // Implicitly targets in a breadth-first manner.
    public Node getTarget() {
        if(targets.size() == 0){
            return null;
        }
        Node target = targets.get(0);
        targets.remove(0);
        return target;
    }

    public void addTarget(Node target){
        targets.add(target);
    }

    public void updateMap(KnownWorld map) {
        knownWorld = map;
    }

    public ArrayList<Node> getSurroundings() {
        ArrayList<Node> surroundings = new ArrayList<>();
        
        for(int i = -1; i < 2; i++) {
            for(int j = -1; j < 2; j++) {
                int nx = tank.x + i;
                int ny = tank.y + j;
                if(nx >= 0 && nx < 16 && ny >= 0 && ny < 16) {
                    surroundings.add(knownWorld.nodes[nx][ny]);
                }
            }
        }

        return surroundings;
    }

    // Finds the closest path from current node to target node
    // Sets hasPath flag to true
    public void getPath(){
        pathToTarget = findPath(knownWorld.nodes[tank.x][tank.y], target);
        hasPath = true;
    }

    // Finds the path to the target node.
    public ArrayList<int[]> findPath(Node start, Node end) {
        Graph g = new Graph(knownWorld.nodes);
        return g.dijkstra(start, end);
    }

    // Adds the nodes adjacent to the current node to the frontier.
    public void addFrontierNodes(int x, int y){
        for(int i = -1; i <= 1; i++){
            for(int j = -1; j <= 1; j++){
                if(x + i >= 0
                && x + i <= 15
                && y + j >= 0
                && y + j <= 15
                && knownWorld.nodes[x + i][y + j] == null){
                    Node nodeToAdd = new Node(x + i, y + j);
                    if(gameBoard[x + i][y + j].type == CellType.TREE){
                        nodeToAdd.type = CellType.TREE;
                        nodeToAdd.obstacle = true;
                    }
                    for(Tank t : tanks){
                        if(t.x == nodeToAdd.x && t.y == nodeToAdd.y){
                            nodeToAdd.type = CellType.TANK;
                            nodeToAdd.obstacle = true;
                            if(t.team != tank.team){
                                stateMachine.changeState(tankRetreatState);
                            }
                        }
                    }
                    knownWorld.addNode(nodeToAdd);
                    frontier.add(nodeToAdd);
                }
            }
        }
    }

    // Help class that holds the pathfinding logic.
    // The pathfinding algorithm is Dijkstra's algorithm.
    class Graph{

        // Copy of the known world.
        Node[][] nodes;

        // Size of the input array used for the graph.
        int size;

        // Constructor.
        Graph(Node[][] nodes){
            this.nodes = nodes;
            this.size = nodes.length;
        }

        // Finds the node with the smallest distance to the source node.
        public int minDistance(int[] dist, boolean[] visited){
            int min = Integer.MAX_VALUE, minIndex = -1;
            for(int i = 0; i < size * size; i++){
                if(!visited[i] && dist[i] < min){
                    min = dist[i];
                    minIndex = i;
                }
            }
            return minIndex;
        }

        // Finds the path from the source node to the target node.
        // Uses Dijkstra's algorithm.
        public ArrayList<int[]> dijkstra(Node src, Node target){
            println("From: [" + src.x + ", " + src.y + "] to [" + target.x + ", " + target.y + "]");
            int[] dist = new int[this.size * this.size];
            int[] predecessor = new int[this.size * this.size];
            boolean[] visited = new boolean[this.size * this.size];

            for(int i = 0; i < dist.length; i++){
                dist[i] = Integer.MAX_VALUE;
                predecessor[i] = -1;
            }
            dist[src.y * size + src.x] = 0;

            int[] dx = {-1,0,1,0};
            int[] dy = {0,-1,0,1};

            outerloop:
            for(int i = 0; i < size * size -1; i++){
                int u = minDistance(dist, visited); //<>//
                println(u % size + ", " + u / size);
                visited[u] = true;

                if(u == target.y * size + target.x){
                    break;
                }

                int ux = u % size;
                int uy = u / size;
                
                for(int j = 0; j < 4; j++){
                    int vx = ux + dx[j];
                    int vy = uy + dy[j];
                    if(vx >= 0
                    && vx < size
                    && vy >= 0
                    && vy < size){
                        int v = vy * size + vx;
                        if(!visited[v]
                        && nodes[vx][vy] != null
                        && !nodes[vx][vy].obstacle
                        && dist[u] != Integer.MAX_VALUE
                        && dist[u] + nodes[vx][vy].value < dist[v]){
                            dist[v] = dist[u] + nodes[vx][vy].value;
                            predecessor[v] = u;
                        }
                    }
                }
            }
            ArrayList<int[]> path = new ArrayList<>();
            int current = target.y * size + target.x;
            while(current != -1){
                int x = current % size;
                int y = current / size;
                path.add(0, new int[]{x, y});
                current = predecessor[current];
            }

            for(int i = 0; i < path.size(); i++){
                println("[" + path.get(i)[0] + ", " + path.get(i)[1] + "]");
            }

            return path;
        }
    }

    public int getBid(Node target) {
        int bid = 0;
        int i = 0;
        int previousx = tank.x;
        int previousy = tank.y;
        ArrayList<int[]> list;

        while(i < targets.size()) {
            list = findPath(knownWorld.nodes[previousx][previousy], targets.get(i)); 
            bid += list.size(); 
            
            i++;
            previousx = targets.get(i-1).x;
            previousy = targets.get(i-1).y; 
        } 

        list = findPath(knownWorld.nodes[previousx][previousy], targets.get(i));
        bid += list.size();

        return bid;
    }

}
class Team{

    int teamColor;
    int[] homebase;
    Tank[] tanks;

    Logic teamLogic;

    Team(int _color, int[] _homebase){
        this.teamColor = _color;
        this.homebase = _homebase;
        this.tanks = new Tank[3];
    }

    public void updateLogic(){
        for(Tank t: this.tanks){
            t.update();
        }
    }

    public void init(){
        
    }



}
class TeamLogic extends Logic {

    Team team;

    TeamLogic(Team team) {
        super();
        this.team = team;
        this.knownWorld = new KnownWorld(team);
        init();
    }    

    public void init() {
        if(team.homebase[0] < 12) {
            for(int i = 0; i <= 3; i++) {
                for(int j = 0; j <= 6; j++) {
                    knownWorld.addNode(new Node(i, j));
                }
            }
        } else {
            for(int i = 15; i >= 12; i--) {
                for(int j = 15; j >= 8; j--) {
                    knownWorld.addNode(new Node(i, j));
                }
            }
        }
    }

    public void update() {
        for(Tank tank : team.tanks) {
            ArrayList<Node> tankView = tank.logic.getSurroundings();
            this.knownWorld.update(tankView);
        }
        for(Tank tank : team.tanks) {
            tank.logic.updateMap(knownWorld);
        }

        assignTargets();
    }

    public void assignTargets() {
        while(frontier.size() > 0) {
            Node target = frontier.remove(0);
            performAuction(target);
        }
    }

    public void performAuction(Node target) {
        Tank bestBidder = null;
        int bestBid = 100000;

        for(Tank tank : team.tanks) {
            int currentBid = tank.logic.getBid(target);
            if(currentBid < bestBid) {
                bestBidder = tank;
            } else if (currentBid == bestBid) {
                if(Math.random() < 0.5f) {
                    bestBidder = tank;
                }
            }
        }

        if(bestBidder != null) {
            bestBidder.logic.addTarget(target);
        }
    }

}
/* 
 * Authors:
 * - Erik Gustafsson
 * - August Hafvenström
 * - Petter Signell
 */
 
 /* 
  * This class defines a timer to keep track of elapsed time in milliseconds
  * It also allows for other classes to set new timers to check for elapsed time
  * since the timer was started
  */
 
 
 class Timer{

    int startTime;
    int elapsedTime;
    int currentTime;
    boolean isPaused;

    Timer(){
        this.startTime = millis();
        this.elapsedTime = 0;
        this.isPaused = false;
    }

    public void tick(){
        if(!isPaused){
            this.elapsedTime += timeSinceLastTick();
        }
        this.currentTime = millis();
    }

    public int setNewTimer(int mill){
        return this.elapsedTime + mill;
    }

    public int getElapsedTime(){
        return this.elapsedTime;
    }

    public int getCurrentTime(){
        return this.currentTime;
    }

    public int timeSinceLastTick(){
        return millis() - this.currentTime;
    }

    public void togglePause(){
        this.isPaused = !this.isPaused;
    }
}
/* 
 * Authors:
 * - Erik Gustafsson
 * - August Hafvenström
 * - Petter Signell
 */

 /*
  * This class represents a tree in the game.
 */

class Tree {

    // Coordinate of the tree on the game board
    int x, y;

    // Actual coordinate of the tree on the screen
    int xCoord, yCoord;
    
    // Constructor
    Tree(int x, int y) {
        this.x = x;
        this.y = y;

        xCoord = x * 50;
        yCoord = y * 50;
    }

    // Draws the tree on the screen
    public void draw() {
        fill(treeColor, 50);
        ellipse(xCoord, yCoord, 165, 165);
        fill(color(139, 69, 19));
        ellipse(xCoord, yCoord, 165/2, 165/2);
    }
}


  public void settings() { size(800, 800); }

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Assignment_2" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
