class BlueTeam extends Team{

    BlueTeam(color _color, int[] _homebase){
        super(_color, _homebase);
        this.teamLogic = new TeamLogic(this);
        this.tanks[0] = new BlueTank(this.homebase[0] + 1, this.homebase[1] + 1, 3, this);
        //this.tanks[1] = new DummyTank(this.homebase[0] + 1, this.homebase[1] + 3, 4, this);
        this.tanks[2] = new BlueTank(this.homebase[0] + 1, this.homebase[1] + 5, 5, this);
        init();
    }

    void updateLogic(){
        //System.out.println("Blue Team Logic");
        super.updateLogic();
        this.teamLogic.update(); 
    }

    void init(){
        for(Tank t: this.tanks){
            if(t != null){
                teamLogic.knownWorld.nodes[t.x][t.y].obstacle = true;
            }
        }
    }

    class BlueTank extends Tank{
        BlueTank(int _x, int _y, int _id, Team _team){
            super(_x, _y, _id, _team);
            this.logic = new BlueLogic(this);
            this.logic.stateMachine.logic = this.logic;
        }
    }

    class DummyTank extends Tank{
        DummyTank(int _x, int _y, int _id, Team _team){
            super(_x, _y, _id, _team);
        }
    }
    /*
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
    }*/

    class BlueLogic extends TankLogic{

        BlueLogic(Tank tank){
            super(tank);
        }

        void update(){
            //System.out.println("Blue Tank Logic");
            super.update();

            // State checks and changes
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
            }else if(this.stateMachine.currentState == tankWaitingState){
                if(this.logicTimer >= timer.getElapsedTime()){
                    return;
                }else{
                    this.stateMachine.changeState(tankWanderState);
                }
            }

            this.stateMachine.update();

            if(this.hasPath && this.hasTarget){

                int[] node = this.pathToTarget.get(0);

                // Arrived at node check
                if(node[0] == this.tank.x
                && node[1] == this.tank.y){
                    this.pathToTarget.remove(0);
                }else{
                    //ArrayList<int[]> failsafe = findPath(this.knownWorld.nodes[this.tank.x][this.tank.y], this.knownWorld.nodes[node[0]][node[1]]);
                    //for(int i = failsafe.size() - 1; i >= 0; i--){
                    //    this.pathToTarget.add(0, failsafe.get(i));
                    //}
                }
                // Arrived at target check
                if(pathToTarget.size() == 0){
                    this.hasPath = false;
                    this.hasTarget = false;
                    return;
                }

                node = this.pathToTarget.get(0);

                // Collision check
                for(Tank t: this.tank.team.tanks){
                    if(t == null){
                        continue;
                    }
                    if(t.id != this.tank.id
                    && t.x == node[0]
                    && t.y == node[1]){
                        this.pathToTarget = findPath(this.knownWorld.nodes[this.tank.x][this.tank.y], this.knownWorld.nodes[this.target.x][this.target.y]);
                    }
                }
                for(Tree t: trees){
                    if(t.x == node[0]
                    && t.y == node[1]){
                        this.pathToTarget = findPath(this.knownWorld.nodes[this.tank.x][this.tank.y], this.knownWorld.nodes[this.target.x][this.target.y]);
                    }
                }

                // Movement
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

        void remakePaths(Tank tank1, Tank tank2){
            ArrayList<int[]> path1 = tank1.logic.pathToTarget;
            ArrayList<int[]> path2 = tank2.logic.pathToTarget;

            if(path1.size() < 2){
                tank1.logic.hasPath = false;
                tank1.logic.hasTarget = false;
                return;
            }

            if(path2.size() < 2){
                tank2.logic.hasPath = false;
                tank2.logic.hasTarget = false;
            }

            String error = "[path1.size() = " + path1.size() + "][path2.size() = " + path2.size() +"]";

            if(!tank2.logic.hasTarget && path1.size() > 2){
                error += "[tank2 no target]";
                // Tank 1 above tank 2
                if(tank1.y > tank2.y){
                    error += "[tank1 above tank2]";
                    // Tank 1 going down
                    if(path1.get(0)[1] > tank1.y){
                        error += "[tank1 going down]";
                        // Tank 1 going down
                        if(path1.get(1)[1] > path1.get(0)[1]){
                            error += "[tank1 going down]";
                            path1.remove(0);
                            path1.remove(0);
                            if(tank2.x < 8){
                                path1.add(0, new int[]{tank1.x + 1, tank1.y});
                                path1.add(1, new int[]{tank1.x + 1, tank1.y + 1});
                                path1.add(2, new int[]{tank1.x + 1, tank1.y + 2});
                                path1.add(3, new int[]{tank1.x, tank1.y + 2});
                            }else{
                                path1.add(0, new int[]{tank1.x - 1, tank1.y});
                                path1.add(1, new int[]{tank1.x - 1, tank1.y + 1});
                                path1.add(2, new int[]{tank1.x - 1, tank1.y + 2});
                                path1.add(3, new int[]{tank1.x, tank1.y + 2});
                            }
                        // Tank 1 going right
                        }else if(path1.get(1)[0] > path1.get(0)[0]){
                            error += "[tank1 going right]";
                            path1.remove(0);
                            path1.remove(0);
                            path1.add(0, new int[]{tank1.x + 1, tank1.y});
                            path1.add(1, new int[]{tank1.x + 1, tank1.y + 1});
                        // Tank 1 going left
                        }else{
                            error += "[tank1 going left]";
                            path1.remove(0);
                            path1.remove(0);
                            path1.add(0, new int[]{tank1.x - 1, tank1.y});
                            path1.add(1, new int[]{tank1.x - 1, tank1.y + 1});
                        }    
                    }
                // Tank 1 below tank 2
                }else if(tank2.y > tank1.y){
                    error += "[tank1 below tank2]";
                    // Tank 1 going up
                    if(path1.get(0)[1] < tank1.y){
                        error += "[tank1 going up]";
                        // Tank 1 going up
                        if(path1.get(1)[1] < path1.get(0)[1]){
                            error += "[tank1 going up]";
                            path1.remove(0);
                            path1.remove(0);
                            if(tank2.x < 8){
                                path1.add(0, new int[]{tank1.x + 1, tank1.y});
                                path1.add(1, new int[]{tank1.x + 1, tank1.y - 1});
                                path1.add(2, new int[]{tank1.x + 1, tank1.y - 2});
                                path1.add(3, new int[]{tank1.x, tank1.y - 2});
                            }else{
                                path1.add(0, new int[]{tank1.x - 1, tank1.y});
                                path1.add(1, new int[]{tank1.x - 1, tank1.y - 1});
                                path1.add(2, new int[]{tank1.x - 1, tank1.y - 2});
                                path1.add(3, new int[]{tank1.x, tank1.y - 2});
                            }
                        // Tank 1 going right
                        }else if(path1.get(1)[0] > path1.get(0)[0]){
                            error += "[tank1 going right]";
                            path1.remove(0);
                            path1.remove(0);
                            path1.add(0, new int[]{tank1.x + 1, tank1.y});
                            path1.add(1, new int[]{tank1.x + 1, tank1.y - 1});
                        // Tank 1 going left
                        }else{
                            error += "[tank1 going left]";
                            path1.remove(0);
                            path1.remove(0);
                            path1.add(0, new int[]{tank1.x - 1, tank1.y});
                            path1.add(1, new int[]{tank1.x - 1, tank1.y - 1});
                        }    
                    }
                }else if(tank1.x < tank2.x){

                }else if(tank1.x > tank2.x){

                }
            // Tank 1 above tank 2
            } else if(tank1.y > tank2.y){
                error += "[tank2 has target]";
                error += "[tank1 above tank2]";
                // Tank 1 going down
                println(path1.get(0)[1] + "?" + tank1.y);
                if(path1.get(0)[1] > tank1.y){
                    error += "[tank1 going down]";
                    // Tank 1 going down
                    if(path1.get(1)[1] > path1.get(0)[1]){
                        error += "[tank1 going down]";
                        // Tank 2 going up
                        if(path2.get(0)[1] < tank2.y){
                            error += "[tank2 going up]";
                            if(tank2.x < 8){
                                path2.remove(0);
                                path2.add(0, new int[]{tank2.x + 1, tank2.y});
                                path2.add(1, new int[]{tank2.x + 1, tank2.y - 1});
                                path2.add(2, new int[]{tank2.x, tank2.y - 1});
                            }else{
                                path2.remove(0);
                                path2.add(0, new int[]{tank2.x - 1, tank2.y});
                                path2.add(1, new int[]{tank2.x - 1, tank2.y - 1});
                                path2.add(2, new int[]{tank2.x, tank2.y - 1});
                            }
                        }else{
                            return;
                        }
                    // Tank 1 going right
                    }else if(path1.get(1)[0] > path1.get(0)[0]){
                        error += "[tank1 going right]";
                        // Tank 2 going up
                        if(path2.get(0)[1] < tank2.y){
                            error += "[tank2 going up]";
                            // Tank 2 going left
                            if(path2.get(1)[0] < path2.get(0)[0]){
                                error += "[tank2 going left]";
                                path2.remove(0);
                                path2.add(0, new int[]{tank2.x - 1, tank2.y});
                            // Tank 2 going up or right
                            }else{
                                error += "[tank2 going up or right]";
                                path1.remove(0);
                                path1.add(0, new int[]{tank1.x + 1, tank1.y});
                            }
                        }
                    // Tank 1 going left
                    }else{
                        error += "[tank1 going left]";
                        // Tank 2 going up
                        if(path2.get(0)[1] < tank2.y){
                            error += "[tank2 going up]";
                            // Tank 2 going right
                            if(path2.get(1)[0] > path2.get(0)[0]){
                                error += "[tank1 going right]";
                                path2.remove(0);
                                path2.add(0, new int[]{tank2.x + 1, tank2.y});
                            // Tank 2 going up or left
                            }else{
                                error += "[tank1 going up or left]";
                                path1.remove(0);
                                path1.add(0, new int[]{tank1.x - 1, tank1.y});
                            }
                        }
                    }
                }
            // Tank 1 below tank 2
            }else if(tank2.y > tank1.y){
                error += "[tank2 has target]";
                error += "[tank1 below tank2]";
                // Tank 1 going up
                if(path1.get(0)[1] < tank1.y){
                    error += "[tank1 going up]";
                    // Tank 1 going up
                    if(path1.get(1)[1] < path1.get(0)[1]){
                        error += "[tank1 going up]";
                        // Tank 2 going down
                        if(path2.get(0)[1] > tank2.y){
                            error += "[tank2 going down]";
                            if(tank2.x < 8){
                                path2.remove(0);
                                path2.add(0, new int[]{tank2.x + 1, tank2.y});
                                path2.add(1, new int[]{tank2.x + 1, tank2.y - 1});
                                path2.add(2, new int[]{tank2.x, tank2.y - 1});
                            }else{
                                path2.remove(0);
                                path2.add(0, new int[]{tank2.x - 1, tank2.y});
                                path2.add(1, new int[]{tank2.x - 1, tank2.y - 1});
                                path2.add(2, new int[]{tank2.x, tank2.y - 1});
                            }
                        }else{
                            return;
                        }
                    // Tank 1 going right
                    }else if(path1.get(1)[0] > path1.get(0)[0]){
                        error += "[tank1 going right]";
                        // Tank 2 going down
                        if(path2.get(0)[1] > tank2.y){
                            error += "[tank2 going down]";
                            // Tank 2 going left
                            if(path2.get(1)[0] < path2.get(0)[0]){
                                error += "[tank2 going left]";
                                path2.remove(0);
                                path2.add(0, new int[]{tank2.x - 1, tank2.y});
                            // Tank 2 going up or right
                            }else{
                                error += "[tank1 going up or right]";
                                path1.remove(0);
                                path1.add(0, new int[]{tank1.x + 1, tank1.y});
                            }
                        }
                    // Tank 1 going left
                    }else{
                        error += "[tank1 going left]";
                        // Tank 2 going down
                        if(path2.get(0)[1] > tank2.y){
                            error += "[tank2 going down]";
                            // Tank 2 going right
                            if(path2.get(1)[0] > path2.get(0)[0]){
                                error += "[tank2 going right]";
                                path2.remove(0);
                                path2.add(0, new int[]{tank2.x + 1, tank2.y});
                            // Tank 2 going up or left
                            }else{
                                error += "[tank2 going up or left]";
                                path1.remove(0);
                                path1.add(0, new int[]{tank1.x - 1, tank1.y});
                            }
                        }
                    }
                }
            }else if(tank1.x < tank2.x){
                error += "[tank2 has target]";
                error += "[tank1 left of tank2]";
            }else if(tank1.x > tank2.x){
                error += "[tank2 has target]";
                error += "[tank1 right of tank2]";
            }
            println(error);
            println("Tank 1: [" + tank1.x + "," + tank1.y + "], Tank 2: [" + tank2.x + "," + tank2.y + "]");
        }
    }
    /*
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
    }*/
}
