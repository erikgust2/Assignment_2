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
    void update(){

    }

    
    
    //void getTeamPath(){
    //    pathToTarget = findPath(knownWorld.nodes[tank.x][tank.y], target);
    //    hasPath = true;
    //}

    
}
