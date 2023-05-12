# Assignment_2

## Authors
- Group 03
- Erik Gustafsson
- August Hafvenström

## Prerequisites
- This project uses no external libraries except for Processing itself.
- It has been verified to run in both VSCODE and Processing IDE on Windows without issue.

### Instructions for Processing IDE
- Un-Zip the file at a convenient location.
- In Processing, open the "Assignment_1_Grid.pde"-file.
- Press the "play"-button.

### Instructions for VSCODE
- Un-Zip the file at a convenient location.
- Use "Open Folder" in the file-menu to open the folder containing the .pde-files.
- Open the Command Palette and select "Processing: Run Processing Project".
- If this does not work, try opening the Command Palette and select "Processing: Create Task File" to remake tasks.json.

## What am I looking at?
- The program does not work as intended at the moment as there are issues with the pathfinding algorithm. 
- However, the auction system itself works as can be seen in the terminal outputs.
- For each frontier node, the team actor starts an auction with a corresponding terminal output explaining which node is being auctioned.
- After that, each bid (defined as the sum of movements to complete all tasks including the auctioned one) from the tanks get printed out into the terminal.
- The tank with the lowest bid (e.g the lowest amound of moves required to complete the tasks) wins. This is displayed as the last prompt before the auction ends.

### Caveats in the prototype
- Due to issues in the pathfinding, the tanks are unable to avoid collision with barriers in nodes.
- Thus, collision has been disabled to show the tanks moving around without immediately deadlocking.
- In addition, the tanks will only explore the area closest to their starting zone before stopping.
