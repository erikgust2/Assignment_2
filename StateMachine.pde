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
    Logic logic;

    StateMachine(State start, Logic logic) {
        this.currentState = start;
        this.logic = logic;
    }

    void changeState(State newState) {
        if(currentState != newState) {
            currentState.onExit(logic);
            currentState = newState;
            currentState.onEnter(logic);
        }
    }

    void update() {
        currentState.execute(logic);
    }

}

// Abstract class representing a state.
class State{

    void onEnter(Logic logic) {}
    void onExit(Logic logic) {}
    void execute(Logic logic) {}
    String toString() {return "";}
}

// State representing the exploring of the map.
class WanderState extends State {

    String name = "WanderState";

    void onEnter(Logic logic) {
        println("WanderState onEnter");
        logic.knownWorld.nodes[logic.tank.x][logic.tank.y].visited = true;
        logic.visited.add(logic.knownWorld.nodes[logic.tank.x][logic.tank.y]);
        
        logic.addFrontierNodes(logic.tank.x, logic.tank.y);
    }

    void onExit(Logic logic) {
        println("WanderState onExit");
    }

    void execute(Logic logic) {
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

    void onEnter(Logic logic) {
        println("RetreatState onEnter");
        logic.pathToTarget = logic.findPath(logic.knownWorld.nodes[logic.tank.x][logic.tank.y], logic.knownWorld.nodes[logic.tank.xHome][logic.tank.yHome]);
        logic.hasPath = true;
        logic.hasTarget = true;
    }

    void onExit(Logic logic) {
        println("RetreatState onExit");
    }

    void execute(Logic logic) {
        //println("WanderState execute");
    }

}

// State representing the tank reporting what it has seen
class ReportState extends State{
    
    String name = "ReportState";

    void onEnter(Logic logic){
        logic.logicTimer = timer.setNewTimer(3000);
        println("ReportState onEnter");
    }

    void onExit(Logic logic){
        println("ReportState onExit");
    }

    void execute(Logic logic){

    }

}

// State representing the tank having no actions to take
class IdleState extends State{

    String name = "IdleState";

    void onEnter(Logic logic){
        println("IdleState onEnter");

    }

    void onExit(Logic logic){
        println("IdleState onExit");
    }

    void execute(Logic logic){

    }
}

// State representing the exploring of the map.
class ScoutWanderState extends State {

    String name = "ScoutWanderState";

    void onEnter(Logic logic) {
        println("ScoutWanderState onEnter");
    }

    void onExit(Logic logic) {
        println("ScoutWanderState onExit");
    }

    void execute(Logic logic) {
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