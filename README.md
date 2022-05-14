# Cooperation Game

**TODO: Add description**

```mermaid
stateDiagram-v2
[*] --> Players_joining
Players_joining --> Players_joining
Players_joining --> Setup_game
Setup_game --> Player_chooses_action
Player_chooses_action --> Play_card
Play_card --> Discard_cards
Player_chooses_action --> Discard_cards
Discard_cards --> Draw_cards
Draw_cards --> Player_chooses_action

Play_card --> win
Play_card --> lose
```
