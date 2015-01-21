require "sdl2"

include SDL2

UP = 0
DOWN = 1
LEFT = 2
RIGHT = 3

SDL2.init INIT::VIDEO

window = Window.new "Pong", 100, 100, 1024, 768, Window::Flags::SHOWN
renderer = window.create_renderer flags: Renderer::Flags::ACCELERATED | Renderer::Flags::PRESENTVSYNC

bitmap = SDL2.load_bmp_from_file "assets/test.bmp"
bitmap_rect = bitmap.rect

puts "Loaded #{bitmap.w}x#{bitmap.h} bitmap"

texture = renderer.create_texture bitmap
bitmap.free

dst_rect = Rect.new 0, 0, 100, 100

quit = false

ax = 0
ay = 0
acceleration_mag = 4
arrows = Array.new(4, 0)

until quit
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
        arrows[UP] = is_down
      when Scancode::DOWN
        arrows[DOWN] = is_down
      when Scancode::LEFT
        arrows[LEFT] = is_down
      when Scancode::RIGHT
        arrows[RIGHT] = is_down
      end
    end
  end

  ax = arrows[RIGHT] - arrows[LEFT]
  ay = arrows[DOWN] - arrows[UP]

  dst_rect.x += ax * acceleration_mag
  dst_rect.y += ay * acceleration_mag

  renderer.clear
  renderer.copy texture, bitmap_rect, dst_rect
  renderer.present
end

SDL2.quit

