# "Master of Zelda"

This game project is inspired by the build system of Master Of Orion 2 and the gameplay style of Zelda: A Link To The Past.  The idea is that the beginning of the game will allow you to choose your character's specialties with a point-based system without dependencies, just like Master Of Orion 2, and will pointedly include negative specialties to gain points for more positives.  The game will feature challenges that will be difficult for any kind of character build.  The game will feature limited inventory and fun combat like Zelda: ALTTP.  We think it has a lot of potential.

The name is nowhere near final.

Tiles are by Zabin who freely provided them on [OpenGameArt](http://opengameart.org/users/zabin).

The character sprite was mixed and matched with the [Universal LPC Spritesheet Character Generator](http://gaurav.munjal.us/Universal-LPC-Spritesheet-Character-Generator/).  See that page for licenses and credits.

These graphics are not final; just in use to get things working.

## Building / playing

This game is written in Lua for the [LÖVE](https://love2d.org/) 2D game framework.  We'll package it when it's in a more playable state, but for now, we are building and testing directly from Sublime Text 3 with this LOVE.sublime-build file:

```JSON
{
    "selector": "source.lua",
    "cmd": ["C:/tools/love/love.exe", "${project_path:${file_path}}"],
    "shell": true,
    "file_regex": "^Error: (?:[^:]+: )?([^: ]+?):(\\d+):() ([^:]*)$"
}
```

To use this in Sublime Text 3, click "Tools" -> "Build System" -> "New Build System...", replace everything in the resulting document that opens with the above, edit the path to your love executable, save in the default location as "LOVE.sublime-build", and you should be able to then use "Tools" -> "Build" to build and run.

Also, don't forget to "git submodule update --init"!  STI is used for loading the map(s) made in Tiled.