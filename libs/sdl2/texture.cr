class SDL2::Texture
  getter texture

  def initialize(@texture)
  end

  def to_unsafe
    @texture
  end
end
