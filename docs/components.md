# Components

## General Components
- Ammo Component
    - Handles actions related to the ammo system since they're pretty specific and didn't fit well in the existing item system
    - interacts with the `AmmoLoader` Autoload
- Attack Component
    - Holds information about attacks and is passed to a damage component to handle hits
- Damage Component
    - Handles attacks, penetration, and dispatching damage to health components
- Damage Effect Component
    - Spawns on hit effects like sparks and bullet holes
- Equip Effect Component
    - Adds gameplay affects to parent when added to tree. Used for attachments and equipment effects 
- Footstep Component
    - WIP but will play footstep sound effects based on the material being traveled over
- GuaranteeedItemSpawn Component
    - Guarantees a certain number of a given item spawn on the map in selected areas
    - To be used for key items like the Power Core or .. keys
- Loot Fiesta Component
    - Spawns items to fly in the air when triggered. Fiesta!
## Player Components
- Health Component
  - Handles life pools, damage, and healing for the player
