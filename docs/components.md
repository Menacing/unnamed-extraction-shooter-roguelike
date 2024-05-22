# Components

## General Components
- Ammo Component
    - Handles actions related to the ammo system since they're pretty specific and didn't fit well in the existing item system
    - interacts with the `AmmoLoader` Autoload
- Footstep Component
    - WIP but will play footstep sound effects based on the material being traveled over
- GuaranteeedItemSpawn Component
    - Guarantees a certain number of a given item spawn on the map in selected areas
    - To be used for key items like the Power Core or .. keys
## Player Components
- Health Component
  - Handles life pools, damage, and healing for the player
