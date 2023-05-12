/* 
 * Authors:
 * - Erik Gustafsson
 * - August Hafvenström
 * - Petter Signell
 */

/*
 * This class extends the logic class with additional team-specific logic.
 * It is used by the team classes (i.e BlueTeam and RedTeam).
 * This class acts as the third actor; the leader.
 */

class TeamLogic extends Logic {

    // The team this logic belongs to
    Team team;

    // Already assigned nodes. Used to prevent the same node from being assigned twice.
    ArrayList<Node> assignedTargets = new ArrayList<Node>();

    // Constructor
    TeamLogic(Team team) {
        super();
        this.team = team;
        this.knownWorld = new KnownWorld(team);
        init();
    }    

    // Runs on startup to define the starting area on the map.
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

    // Runs every frame
    void update() {

        // Updates the map with the surroundings of all tanks
        for(Tank tank : team.tanks) {
            ArrayList<Node> tankView = tank.logic.getSurroundings();
            this.knownWorld.update(tankView);
        }

        // Adds new frontier nodes to be explored
        for(Node node[] : knownWorld.nodes) {
            for(Node n : node) {
                if(n != null && !n.visited && !frontier.contains(n)) {
                    frontier.add(n);
                }
            }
        }

        // Updates the maps of the subservient tanks with the map of the leader
        for(Tank tank : team.tanks) {
            tank.logic.updateMap(knownWorld, frontier);
        }

        //System.out.println("Frontier size: " + frontier.size());

        // Assigns targets to the tanks from the frontier using an auction system
        assignTargets();
    }

    // Goes through the frontier and auctions the target nodes out to the subservient tanks.
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

    /*
     * This method performs the auction for a single target node.
     * The logic follows a simple auction system based on a sealed-bid system.
     * The tank with the lowest bid (i.e the tank that would need to perform the lowest
     * amount of actions to reach the target) wins the auction and gets assigned the target.
     */
    void performAuction(Node target) {
        //System.out.println("Auction started");
        Tank bestBidder = null;
        int bestBid = 100000;

        // Goes through all tanks (ignoring dummies) and gets their bids for the target node
        for(Tank tank : team.tanks) {
            if(tank instanceof BlueTeam.DummyTank
            || tank instanceof RedTeam.DummyTank){
                continue;
            }

            // Gets the bid for the target node by prompting the tank to calculate it.
            int currentBid = tank.logic.getBid(target);
            //System.out.println("Tank bidded " + currentBid);

            // If the bid is lower than the current best bid, the tank becomes the new best bidder.
            if(currentBid < bestBid) {
                bestBidder = tank;
                bestBid = currentBid;

            // If the bid is equal to the current best bid, the tank has a 50% chance of becoming the new best bidder.
            } else if (currentBid == bestBid) {
                if(Math.random() < 0.5) {
                    bestBidder = tank;
                }
            }
        }

        // If a best bidder was found, the target node is assigned to the tank.
        if(bestBidder != null) {
            bestBidder.logic.addTarget(target);
            this.assignedTargets.add(target);
            System.out.println("Tank[" + bestBidder.id + "] won auction for " + target.x + ", " + target.y + " with a bid of " + bestBid);
        }
    }

}
