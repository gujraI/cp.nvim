# PLAN
```cp = {
  -- user-facing setup, called once during plugin init
  setup = function(opts) ... end,

  -- config populated by setup(), read by other functions as fallback defaults
  config = {
    default_language = "cpp",
    default_template = "...",
    window = {
      split_ratio = 0.5,
      float_width = 0.8,
      float_height = 0.6,
    },
  },

  -- language definitions 
  languages = {
    cpp = {
      extension = "cpp",
      compile_cmd = { "g++", "-O2", "-o", "%out%", "%src%" },
      run_cmd = { "%out%" },
    },
    python = {
      extension = "py",
      compile_cmd = nil,
      run_cmd = { "python3", "%src%" },
    },
    java = {
      extension = "java",
      compile_cmd = { "javac", "%src%" },
      run_cmd = { "java", "%classname%" },
    },
  },

  -- judge definitions — each an instantiated client + parser pair
  judges = {
    cses = {
      client = <CurlClient instance>,  -- has :request(endpoint, method, opts)
      parser = <cses_parser module>,   -- has .parse(html)
    },
    ...
  },

  detect_judge = function(input) ... end,      -- id/link -> judge key ("cses"/"cf")
  fetch_problem = function(client, id) ... end, -- client:request(...) -> body
  parse_problem = function(parser, body) ... end, -- parser.parse(body) -> struct

  -- test running
  test_problem = function(buf, examples) ... end, -- detects lang, runs cp.test primitives

  -- command entry points (bound to :Cp and :Test via vim.api.nvim_create_user_command)
  cp_command = function(args) ... end,
  test_command = function(args) ... end,
}```
- write CURL primitives
- write UI primitives for drawing floating UI etc
- write testing primitives, async test runner
- write html parsing primitives?
- handoff to agent for grunt work (cses client/parser module)

