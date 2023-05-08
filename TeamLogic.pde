class TeamLogic extends Logic {

    Team team;

    TeamLogic(Team team) {
        this.team = team;
    }    

    void assignTargets() {
        while(frontier.length() > 0) {
            Node target = frontier.pop();
            performAuction(target);
        }
    }

    void performAuction(Node target) {
        Tank bestBidder = null;
        int bestBid = 100000;

        for(Tank tank : team.tanks) {
            int currentBid = tank.logic.getBid(target);
            if(currentbid < bestBid) {
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