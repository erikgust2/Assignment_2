class Team{

    color teamColor;
    int[] homebase;
    Tank[] tanks;

    KnownWorld teamKnownWorld;

    Team(color _color, int[] _homebase){
        this.teamColor = _color;
        this.homebase = _homebase;
        this.tanks = new Tank[3];
        this.teamKnownWorld = new KnownWorld(this);
    }

    void updateLogic(){

    }



}
