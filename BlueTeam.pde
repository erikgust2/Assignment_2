class BlueTeam extends Team{

    BlueTeam(color _color, int[] _homebase){
        super(_color, _homebase);
        this.tanks[0] = new BlueTank(this.homebase[0] + 1, this.homebase[1] + 1, this);
        this.tanks[1] = new BlueTank(this.homebase[0] + 1, this.homebase[1] + 3, this);
        this.tanks[2] = new BlueTank(this.homebase[0] + 1, this.homebase[1] + 5, this);
    }

    void updateLogic(){
        
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
            this.logic = new BlueLogic(this);
        }
    }

    class BlueLogic extends Logic{

        BlueLogic(Tank tank){
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