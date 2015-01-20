require "sdl2"

SDL2.init(LibSDL2::INIT_VIDEO)

window = SDL2::Window.new "Pong", 100, 100, 1024, 768, LibSDL2::WINDOW_SHOWN

renderer = SDL2::Renderer.new window, -1, LibSDL2::RENDERER_ACCELERATED | LibSDL2::RENDERER_PRESENTVSYNC

bitmap = LibSDL2.load_bmp_rw(LibSDL2.rw_from_file("assets/test.bmp", "rb"), 1)
raise "Bitmap not loaded" unless bitmap

texture = renderer.create_texture bitmap

renderer.clear
renderer.copy texture, nil, nil
renderer.present

quit = false

until quit
  SDL2.poll_events do |event|
    puts "Event received: #{event.type}"
    if event.type == LibSDL2::QUIT || event.type == LibSDL2::KEYDOWN
      quit = true
    end
  end
end

