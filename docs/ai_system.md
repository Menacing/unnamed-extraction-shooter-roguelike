# AI
The reworked AI system is a 3 tier approach based on some of the arguments presented [here](https://takinginitiative.net/wp-content/uploads/2020/01/behaviortrees_breaking-the-cycle-of-misuse.pdf).

The 3 tiers are:
1) Sensing
2) Decision Making
3) Actuation

## [Sensory Component](../game_objects/enemies/sense_component.gd)
The sensory component is a node you should attack to the head or sensor equivalent of your monster. It includes a viewcone, a to be implimented listening spehere, and a 6th sense bullet detector. It has an indepent update tick rate and will process what the monster sees, hears, knows, and remembers along with some memory information.

It is up to the other 2 layers to interpret and use this information

## State Chart
Each monster will then have a state chart that represents the decision making layer of the 3 tier approach. As much as possible we'll try to use the same state and code and control capability by selective disabling transitions or states. Information about the environment should be queried from the Sense component and passed to the relevant Behavior Tree

## Behavior Tree
Each behavior tree should represent a small behavior to execute. There should be very little decision making in the tree, any decisions should be handled by the state chart which should react by choosing a different tree to execute. 

Responsible for playing animations, sounds and movement.