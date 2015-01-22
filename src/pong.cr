require "sdl2"

include SDL2

UP = 0
DOWN = 1
LEFT = 2
RIGHT = 3

SDL2.init INIT::VIDEO

record World, w, h

class Entity
  property x, y
  delegate h, @tex_rect
  delegate w, @tex_rect

  def initialize(@texture, @tex_rect)
    @x = 0.0
    @y = 0.0
  end

  def render(renderer)
    rect = Rect.new @x.to_i, @y.to_i, @tex_rect.w, @tex_rect.h
    renderer.copy @texture, @tex_rect, rect
  end
end

class Ball < Entity
  property vx, vy
  @vx = 0.0
  @vy = 0.0
end

def update_all(world, paddles, ball, controls, dt)
  ball.x += ball.vx * dt
  ball.y += ball.vy * dt

  paddles.each_with_index do |paddle, i|
    paddle.y += (controls[i][DOWN] - controls[i][UP]) * dt
    paddle.y = world.h - paddle.h if paddle.y > world.h - paddle.h
    paddle.y = 0 if paddle.y < 0
  end
end

def load_texture(renderer, filename)
  bitmap = SDL2.load_bmp_from_file filename
  bitmap_rect = bitmap.rect

  texture = renderer.create_texture bitmap
  bitmap.free
  {texture, bitmap_rect}
end

GAME_WIDTH = 1024
GAME_HEIGHT = 768
window = Window.new "Pong", 100, 100, GAME_WIDTH, GAME_HEIGHT, Window::Flags::SHOWN
renderer = window.create_renderer flags: Renderer::Flags::ACCELERATED | Renderer::Flags::PRESENTVSYNC

paddle_tex, paddle_rect = load_texture renderer, "assets/GreenPaddle.bmp"
ball_tex, ball_rect = load_texture renderer, "assets/Ball.bmp"

world = World.new GAME_WIDTH, GAME_HEIGHT
paddles = [Entity.new(paddle_tex, paddle_rect), Entity.new(paddle_tex, paddle_rect)]
paddles[0].x = 10
paddles[0].y = (GAME_HEIGHT - paddle_rect.h) / 2
paddles[1].x = GAME_WIDTH - paddle_rect.w - 10
paddles[1].y = (GAME_HEIGHT - paddle_rect.h) / 2

ball = Ball.new(ball_tex, ball_rect)
ball.x = (GAME_WIDTH - ball_rect.w) / 2
ball.y = (GAME_HEIGHT - ball_rect.h) / 2

ball.vx = 0.5
ball.vy = 0.5

quit = false

controls = Array.new(2) { Array.new(4, 0) }

last_ticks = SDL2.ticks
frames_ticks = last_ticks
frames = 0

until quit
  now_ticks = SDL2.ticks
  dt = now_ticks - last_ticks

  SDL2.poll_events do |event|
    case event.type
    when EventType::QUIT
      quit = true
    when EventType::KEYDOWN, EventType::KEYUP
      is_down = event.type == EventType::KEYDOWN ? 1 : 0
      case event.key.key_sym.scan_code
      when Scancode::ESCAPE
        quit = true
      when Scancode::UP
        controls[1][UP] = is_down
      when Scancode::DOWN
        controls[1][DOWN] = is_down
      when Scancode::LEFT
        controls[1][LEFT] = is_down
      when Scancode::RIGHT
        controls[1][RIGHT] = is_down
      when Scancode::W
        controls[0][UP] = is_down
      when Scancode::S
        controls[0][DOWN] = is_down
      when Scancode::A
        controls[0][LEFT] = is_down
      when Scancode::D
        controls[0][RIGHT] = is_down
      end
    end
  end

  update_all world, paddles, ball, controls, dt

  renderer.clear
  paddles.each &.render(renderer)
  ball.render renderer
  renderer.present

  last_ticks = now_ticks
  frames += 1

  if now_ticks - frames_ticks > 1000
    puts "FPS: #{frames.to_f / (now_ticks - frames_ticks) * 1000}"
    frames_ticks = now_ticks
    frames = 0
  end
end

SDL2.quit

