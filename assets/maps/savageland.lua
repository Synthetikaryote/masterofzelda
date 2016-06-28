return {
  version = "1.1",
  luaversion = "5.1",
  tiledversion = "0.16.1",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 240,
  height = 240,
  tilewidth = 32,
  tileheight = 32,
  nextobjectid = 1,
  properties = {},
  tilesets = {
    {
      name = "mountain_landscape",
      firstgid = 1,
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      image = "mountain_landscape.png",
      imagewidth = 512,
      imageheight = 512,
      tileoffset = {
        x = 0,
        y = 0
      },
      properties = {},
      terrains = {
        {
          name = "gravel",
          tile = -1,
          properties = {}
        },
        {
          name = "gravel 2",
          tile = -1,
          properties = {}
        }
      },
      tilecount = 256,
      tiles = {
        {
          id = 11,
          terrain = { -1, -1, -1, 1 }
        },
        {
          id = 12,
          terrain = { -1, -1, 1, 1 }
        },
        {
          id = 13,
          terrain = { -1, -1, 1, -1 }
        },
        {
          id = 27,
          terrain = { -1, 1, -1, 1 }
        },
        {
          id = 28,
          terrain = { 1, 1, 1, 1 }
        },
        {
          id = 29,
          terrain = { 1, -1, 1, -1 }
        },
        {
          id = 43,
          terrain = { -1, 1, -1, -1 }
        },
        {
          id = 44,
          terrain = { 1, 1, -1, -1 }
        },
        {
          id = 45,
          terrain = { 1, -1, -1, -1 }
        },
        {
          id = 110,
          terrain = { -1, 1, 1, 1 }
        },
        {
          id = 111,
          terrain = { 1, -1, 1, 1 }
        },
        {
          id = 126,
          terrain = { 1, 1, -1, 1 }
        },
        {
          id = 127,
          terrain = { 1, 1, 1, -1 }
        },
        {
          id = 142,
          terrain = { -1, 0, 0, 0 }
        },
        {
          id = 143,
          terrain = { 0, -1, 0, 0 }
        },
        {
          id = 155,
          terrain = { -1, -1, -1, 0 }
        },
        {
          id = 156,
          terrain = { -1, -1, 0, 0 }
        },
        {
          id = 157,
          terrain = { -1, -1, 0, -1 }
        },
        {
          id = 158,
          terrain = { 0, 0, -1, 0 }
        },
        {
          id = 159,
          terrain = { 0, 0, 0, -1 }
        },
        {
          id = 171,
          terrain = { -1, 0, -1, 0 }
        },
        {
          id = 172,
          terrain = { 0, 0, 0, 0 }
        },
        {
          id = 173,
          terrain = { 0, -1, 0, -1 }
        },
        {
          id = 187,
          terrain = { -1, 0, -1, -1 }
        },
        {
          id = 188,
          terrain = { 0, 0, -1, -1 }
        },
        {
          id = 189,
          terrain = { 0, -1, -1, -1 }
        }
      }
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "floor",
      x = 0,
      y = 0,
      width = 240,
      height = 240,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "base64",
      compression = "zlib",
      data = "eJztwwENAAAAwqA3tH8bi8DGqqmqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqraAZpdcww="
    },
    {
      type = "tilelayer",
      name = "obstacles",
      x = 0,
      y = 0,
      width = 240,
      height = 240,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "base64",
      compression = "zlib",
      data = "eJzt3UluLEUQBuDHuGfcM+4Z94x7xj3jDewb2DcDTgCcADgBsCUQsvQk3H7d7hryz/g+KZbuLpXaOUREZT14sK7HKh6veKLiyYqnKp5e+TuBZTxT8WzFcxXPV7xQ8eKuVwQc66WKlyteqXi14rWK10/4+4uKyxWuC3i0NyrerHir4u2KdyrePeHvryquV7gumN0Sc997Fe9XfFDxYcVHFR+f+ZmMy3ppHEvMfZ9UfFrxWcXnFV9UfHnmZ55q699U59+w9dKY7ptH/qri64pvKr6t+K7i+5Wu8ZCtf1N+w1k6jLfyyMyqw3h7bh6ZdXSYOzjfuXlk1pE8d+jt2Y48MkuzJ9vOCHlk5mJPtp0R8sjMxZ4MctmTQa6Z92TqAsxu5j1Zcl3gX2oDkEttAHKpDUAutQHIpTYAuWauDcCIlswZz1wbgBHJGUMuOWPIJWcMuTrljPWHMZtOOWN7fWbTKWdsrw+57PUhV6e9Psym014fZtNprw/QmXoj5FJvhFzqjZBLvRFyqTfen9wBe1NvvL8OuQNj1NjUG++vQ+6gwxhFTx1yBx3GKHrqkDvoMEbRU4fcQYcxip465A46jFEwqw5jFAAAAMCNi4rLvS8CuJeriuuFP9OYALnWGBMAAAAAOnKOAeRyjgHkco4B5HKOAdwuYW/pHAO4XcLe0jkGcLuEvaVzDEhYJ+7B3pIECevEPdhbkiBhnbgHe0sSWCfezt6SBNaJkMs6EXJZJwIAAMBy9HlBLv+/kEufJuTSpwm59GlCLn2akEufJuTSp8m5vBcQcs36XkC1Vciltgq51FYhl9oq5FJbhVxqq5BLbRUAAACAU+izhlyz9lnTlx57yKXHHnLpsYdceuwhlx57yKXHHnLpsQcAuJt6PeRSr4dc6vWQS70ecqnXQ67O9fofKn6s+Gnj75UzZCmd6/U/V/xS8evG3ytnSBdrzlW/Vfxe8cdCn3csOcPjOB8j35pz1Z8Vf1X8vdDnHUvO8DjOx8g341wlZ0gXM85VnXOG9DLjXNU5Z0gv5irIZa4CAAAAAAAAAO7i+SbI5fkmAEbjjB/I5YwfyDXjuQnQxYznJkAXo5yboMYDpxvl3AQ1HjidcxPYk/oH5FL/gFzqH8yqw9pS/YNZdVhbjlL/gKV1WFuOUv+ApXVYW6p/MCtrS8hlbQm5rC0BAAAAAAAAAACYQYfnsWFWHZ7Hhll1eB4bZtXheWyYleexIVf689jyb3SW/jy2/Bvkkn+DXPJvkEv+DXKl59+gs/T8GwAAcLeLisu9L2JCennYwlXF9d4XMSG9PJBLLw+zm3mNqZeH2c28xtTLw+xmXmPq5WF2M68x9fIwO2tMyGWNubyZc4KMxRpzeTPnBGF2M+cEYXYz5wRhdnKCkEtOEHLJCQIAeMYeknnGHgAAAAAAAAAAAAAAAAAA+nA+AORyPsB/vHuEU5j3xuL/9zD35v/Me2Px7qDD3BtG591Bh7k3jM67gw5zbxiddwcd5t7wsBHzId4ddJh7w8NGzId4d9BhyfdmxLkinXwIWxlxrkgnH8JWzBXLkw9hK+aK5cmHsBVzxfKS8yFkMVdALnMFAAAAAABsY6+zf5w5BOfb6+yfkc4cuhlLjCePZtxlNDdjySjjychGGnePZcxhLX5b60scc8jgtwUAAAAAAAAAAAAAwCj+AY0+Oh4="
    }
  }
}
