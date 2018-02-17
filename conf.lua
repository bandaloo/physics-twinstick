confTable = {}

function love.conf(t)
  t.console = true
  t.title = "physicstest"
  t.version = "0.10.2"
  t.window.width = 1280
  t.window.height = 720
  t.window.fsaa = 1
  t.window.highdpi = true
  confTable = t
end
