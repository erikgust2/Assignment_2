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
                    Node node = new Node(i, j);
                    knownWorld.addNode(node);
                    frontier.add(node);
                }
            }
        } else {
            for(int i = 15; i >= 12; i--) {
                for(int j = 15; j >= 8; j--) {
                    Node node = new Node(i, j);
                    knownWorld.addNode(node);
                    frontier.add(node);
                }
            }
        }
    }

    void update() {
        for(Tank tank : team.tanks) {
            ArrayList<Node> tankView = tank.logic.getSurroundings();
            this.knownWorld.update(tankView);
            /* for(Node node : tankView) {
                if(!frontier.contains(node)) {
                    frontier.add(node);
                }
            } */
        }
        for(Tank tank : team.tanks) {
            tank.logic.updateMap(knownWorld);
        }

        assignTargets();
    }

    void assignTargets() {
        System.out.println("Assigning targets...");
        while(frontier.size() > 0) {
            Node target = frontier.remove(0);
            performAuction(target);
        }
    }

    void performAuction(Node target) {
        System.out.println("Auction started");
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
            System.out.println("Tank won auction for " + target.x + ", " + target.y);
        }
    }

}