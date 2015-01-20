class SDL2::Surface
  getter surface
  getter width
  getter height
  getter bpp

  def initialize(@surface, @width, @height, @bpp)
  end

  def lock
    LibSDL2.lock_surface @surface
  end

  def unlock
    LibSDL2.unlock_surface @surface
  end

  def update_rect(x, y, w, h)
    LibSDL2.update_rect @surface, x, y, w, h
  end

  def flip
    LibSDL2.flip @surface
  end

  def []=(offset, color)
    (@surface.value.pixels as UInt32*)[offset] = color.to_u32
  end

  def []=(x, y, color)
    self[y.to_i32 * @width + x.to_i32] = color
  end

  def offset(x, y)
    x.to_i32 + (y.to_i32 * @width)
  end
end
