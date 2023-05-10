class TeamLogic extends Logic {

    Team team;

    TeamLogic(Team team) {
        super();
        this.team = team;
        this.knownWorld = new KnownWorld(team);
        init();
    }    

    void init() {
        if(team.homebase[0] < 12) {
            for(int i = 0; i <= 3; i++) {
                for(int j = 0; j <= 6; j++) {
                    knownWorld.addNode(new Node(i, j));
                }
            }
        } else {
            for(int i = 15; i >= 12; i--) {
                for(int j = 15; j >= 8; j--) {
                    knownWorld.addNode(new Node(i, j));
                }
            }
        }
    }

    void update() {
        for(Tank tank : team.tanks) {
            ArrayList<Node> tankView = tank.logic.getSurroundings();
            this.knownWorld.update(tankView);
        }
        for(Tank tank : team.tanks) {
            tank.logic.updateMap(knownWorld);
        }

        assignTargets();
    }

    void assignTargets() {
        while(frontier.size() > 0) {
            Node target = frontier.remove(0);
            performAuction(target);
        }
    }

    void performAuction(Node target) {
        Tank bestBidder = null;
        int bestBid = 100000;

        for(Tank tank : team.tanks) {
            int currentBid = tank.logic.getBid(target);
            if(currentBid < bestBid) {
                bestBidder = tank;
            } else if (currentBid == bestBid) {
                if(Math.random() < 0.5) {
                    bestBidder = tank;
                }
            }
        }

        if(bestBidder != null) {
            bestBidder.logic.addTarget(target);
        }
    }

}