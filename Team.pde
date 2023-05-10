class Team{

    color teamColor;
    int[] homebase;
    Tank[] tanks;

    Logic teamLogic;

    Team(color _color, int[] _homebase){
        this.teamColor = _color;
        this.homebase = _homebase;
        this.tanks = new Tank[3];
    }

    void updateLogic(){
        for(Tank t: this.tanks){
            t.update();
        }
    }

    void init(){
        
    }



}
