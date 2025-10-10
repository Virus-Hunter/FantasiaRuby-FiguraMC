# Changelog

## 2025/10/09

### Added
- Added an anim override function to EZAnims manager
- Trident throwing pose

### Changed
- Streamlined some animation transitions

## 2025/10/06

### Added
- Custom shield prop and blocking animations
	- This can be toggled on and off in the action menu, seperate from custom items (Sword)
	- Also shows up in first person (Did my best to have it raised while blocking)
- "Tool" state 
	- When holding a shovel/axe/hoe/pickaxe, Ruby will sling it over her shoulder while moving about
- Bow drawing animation
- Midair/water crouch pose (Cannonball!)
- Better Combat Mod compatibility toggle
	- This is a subpar solution at best. Basically it disables Ruby's animations for a moment during weapon attacks so the mod's animation can play out. If the attack is shorter or longer than the default attack animation speed then it'll still look weird at the end. But it's a HUGE step from having her not move at all during the mod's animations.
	- Also fixes Ruby's hips appearing during first person attacks with this mod
	- This could technically also work for other mods that override attack animations, but your mileage may vary
- Ruby now lays on top of beds instead of clipping halfway into them (Will do a proper sleeping pose later)

### Changed
- Refactored most of the script of the code
- Decided to slap the action wheel icon and sword texture into the rubyMain texture file (I thought it would be more efficient)
- Shortened the blend time between a lot of animations (Ruby will transition faster between animations)
- Finally fixed the jump animations
- Shrunk down the custom sword while in first person
- Vanilla shields are now positioned properly and are fully compatible with the new blocking animations

## 2025/09/30

### Added
- Added a proper changelog

### Changed
- Fixed R hand during Elytra/Fly animations

## 2025/09/27

### Added
- Added Elytra/Fly animations (Ruby breaks out her cool glider)

## 2025/09/27

### Added
- Animated idle pose
- Added basic water animations

### Changed
- Fixed sitting pose
- Fixed head during jump pose
- Adjusted R arm during regular jumps
- Adjusted attack animation (held item swings further)

## 2025/09/26

### Added
- Public release