require "sdl2"

include SDL2

RAND = Random.new

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
    rect = Rect.new @x.to_i - (@tex_rect.w / 2), @y.to_i - (@tex_rect.h / 2), @tex_rect.w, @tex_rect.h
    renderer.copy @texture, @tex_rect, rect
  end
end

class Ball < Entity
  property vx, vy
  property hold

  @hold = 2000
  @vx = 0.0
  @vy = 0.0

  def r
    (h + w) / 4
  end
end

class Paddle < Entity
  property speed_modifier
  @speed_modifier = 0.5
end

def reset_ball(ball)
  ball.x = GAME_WIDTH / 2
  ball.y = GAME_HEIGHT / 2
  ball.vx = -ball.vx
  ball.vy = 0.3 * (RAND.rand > 0.5 ? -1 : 1)
  ball.hold = 2000
end

def update_all(world, paddles, ball, scores, controls, dt)
  if ball.hold > 0
    ball.hold -= dt
  else
    ball.x += ball.vx * dt
    ball.y += ball.vy * dt
  end

  if (ball.y < ball.r && ball.vy < 0) || (ball.y > (world.h - ball.r) && ball.vy > 0)
    ball.vy = -ball.vy
  end

  if ball.vx < 0
    if ball.x < ball.r
      scores[1] += 1
      reset_ball ball
    elsif ball.x - ball.r < paddles[0].x + paddles[0].w / 2
      if ball.y + ball.r > paddles[0].y - paddles[0].h/2 &&
          ball.y - ball.r < paddles[0].y + paddles[0].h/2
        ball.vx = -ball.vx
        ball.vy = (ball.y - paddles[0].y) / paddles[0].h
      end
    end
  end

  if ball.vx > 0
    if ball.x > (world.w - ball.r)
      scores[0] += 1
      reset_ball ball
    elsif ball.x + ball.r > paddles[1].x - paddles[1].w / 2
      if ball.y + ball.r > paddles[1].y - paddles[1].h/2 &&
          ball.y - ball.r < paddles[1].y + paddles[1].h/2
        ball.vx = -ball.vx
        ball.vy = (ball.y - paddles[1].y) / paddles[1].h
      end
    end
  end

  paddles.each_with_index do |paddle, i|
    paddle.y += (controls[i][DOWN] - controls[i][UP]) * dt * paddle.speed_modifier
    paddle.y = world.h - paddle.h/2 if paddle.y > world.h - paddle.h/2
    paddle.y = paddle.h/2 if paddle.y < paddle.h/2
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
paddles = [Paddle.new(paddle_tex, paddle_rect), Paddle.new(paddle_tex, paddle_rect)]
paddles[0].x = 10 + paddle_rect.w / 2
paddles[0].y = (GAME_HEIGHT - paddle_rect.h) / 2
paddles[1].x = GAME_WIDTH - paddle_rect.w / 2 - 10
paddles[1].y = (GAME_HEIGHT - paddle_rect.h) / 2

scores = [0,0]
paddles[0].speed_modifier = 1
paddles[1].speed_modifier = 0.4

ball = Ball.new(ball_tex, ball_rect)
ball.x = (GAME_WIDTH - ball_rect.w) / 2
ball.y = (GAME_HEIGHT - ball_rect.h) / 2

ball.vx = 0.5 * (RAND.rand > 0.5 ? -1 : 1)
ball.vy = 0.5 * (RAND.rand > 0.5 ? -1 : 1)

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
        controls[0][UP] = is_down
      when Scancode::DOWN
        controls[0][DOWN] = is_down
      when Scancode::LEFT
        controls[0][LEFT] = is_down
      when Scancode::RIGHT
        controls[0][RIGHT] = is_down
      end
    end
  end

  # "AI"
  if ball.y > paddles[1].y + ball.r
    controls[1][DOWN] = 1
    controls[1][UP] = 0
  elsif ball.y < paddles[1].y - ball.r
    controls[1][DOWN] = 0
    controls[1][UP] = 1
  else
    controls[1][UP] = 0
    controls[1][DOWN] = 0
  end

  update_all world, paddles, ball, scores, controls, dt

  renderer.clear
  paddles.each &.render(renderer)
  ball.render renderer
  renderer.present

  last_ticks = now_ticks
  frames += 1

  if now_ticks - frames_ticks > 1000
    #puts "FPS: #{frames.to_f / (now_ticks - frames_ticks) * 1000}"
    frames_ticks = now_ticks
    frames = 0
  end
end

SDL2.quit

