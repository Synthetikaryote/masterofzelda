# "Master of Zelda"

This game project is inspired by the build system of Master Of Orion 2 and the gameplay style of Zelda: A Link To The Past.  The idea is that the beginning of the game will allow you to choose your character's specialties with a point-based system without dependencies, just like Master Of Orion 2, and will pointedly include negative specialties to gain points for more positives.  The game will feature challenges that will be difficult for any kind of character build.  The game will feature limited inventory and fun combat like Zelda: ALTTP.  We think it has a lot of potential.

The name is nowhere near final.

Tiles are by Zabin who freely provided them on [OpenGameArt](http://opengameart.org/users/zabin).

The character sprite was mixed and matched with the [Universal LPC Spritesheet Character Generator](http://gaurav.munjal.us/Universal-LPC-Spritesheet-Character-Generator/).  See that page for licenses and credits.

These graphics are not final; just in use to get things working.

## Building / playing

This game is written in Lua for the [LÖVE](https://love2d.org/) 2D game framework.  To run the [releases](https://github.com/Synthetikaryote/masterofzelda/releases), install [LÖVE](https://love2d.org/) and that should associate .love files with it automatically.  You can then run .love files like any other program.

If you want to fork and/or hack on the game with Sublime Text 3, you can build and run the game directly from Sublime Text 3 with this LOVE.sublime-build file:

```JSON
{
    "selector": "source.lua",
    "cmd": ["C:/tools/love/love.exe", "${project_path:${file_path}}"],
    "shell": true,
    "file_regex": "^Error: (?:[^:]+: )?([^: ]+?):(\\d+):() ([^:]*)$"
}
```

To use this, in Sublime Text 3, click "Tools" -> "Build System" -> "New Build System...", replace everything in the resulting document that opens with the above, edit the path to your love executable, save in the default location as "LOVE.sublime-build", and you should be able to then use "Tools" -> "Build" to build and run when you have main.lua open.

Alternatively, the following batch script will build and run the game if you have it and 7za in this repo's root directory.  Edit the path to your love executable.

```batch
7za a -r -tzip masterofzelda.love *.* -xr!*.love -xr!*.bat -xr!*.exe
"C:\tools\love\love.exe" masterofzelda.love
```

Also, don't forget to "git submodule update --init"!  [STI](https://github.com/karai17/Simple-Tiled-Implementation/) is used as a submodule for loading the map(s) made in [Tiled](https://github.com/bjorn/tiled).