class BlueTeam extends Team{

    BlueTeam(color _color, int[] _homebase){
        super(_color, _homebase);
        this.teamLogic = new TeamLogic(this);
        this.tanks[0] = new BlueTank(this.homebase[0] + 1, this.homebase[1] + 1, this);
        this.tanks[1] = new BlueTank(this.homebase[0] + 1, this.homebase[1] + 3, this);
        this.tanks[2] = new BlueTank(this.homebase[0] + 1, this.homebase[1] + 5, this);
    }

    void updateLogic(){
        System.out.println("Blue Team Logic");
        super.updateLogic();
        this.teamLogic.update(); 
    }

    void init(){
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
            this.logic.stateMachine.logic = this.logic;
        }
    }

    class BlueScoutTank extends Tank{
        BlueScoutTank(int _x, int _y, Team _team){
            super(_x, _y, _team);
            this.logic = new BlueScoutLogic(this);
            //this.logic.stateMachine = new StateMachine(scoutTankWanderState, teamLogic);
        }

        void update(){
            teamLogic.knownWorld.nodes[x][y].visited = true;
            this.logic.update();
        }

        // Move the tank in a given direction
        void moveRight() {
            if(!checkCollision(this.x + 1, this.y)) {
                this.x += 1;
                this.xCoord = x * 50;
                this.rotation = 0;
                //teamLogic.addFrontierNodes(this.x, this.y);
            }
        }

        void moveLeft() {
            if(!checkCollision(this.x - 1, this.y)) {
                this.x -= 1;
                this.xCoord = x * 50;
                this.rotation = 180;
                //teamLogic.addFrontierNodes(this.x, this.y);
            }
        }

        void moveUp() {
            if(!checkCollision(this.x, this.y - 1)) {
                this.y -= 1;
                this.yCoord = y * 50;
                this.rotation = 270;
                //teamLogic.addFrontierNodes(this.x, this.y);
            }
        }

        void moveDown() {
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

        void update(){
            System.out.println("Blue Tank Logic");
            super.update();
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
            }else if(this.stateMachine.currentState == tankWanderState){
                if(this.logicTimer >= timer.getElapsedTime()){
                    return;
                }
            }

            this.stateMachine.update();

            if(this.hasPath && this.hasTarget){

                if(this.knownWorld.nodes[target.x][target.y].obstacle) {
                    this.hasTarget = false;
                    this.hasPath = false;
                    return;
                }

                int[] node = this.pathToTarget.get(0);

                if(node[0] == this.tank.x
                && node[1] == this.tank.y){
                    this.pathToTarget.remove(node);
                }
                if(knownWorld.nodes[node[0]][node[1]].obstacle){
                    ArrayList<int[]> newPath = findPath(new Node(this.tank.x, this.tank.y), target);
                    pathToTarget.remove(0);
                    for(int i = 0; i < newPath.size(); i++){
                        pathToTarget.add(0, newPath.get(i));
                    }
                    for(Tank t: this.tank.team.tanks){
                        if(t.x == node[0]
                        && t.y == node[1]){
                            t.logic.logicTimer = timer.setNewTimer(100);
                        }
                    }
                    return;
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

        void update(){
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
                System.out.println("Heading towards " + this.target.x + ", " + this.target.y);
                int[] node = this.pathToTarget.get(0);

                if(node[0] == this.tank.x
                && node[1] == this.tank.y){
                    this.pathToTarget.remove(node);
                } else if (this.pathToTarget.get(1)[0] == target.x && this.pathToTarget.get(1)[1] == target.y) {
                    this.pathToTarget.remove(0);
                    this.pathToTarget.remove(0);
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

        Node getTarget(){
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
