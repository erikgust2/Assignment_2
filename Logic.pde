/* 
 * Authors:
 * - Erik Gustafsson
 * - August Hafvenström
 * - Petter Signell
 */

 /*
  * This class defines the logic of the tank.
  */

class Logic {

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

    // Constructor.
    public Logic(Tank tank) {
        this.tank = tank;
        this.knownWorld = new KnownWorld(new Node(tank.x, tank.y));
        this.stateMachine = new StateMachine(tankWanderState, this);
        this.visited = new ArrayList<Node>();
        this.frontier = new ArrayList<Node>(); 
    }

    Logic (Team team){
        this.team = team;
        this.knownWorld = new KnownWorld(team);
        this.visited = new ArrayList<Node>();
        this.frontier = new ArrayList<Node>();
    }

    // Called every tick of the simulation
    void update(){

    }

    // Finds the closest path from current node to target node
    // Sets hasPath flag to true
    void getPath(){
        pathToTarget = findPath(knownWorld.nodes[tank.x][tank.y], target);
        hasPath = true;
    }
    
    void getTeamPath(){
        pathToTarget = findPath(knownWorld.nodes[tank.x][tank.y], target);
        hasPath = true;
    }

}
