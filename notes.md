# States

Each MUGEN character additionally has three special states, numbered -1, -2, and -3. These are the only allowable states with negative numbers. State -1 generally contains state controllers that determine state transition rules based on user input (commands). State -2 contains other state controllers that need to be checked every tick. State -3 contains state controllers which are checked every tick *unless* the player is temporarily using another player's state data (for instance, when the player is being thrown).

There is one exception to the above scenario. If the character is a "helper" character, i.e., spawned by the Helper state controller, that character will not have the special states -3 and -2. The helper character will not have the special state -1 either, unless it has keyboard input enabled. (This is controlled by the Helper state controller when the character is created.)

# Life and Power

His power bar is the blue bar, and that increases with each attack he gives or takes. When the power bar reaches certain values, he can do super moves.

# Hitdef

A single HitDef is valid only for a single hit. To make a move hit several times, you must trigger more than one HitDef during the attack.
