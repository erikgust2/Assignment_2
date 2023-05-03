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

    // Adds a node to the known world.
    void addNode(Node node) {
        if(nodes[node.x][node.y] == null) {
            nodes[node.x][node.y] = node;
            nodes[node.x][node.y].explored = true;
        }
    }

    void addBaseNodes(Team team){
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
    void draw() {
        for(int i = 0; i < nodes.length; i++) {
            for(int j = 0; j < nodes[i].length; j++) {
                if(nodes[i][j] != null) {
                    nodes[i][j].draw(this.team.teamColor);
                }
            }
        }
    }
}