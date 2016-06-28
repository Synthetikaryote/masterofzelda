return {
  version = "1.1",
  luaversion = "5.1",
  tiledversion = "0.16.1",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 100,
  height = 100,
  tilewidth = 16,
  tileheight = 16,
  nextobjectid = 7,
  properties = {},
  tilesets = {
    {
      name = "sygma_dwtileset2",
      firstgid = 1,
      tilewidth = 16,
      tileheight = 16,
      spacing = 0,
      margin = 0,
      image = "sygma_dwtileset2.png",
      imagewidth = 480,
      imageheight = 256,
      transparentcolor = "#ff799b",
      tileoffset = {
        x = 0,
        y = 0
      },
      properties = {},
      terrains = {
        {
          name = "grassland",
          tile = -1,
          properties = {}
        }
      },
      tilecount = 480,
      tiles = {
        {
          id = 180,
          terrain = { 0, -1, -1, -1 }
        },
        {
          id = 181,
          terrain = { -1, 0, -1, -1 }
        },
        {
          id = 210,
          terrain = { -1, -1, 0, -1 }
        },
        {
          id = 211,
          terrain = { -1, -1, -1, 0 }
        },
        {
          id = 240,
          terrain = { 0, 0, 0, 0 }
        },
        {
          id = 399,
          terrain = { 0, 0, 0, -1 }
        },
        {
          id = 400,
          terrain = { 0, 0, -1, -1 }
        },
        {
          id = 401,
          terrain = { 0, 0, -1, 0 }
        },
        {
          id = 429,
          terrain = { 0, -1, 0, -1 }
        },
        {
          id = 431,
          terrain = { -1, 0, -1, 0 }
        },
        {
          id = 459,
          terrain = { 0, -1, 0, 0 }
        },
        {
          id = 460,
          terrain = { -1, -1, 0, 0 }
        },
        {
          id = 461,
          terrain = { -1, 0, 0, 0 }
        }
      }
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "world map",
      x = 0,
      y = 0,
      width = 100,
      height = 100,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "base64",
      compression = "zlib",
      data = "eJzt1rsNwjAUQNHQMQ0VOyBmYBM2YkYahEIayx8pCn5xdIrTREbyy5UdHtM0PQAA6OJymkXvg9nrNCs10auf5V3XWrR6sX2P9FlrTW4d2zZpeSa/cWb69Hhl5O41Lfp1+Ta4/qRN0rXR+z6q3BlJm6RnRY9+XWp31tddi5AuJdH7AwAAAAAAAAAAAIDRnRveGdF7PqJWh1oPTfp3qHVZnkXPMrq1LUqi5xmdHvtSeq+3Bj369Wi1qHWJnmd0euzL2vuqdGdFz3MErW+078f+mvh/NWaT6BmOSI/90mIMOgAAAAAAAAAAAAAAAAAAAADwbx8s6KVF"
    },
    {
      type = "tilelayer",
      name = "enterable tiles",
      x = 0,
      y = 0,
      width = 100,
      height = 100,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "base64",
      compression = "zlib",
      data = "eJztwTEBAAAAwqD1T+1lC6AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAbnEAAAQ=="
    },
    {
      type = "imagelayer",
      name = "Sprite Layer",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      image = "",
      properties = {}
    }
  }
}
