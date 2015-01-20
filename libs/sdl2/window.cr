class SDL2::Window
  getter window
  getter title
  getter x
  getter y
  getter width
  getter height

  def initialize(@title, @x, @y, @width, @height, flags)
    @window = LibSDL2.create_window(title, x, y, width, height, flags)
    if @window.nil?
      raise "Can't create SDL window: #{SDL2.error}"
    end
  end

  def get_surface()
    surface = LibSDL2.get_window_surface(@window)
    if surface.nil?
      raise "Can't get surface: #{SDL2.error}"
    end
    return surface
  end

  def update_surface()
    value = LibSDL2.update_window_surface(@window)
    if value != 0
      raise "Can't update window surface: #{SDL2.error}"
    end
  end

end
