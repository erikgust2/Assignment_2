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

    // The tank that this logic is controlling.
    Tank tank;

    // Flags to indicate if the tank has a target and a path to the target.
    boolean hasTarget = false;
    boolean hasPath = false;

    // Object that contains the known world.
    KnownWorld knownWorld;

    // State machine that informs the tank of what actions to take
    StateMachine stateMachine;

    // Time to check
    int logicTimer;

    // The target node and the path to the target.
    Node target;
    ArrayList<int[]> pathToTarget;

    // Data structures holding the visited and frontier (known, but not yet visited) nodes.
    ArrayList<Node> visited;
    ArrayList<Node> frontier;

    // Constructor.
    public Logic(Tank tank) {
        this.tank = tank;
        visited = new ArrayList<Node>();
        frontier = new ArrayList<Node>();
        this.knownWorld = new KnownWorld(new Node(tank.x, tank.y));
        this.stateMachine = new StateMachine(tankWanderState, this);
    }

    // Called every tick of the simulation
    void update(){

        if(stateMachine.currentState == tankRetreatState){
            if(pathToTarget.size() == 0){
                hasPath = false;
                hasTarget = false;
                stateMachine.changeState(tankReportState);
            }
        }else if(stateMachine.currentState == tankReportState){
            if(timer.getElapsedTime() >= logicTimer){
                stateMachine.changeState(tankWanderState);
            }
        }

        stateMachine.update();

        if(hasPath && hasTarget){
            int[] node = pathToTarget.get(0);

            if(node[0] == tank.x
            && node[1] == tank.y){
                pathToTarget.remove(node);
            }
            if(node[0] < tank.x){
                tank.moveLeft();
            }else if(node[0] > tank.x){
                tank.moveRight();
            }else if(node[1] < tank.y){
                tank.moveUp();
            }else if(node[1] > tank.y){
                tank.moveDown();
            }
        }

    }

    // Finds the next target node.
    // Implicitly targets in a breadth-first manner.
    Node getTarget() {
        if(!frontier.isEmpty()){
            do {
                target = frontier.remove(0);
            } while (target.obstacle);
            if(target.visited == true){
                target = getTarget();
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

    // Finds the closest path from current node to target node
    // Sets hasPath flag to true
    void getPath(){
        pathToTarget = findPath(knownWorld.nodes[tank.x][tank.y], target);
        hasPath = true;
    }

    // Adds the nodes adjacent to the current node to the frontier.
    void addFrontierNodes(int x, int y){
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

    // Finds the path to the target node.
    ArrayList<int[]> findPath(Node start, Node end) {
        Graph g = new Graph(knownWorld.nodes);
        return g.dijkstra(start, end);
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
        int minDistance(int[] dist, boolean[] visited){
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
        ArrayList<int[]> dijkstra(Node src, Node target){
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
                int u = minDistance(dist, visited);
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

}