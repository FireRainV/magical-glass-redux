return {
  version = "1.10",
  luaversion = "5.1",
  tiledversion = "1.10.2",
  class = "",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 20,
  height = 12,
  tilewidth = 40,
  tileheight = 40,
  nextlayerid = 12,
  nextobjectid = 83,
  properties = {
    ["light"] = true,
    ["name"] = "Snowdin - Box Road"
  },
  tilesets = {
    {
      name = "tundratiles",
      firstgid = 1,
      filename = "../tilesets/tundratiles.tsx",
      exportfilename = "../tilesets/tundratiles.lua"
    },
    {
      name = "objects",
      firstgid = 676,
      filename = "../tilesets/objects.tsx",
      exportfilename = "../tilesets/objects.lua"
    }
  },
  layers = {
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 20,
      height = 12,
      id = 1,
      name = "tiles",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        1, 1, 1, 1, 1, 1, 1, 1, 1, 19, 20, 21, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 19, 20, 21, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 19, 20, 21, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 19, 20, 21, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 10, 11, 11, 13, 20, 14, 12, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 19, 20, 20, 20, 20, 20, 14, 11, 12, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 10, 13, 20, 23, 29, 22, 20, 20, 20, 21, 1, 1, 1, 1, 1,
        1, 1, 1, 10, 11, 13, 20, 20, 21, 1, 28, 29, 22, 20, 14, 11, 11, 11, 11, 11,
        11, 11, 11, 13, 20, 20, 20, 23, 30, 1, 1, 1, 19, 20, 20, 20, 20, 20, 20, 20,
        20, 20, 20, 20, 20, 23, 29, 30, 1, 1, 1, 1, 28, 29, 29, 29, 29, 29, 29, 29,
        29, 29, 29, 29, 29, 30, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 20,
      height = 12,
      id = 11,
      name = "tiles2",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        398, 399, 398, 399, 400, 407, 408, 409, 410, 0, 0, 0, 406, 398, 399, 400, 409, 400, 409, 400,
        407, 408, 407, 408, 407, 400, 417, 418, 419, 0, 0, 0, 415, 407, 408, 409, 418, 409, 418, 409,
        398, 399, 398, 399, 400, 329, 338, 339, 428, 0, 0, 0, 325, 326, 327, 418, 409, 418, 409, 418,
        407, 408, 407, 408, 407, 338, 347, 348, 0, 0, 0, 0, 334, 335, 336, 327, 328, 319, 320, 319,
        398, 399, 400, 329, 400, 347, 348, 349, 0, 0, 0, 0, 343, 344, 345, 346, 337, 328, 329, 328,
        407, 408, 409, 338, 339, 356, 357, 358, 0, 0, 0, 0, 0, 0, 354, 335, 346, 417, 418, 417,
        416, 417, 418, 347, 348, 349, 0, 0, 0, 0, 0, 0, 0, 0, 0, 354, 355, 426, 427, 426,
        425, 426, 427, 356, 357, 358, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 9,
      name = "objects_decal",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 66,
          name = "",
          type = "",
          shape = "rectangle",
          x = 576,
          y = 432,
          width = 40,
          height = 40,
          rotation = 0,
          gid = 3,
          visible = true,
          properties = {}
        },
        {
          id = 67,
          name = "",
          type = "",
          shape = "rectangle",
          x = 324,
          y = 160,
          width = 40,
          height = 40,
          rotation = 0,
          gid = 3,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 5,
      name = "markers",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 20,
          name = "spawn",
          type = "",
          shape = "point",
          x = 260,
          y = 360,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 75,
          name = "entry2",
          type = "",
          shape = "point",
          x = 720,
          y = 360,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 77,
          name = "entry3",
          type = "",
          shape = "point",
          x = 420,
          y = 110,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 76,
          name = "entry",
          type = "",
          shape = "point",
          x = 80,
          y = 400,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 4,
      name = "objects",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 68,
          name = "savepoint",
          type = "",
          shape = "rectangle",
          x = 180,
          y = 300,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["text1"] = "* (The convenience of that\nlamp still fills you\nwith determination.)",
            ["ut"] = true
          }
        },
        {
          id = 70,
          name = "",
          type = "",
          shape = "rectangle",
          x = 510,
          y = 230,
          width = 40,
          height = 40,
          rotation = 0,
          gid = 676,
          visible = true,
          properties = {}
        },
        {
          id = 71,
          name = "interactable",
          type = "",
          shape = "rectangle",
          x = 510,
          y = 198,
          width = 40,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["solid"] = true,
            ["text1"] = "* (This is a box.)",
            ["text2"] = "* (You can put an item\ninside or take an item\nout.)",
            ["text3"] = "* (The same box will appear\nlater, so don't worry\nabout coming back.)",
            ["text4"] = "* (Sincerely,[wait:5] a box lover.)"
          }
        },
        {
          id = 72,
          name = "transition",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 320,
          width = 40,
          height = 120,
          rotation = 0,
          visible = true,
          properties = {
            ["map"] = "tundra2",
            ["marker"] = "entry2"
          }
        },
        {
          id = 74,
          name = "transition",
          type = "",
          shape = "rectangle",
          x = 760,
          y = 280,
          width = 40,
          height = 160,
          rotation = 0,
          visible = true,
          properties = {
            ["map"] = "tundra4",
            ["marker"] = "entry"
          }
        },
        {
          id = 78,
          name = "transition",
          type = "",
          shape = "rectangle",
          x = 360,
          y = 0,
          width = 120,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {
            ["map"] = "tundra3A",
            ["marker"] = "spawn"
          }
        },
        {
          id = 82,
          name = "storagebox",
          type = "",
          shape = "rectangle",
          x = 560,
          y = 200,
          width = 41.3333,
          height = 42,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 20,
      height = 12,
      id = 7,
      name = "tiles3",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        361, 362, 363, 362, 363, 362, 363, 364, 363, 364, 365, 0, 0, 0, 0, 361, 362, 363, 362, 363,
        370, 371, 372, 371, 372, 371, 372, 373, 372, 373, 374, 0, 0, 0, 0, 370, 371, 372, 371, 372
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 20,
      height = 12,
      id = 6,
      name = "tiles4",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 298, 299, 300, 301, 302, 303, 304, 304, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 307, 308, 309, 310, 311, 312, 313, 313, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 308, 309, 318, 319, 320, 321, 322, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 308, 317, 318, 327, 328, 329, 328, 311, 312, 0, 0, 0, 0, 0,
        309, 308, 309, 308, 309, 308, 317, 308, 309, 336, 337, 338, 329, 320, 321, 309, 308, 309, 308, 309
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 3,
      name = "collision",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 40,
          name = "",
          type = "",
          shape = "polygon",
          x = 280,
          y = 440,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 40, y = -40 },
            { x = 40, y = 0 }
          },
          properties = {}
        },
        {
          id = 41,
          name = "",
          type = "",
          shape = "polygon",
          x = 320,
          y = 400,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 40, y = -40 },
            { x = 40, y = 0 }
          },
          properties = {}
        },
        {
          id = 42,
          name = "",
          type = "",
          shape = "polygon",
          x = 360,
          y = 360,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 40, y = -40 },
            { x = 40, y = 0 }
          },
          properties = {}
        },
        {
          id = 43,
          name = "",
          type = "",
          shape = "rectangle",
          x = 400,
          y = 320,
          width = 40,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 45,
          name = "",
          type = "",
          shape = "polygon",
          x = 480,
          y = 360,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = -40, y = -40 },
            { x = -40, y = 0 }
          },
          properties = {}
        },
        {
          id = 46,
          name = "",
          type = "",
          shape = "polygon",
          x = 520,
          y = 400,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = -40, y = -40 },
            { x = -40, y = 0 }
          },
          properties = {}
        },
        {
          id = 47,
          name = "",
          type = "",
          shape = "polygon",
          x = 560,
          y = 440,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = -40, y = -40 },
            { x = -40, y = 0 }
          },
          properties = {}
        },
        {
          id = 48,
          name = "",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 440,
          width = 280,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 49,
          name = "",
          type = "",
          shape = "rectangle",
          x = 560,
          y = 440,
          width = 240,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 50,
          name = "",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 280,
          width = 120,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 51,
          name = "",
          type = "",
          shape = "polygon",
          x = 120,
          y = 320,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 40, y = -40 },
            { x = 0, y = -40 }
          },
          properties = {}
        },
        {
          id = 52,
          name = "",
          type = "",
          shape = "polygon",
          x = 160,
          y = 280,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 40, y = -40 },
            { x = 0, y = -40 }
          },
          properties = {}
        },
        {
          id = 53,
          name = "",
          type = "",
          shape = "polygon",
          x = 200,
          y = 240,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 40, y = -40 },
            { x = 0, y = -40 }
          },
          properties = {}
        },
        {
          id = 54,
          name = "",
          type = "",
          shape = "polygon",
          x = 240,
          y = 200,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 40, y = -40 },
            { x = 0, y = -40 }
          },
          properties = {}
        },
        {
          id = 55,
          name = "",
          type = "",
          shape = "polygon",
          x = 280,
          y = 160,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 40, y = -40 },
            { x = 0, y = -40 }
          },
          properties = {}
        },
        {
          id = 69,
          name = "",
          type = "",
          shape = "polygon",
          x = 320,
          y = 120,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 40, y = -40 },
            { x = 0, y = -40 }
          },
          properties = {}
        },
        {
          id = 56,
          name = "",
          type = "",
          shape = "rectangle",
          x = 320,
          y = 0,
          width = 40,
          height = 80,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 58,
          name = "",
          type = "",
          shape = "rectangle",
          x = 640,
          y = 240,
          width = 160,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 59,
          name = "",
          type = "",
          shape = "rectangle",
          x = 600,
          y = 160,
          width = 40,
          height = 80,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 63,
          name = "",
          type = "",
          shape = "polygon",
          x = 640,
          y = 280,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 0, y = -40 },
            { x = -40, y = -40 },
            { x = 0, y = 0 }
          },
          properties = {}
        },
        {
          id = 64,
          name = "",
          type = "",
          shape = "rectangle",
          x = 524,
          y = 154,
          width = 80,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 65,
          name = "",
          type = "",
          shape = "rectangle",
          x = 484,
          y = 0,
          width = 40,
          height = 160,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
