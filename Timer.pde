/* 
 * Authors:
 * - Erik Gustafsson
 * - August Hafvenström
 * - Petter Signell
 */
 
 /* 
  * This class defines a timer to keep track of elapsed time in milliseconds
  * It also allows for other classes to set new timers to check for elapsed time
  * since the timer was started
  */
 
 
 class Timer{

    int startTime;
    int elapsedTime;
    int currentTime;
    boolean isPaused;

    Timer(){
        this.startTime = millis();
        this.elapsedTime = 0;
        this.isPaused = false;
    }

    void tick(){
        if(!isPaused){
            this.elapsedTime += timeSinceLastTick();
        }
        this.currentTime = millis();
    }

    int setNewTimer(int mill){
        return this.elapsedTime + mill;
    }

    int getElapsedTime(){
        return this.elapsedTime;
    }

    int getCurrentTime(){
        return this.currentTime;
    }

    int timeSinceLastTick(){
        return millis() - this.currentTime;
    }

    void togglePause(){
        this.isPaused = !this.isPaused;
    }
}