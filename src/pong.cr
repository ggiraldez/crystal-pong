require "sdl2"

SDL2.init(LibSDL2::INIT_VIDEO)

window = SDL2::Window.new "Pong", 100, 100, 1024, 768, LibSDL2::WINDOW_SHOWN

renderer = SDL2::Renderer.new window, -1, LibSDL2::RENDERER_ACCELERATED | LibSDL2::RENDERER_PRESENTVSYNC

bitmap = LibSDL2.load_bmp_rw(LibSDL2.rw_from_file("assets/test.bmp", "rb"), 1)
raise "Bitmap not loaded" unless bitmap

puts "Loaded #{bitmap.value.w}x#{bitmap.value.h} bitmap"
bitmap_rect = LibSDL2::Rect.new x: 0, y: 0, w: bitmap.value.w, h: bitmap.value.h

texture = renderer.create_texture bitmap
LibSDL2.free_surface bitmap

dst_rect = LibSDL2::Rect.new x: 0, y: 0, w: 100, h: 100

quit = false

ax = 0
ay = 0
acceleration_mag = 4
arrows = Array.new(4, false)

until quit
  SDL2.poll_events do |event|
    if event.type == LibSDL2::QUIT
      quit = true
    end
    
    if event.type == LibSDL2::KEYDOWN || event.type == LibSDL2::KEYUP
      is_down = event.type == LibSDL2::KEYDOWN
      case event.key.key_sym.scan_code
      when LibSDL2::Scancode::ESCAPE
        quit = true
      when LibSDL2::Scancode::UP
        arrows[0] = is_down
      when LibSDL2::Scancode::DOWN
        arrows[1] = is_down
      when LibSDL2::Scancode::LEFT
        arrows[2] = is_down
      when LibSDL2::Scancode::RIGHT
        arrows[3] = is_down
      end
    end
  end

  ax = (arrows[2] ? -1 : 0) + (arrows[3] ? 1 : 0)
  ay = (arrows[0] ? -1 : 0) + (arrows[1] ? 1 : 0)

  dst_rect.y += ay * acceleration_mag
  dst_rect.x += ax * acceleration_mag

  renderer.clear
  renderer.copy texture, pointerof(bitmap_rect), pointerof(dst_rect)
  renderer.present
end

