## 2026/01/28

This may be the final major update as the project has pretty much reached the cloud file limit, despite my best efforts to efficiently squeeze everything down. But I've made sure to make this last hurrah worth while by filling holes in Ruby's animation kit and cleaning things up under the hood as best as possible.

With that being said, I may decide to continue working on Ruby if and when the Figura devs release the next major update which will supposedly increase the cloud file limit AND compress avatars even smaller, among other features that I look forward to taking advantage of.

### Added
- Sneaking animations, complete with sneaking backwards, blocking and attack/mine variations
- New action wheel toggle to turn dynamic head and eye movement off/on
- Crouching jump up animation
- New fall animation where Ruby starts freaking out
- Crossbow loading animation and dynamic aiming when holding a loaded crossbow
- New sleeping pose
- Action wheel toggles now save
- Custom scripts to handle most of what the earlier 3rd party scripts were doing (Animazer, TailFX and Looksy)
### Changed
- script.lua (The main script) has been renamed to RubyMain.lua
- All scripts have been moved to a dedicated scripts folder
- Textures have gone back to being separated files (rubyMain.png, actionWheel.png and itemTex.png)
- Improved compatibility with the Better Combat mod. The script can now *automatically* detect when a Better Combat animation is playing and disables Ruby's animations accordingly, re-enabling them afterwards.
	- The Better Combat toggle has been removed from the action wheel as it is no longer needed.
	- (Thanks to heyy_bbooii on the Figura Discord for this one)
- Head turning is now handled by Sh1loz's Smoothie script
- Removed the following animations:
	- walkjumpup
	- walkjumpdown
	- sprintjumpup
	- sprintjumpdown
	- walkjumpup_sword
	- walkjumpdown_sword
	- sprintjumpup_sword
	- sprintjumpdown_sword
	- walkjumpup_tool
	- walkjumpdown_tool
	- sprintjumpup_tool
	- sprintjumpdown_tool
	- attackR_BetterCombat
	- attackR_tool
		- These were simply duplicates of existing animations, but thanks to the new Animazer functionality these are no longer needed.
- Refined first person empty hand movement for walking, running and jumping
- Refined swimming animations a bit (including first person)
- Ruby's weapon no longer floats during Better Combat animations
- Fixed the UVs on Ruby's ear fluff
- Fixed texture bleeding issues on Ruby's new head model, among other head-related tweaks
- elytra and elytradown animations have been slightly adjusted and now transition into each other seamlessly
- Jumping animation is now tied to up/down velocity
	- Basically the animation is set to play as Ruby hits the peak of her jump, no matter how high it is
	- This also means jump animations are now compatible with mods that let you double jump
- Ruby's legs now dynamically shift while banking with an Elytra
- Fixed the custom shield briefly flickering when blocking in first person
- Vanilla shield is now 25% smaller

## 2026/01/14

### Added
- The facelift update! Ruby has a brand new head model! Featuring eyes that look around, brows that go up and down, and a mouth that eats by the pound.
	- If you've grown acustomed to the old face, too bad
- New minor animation set: look_horizontal, look_vertical and blink
	- This is for the new eye look system, utilizing the Gaze script made by Bitslayn
- New minor animation: attackR_fly
	- attackR while flying's been bugged for a good long while so this new anim will act as an override. It's made to look like Ruby's quickly placing a firework at her side. 

### Changed
- Ruby's head has grown, but her body has shrunk!
	- This was done to be more accurate to the original character illustration, and to match her lore of being short. She's still as tall as a regular player model, if you include her ears.
	- If you don't like her new height, open up models/ruby.bbmodel in Blockbench, select the root folder and Transform->Scale. Then, with everything still selected, use the move gizmo to bring her up on the Y axis until the bottom of her feet are aligned with the floor. You can also select the Head folder and scale that down as well.
- Completely removed the old Skin.png texture file and all meshes that were using it have either been removed or now use the rubyMain.png texture. 
	-This has slightly alleviated the filesize situation but with the new head model we're still dangerously close to the file size limit.
- Pushed all of Ruby a little forward in the Z-axis to better align with the regular player model and hitboxes
- Adjusted the glider straps during the elytradown animation so they're vaguely in Ruby's hands
- Adjusted leg spacing for the walk_sword animation
- Added arm movement while jumping in first person
- Renamed "Toggle Custom Items" option to "Toggle Custom Sword" (Let's face it I'm not adding any more items)

### NOTICE
- As of writing, *the latest version of Blockbench is **not** compatible with Figura.* If you plan on editing the .bbmodel files, be sure to use [version **4.16.2**](https://github.com/JannisX11/blockbench/releases/tag/v4.12.6), the last version of Blockbench that Figura supports. 
	- While it is possible to use Legacy Export on the newer versions of Blockbench, this export format does NOT support animations.

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