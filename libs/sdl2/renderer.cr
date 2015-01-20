class SDL2::Renderer
  getter renderer

  def initialize(window, index, flags)
    @renderer = LibSDL2.create_renderer(window.window, index, flags)
    if @renderer.nil?
      raise "Can't create SDL render: #{SDL2.error}"
    end
  end

  def clear()
    LibSDL2.render_clear(renderer)
  end

  def present()
    LibSDL2.render_present(renderer)
  end

  def create_texture(surface)
    texture = LibSDL2.create_texture_from_surface(renderer, surface)
    raise "Can't create texture: #{SDL2.error}" unless texture
    Texture.new texture
  end

  def copy(texture, srcrect=nil, dstrect=nil)
    LibSDL2.render_copy renderer, texture, srcrect, dstrect
  end
end
