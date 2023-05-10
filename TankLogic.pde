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

    void update() {
        
    }
  
    // Finds the next target node.
    // Implicitly targets in a breadth-first manner.
    Node getTarget() {
        if(targets.size() == 0){
            return null;
        }
        target = targets.remove(0);
        while(knownWorld.nodes[target.x][target.y].obstacle) {
            target = getTarget();
        }
        hasTarget = true;
        return target;
    }

    void addTarget(Node target){
        targets.add(target);
    }

    void updateMap(KnownWorld map, ArrayList<Node> frontier) {
        knownWorld = map;
        for(Node node : frontier) {
            this.frontier.add(node);
        }
        for(Node target : targets) {
            target = knownWorld.nodes[target.x][target.y];
        }
        if(hasPath) {
            for(int[] node : pathToTarget) {
                if(knownWorld.nodes[node[0]][node[1]].obstacle) {
                    pathToTarget = findPath(knownWorld.nodes[tank.x][tank.y], target);
                    break;
                }
            }
        }
    }

    ArrayList<Node> getSurroundings() {
        ArrayList<Node> surroundings = new ArrayList<>();
        
        for(int i = -1; i < 2; i++) {
            for(int j = -1; j < 2; j++) {
                int nx = tank.x + i;
                int ny = tank.y + j;
                if(nx >= 0 && nx < 16 && ny >= 0 && ny < 16) {
                    Node nodeToAdd = new Node(nx, ny);
                    if(gameBoard[nx][ny].type == CellType.TREE){
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
                    surroundings.add(knownWorld.nodes[nx][ny]);
                }
            }
        }

        return surroundings;
    }

    // Finds the closest path from current node to target node
    // Sets hasPath flag to true
    void getPath(){
        pathToTarget = findPath(knownWorld.nodes[tank.x][tank.y], target);
        hasPath = true;
    }

    // Finds the path to the target node.
    ArrayList<int[]> findPath(Node start, Node end) {
        Graph g = new Graph(knownWorld.nodes);
        return g.dijkstra(start, end);
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

    int getBid(Node target){
        int bid = 0;
        int i = 0;
        int previousx = tank.x;
        int previousy = tank.y;
        ArrayList<int[]> list;
  
        while( i < targets.size()){
            list = findPath(knownWorld.nodes[previousx][previousy], targets.get(i));
            bid += list.size();
            previousx = targets.get(i).x;
            previousy = targets.get(i).y;
            i++;
        }
        list = findPath(knownWorld.nodes[previousx][previousy], target);
        bid += list.size();
        return bid;
    }

}