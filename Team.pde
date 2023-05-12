/* 
 * Authors:
 * - Erik Gustafsson
 * - August Hafvenström
 * - Petter Signell
 */

/*
 * Generic class for the teams.
 */

class Team{

    // Team variables
    color teamColor;
    int[] homebase;
    Tank[] tanks;

    // Reference to the team's logic class
    Logic teamLogic;

    // Constructor
    Team(color _color, int[] _homebase){
        this.teamColor = _color;
        this.homebase = _homebase;
        this.tanks = new Tank[3];
    }

    // Runs every frame
    void updateLogic(){
        for(Tank t: this.tanks){
            t.update();
        }
    }

    // Dummy
    void init(){
        
    }



}
