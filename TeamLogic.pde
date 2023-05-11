class TeamLogic extends Logic {

    Team team;

    ArrayList<Node> assignedTargets = new ArrayList<Node>();

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
                    node.explored = true;
                    knownWorld.addNode(node);
                    frontier.add(node);
                }
            }
        } else {
            for(int i = 15; i >= 12; i--) {
                for(int j = 15; j >= 8; j--) {
                    Node node = new Node(i, j);
                    node.explored = true;
                    knownWorld.addNode(node);
                    frontier.add(node);
                }
            }
        }
    }

    void update() {
        for(Tank tank : team.tanks) {
            if(tank == null){
                continue;
            }
            ArrayList<Node> tankView = tank.logic.getSurroundings();
            this.knownWorld.update(tankView);
        }
        for(Node node[] : knownWorld.nodes) {
            for(Node n : node) {
                if(n != null && n.explored && !n.visited && !frontier.contains(n)) {
                    frontier.add(n);
                }
            }
        }
        for(Tank tank : team.tanks) {
            if(tank == null){
                continue;
            }
            tank.logic.updateMap(knownWorld, frontier);
        }

        //System.out.println("Frontier size: " + frontier.size());

        assignTargets();
    }

    void assignTargets() {
        //System.out.println("Assigning targets...");
        outerloop:
        while(frontier.size() > 0) {
            Node target = frontier.remove(0);
            for(Node n : assignedTargets) {
                if(n.x == target.x && n.y == target.y) {
                    continue outerloop;
                }
            } 
            performAuction(target);
        }
    }

    void performAuction(Node target) {
        //System.out.println("Auction started");
        Tank bestBidder = null;
        int bestBid = 100000;

        for(Tank tank : team.tanks) {
            if(tank == null){
                continue;
            }
            if(tank instanceof BlueTeam.DummyTank
            || tank instanceof RedTeam.DummyTank){
                continue;
            }
            int currentBid = tank.logic.getBid(target);
            //System.out.println("Tank bidded " + currentBid);
            if(currentBid < bestBid) {
                bestBidder = tank;
                bestBid = currentBid;
            } else if (currentBid == bestBid) {
                if(Math.random() < 0.5) {
                    bestBidder = tank;
                }
                bestBidder = this.team.tanks[0];
            }
        }

        if(bestBidder != null) {
            bestBidder.logic.addTarget(target);
            this.assignedTargets.add(target);
            System.out.println("Tank[" + bestBidder.id + "] won auction for " + target.x + ", " + target.y + " with a bid of " + bestBid);
        }
    }

}
