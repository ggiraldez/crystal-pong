struct SDL2::Rect
  def initialize(@rect : LibSDL2::Rect)
  end

  def self.new(x = 0 : Int, y = 0, w = 0, h = 0)
    new LibSDL2::Rect.new x: x, y: y, w: w, h: h
  end

  def x; @rect.x; end
  def x=(x); @rect.x = x; end

  def y; @rect.y; end
  def y=(y); @rect.y = y; end

  def w; @rect.w; end
  def w=(w); @rect.w = w; end

  def h; @rect.h; end
  def h=(h); @rect.h = h; end

  def to_unsafe
    @rect
  end

  def to_s(io)
    io << "Rect(x: " << x << ", y: " << y << ", w: " << w << ", h: " << h << ")"
  end

  def inspect(io)
    to_s(io)
  end
end
