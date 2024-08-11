# godot-car
godot 4 game engine repo

# rules
Go from level to level by touching the 'altar' objects on each level.

The game is a 3d first person shooter, but there's no guns. What you do is you start on the hill part
of the level and then you try to find the altar, which is on the very highest part of the hill. When 
you touch the altar the ground opens up and you fall into a maze. There you have several goals. Firstly
you want to stay alive. Secondly you want to amass points. Finally you want to proceed to the next level.

In the maze there are four types of objects. There are altars, keys, dots, and what we'll call 'patrol' 
objects. You need to collect all the keys in the maze. Then if you do and you go to the last altar,
the ground opens up and you are delivered to the next hill again. The game cycles this way through
phases of hill and maze.

In the maze the patrol can kill you. The patrol objects start off red. The patrol is guarding dots
and moves around the maze from dot to dot. The dots are also worth points. If you avoid the patrol 
but collect all of its dots, the patrol turns green and you can get it, along with some points, and 
the ability to travel freely.

There are also obstacles on the hill part of the level. Here there are alagators. They can tell where
you are and will follow you. At the time of this writing the gators make moving around difficult. 
You can get away from the gators by getting into the car. Being in the car stops the alagators. They 
literally stop moving when the player uses the car. You enter the car by moving into it, and you 
exit the car by jumping while you are already inside. 

At the time of this writing the car has trouble moving through some parts of the hills, so it is 
a challenge in the game to go to the hill altar in the car. Additionally, you need to be out of the 
car for the hill altar to work, and open up the hole to the maze part of the game.

# controls
On the keyboard you can use the direction keys or the a,s,d, and w keys to move around. You also need a 
mouse or trackpad to move the direction the player is looking. You can move one way and be looking a 
totally different direction. The space button is used for jumping.

On the game controller you use the D-pad for moving around. You can then use one of the sticks for looking
in different directions. There is a button on the gamepad for jumping. This button is also for exiting
the car and also dropping the gate (if you are in the maze).

You can pause gameplay on the keyboard by pressing the escape key, and there is a button on the game controller
to do the same.

# visuals
There is a splash screen displayed when the game starts and sometimes during gameplay. The words on the 
screen are from an earlier version of the game and may not represent the true title of the game.

Moving around on the hills requires jumping, but it is not as common on the maze parts of the game.

# strategy
On the hill level (that's the first level) you will be followed by these gator creatures. When they get really
close they jump in the air and come down on your head. For every bounce they extract health points. If
you do nothing they will kill you that way. The remedy is to go to the car, or run away. In the car they
cannot hurt you, and they move slower than you when you run.

On that hill level the primary objective is to get to the altar, and thereby go to the maze level that 
is below. You cannot touch the altar inside the car, so what you want to do is to drive up and then
jump out and touch the object. If you do this quickly the gators will not be close enough to hurt
you. The gators cannot follow you to the maze.

On the maze level (this is a level that exists below every hill level) you will land in the maze
on a ramp. The ramp goes from the inside of the maze itself to the flat platform that exists at 
wall height. You can choose to go from the maze to the wall above at any time. You can see where
the patrols are and go around them. Also, if you are in the maze and you want to get out you 
can jump to the walls. 

On the maze level there is also a set of passages that make up a jail. Jail cells have getes on them.
You can pick up a gate by first touching the key altar (found in the maze) and then simply touching
the gate. While you are holding it, the gate cannot protect you from the patrol, but once you drop
them, putting them in a new position, the patrol cannot pass them. Again, to get the gate you
need the key, and then you simply touch the gate you want to hold. To drop the gate you press the 
jump button.
