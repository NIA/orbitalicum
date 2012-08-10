require 'rubygems'
require 'rubygame'

include Rubygame::Color

# A set of convenience methods for drawing
module Graphics
  BG_COLOR = [0, 0, 0, 255]

  def self.draw_gradient_polyline(surface, points, color1, color2)
    return if points.count < 2

    color1 = ColorRGB.new_from_sdl_rgba(color1)
    color2 = ColorRGB.new_from_sdl_rgba(color2)

    n = points.count
    (n-2).downto(0) do |i|
      color = color2.average color1, i.to_f/(n-1)
      surface.draw_line points[i], points[i+1], color
    end
  end

  def self.draw_text(surface, text)
    font = Rubygame::TTF.new "C:/Windows/Fonts/arialbd.ttf", 25
    smooth = true
    text_surface = font.render_utf8 text, smooth, [ 0xee, 0xee, 0x33]

    # Determine the dimensions in pixels of the area used to render the text.  The
    # "topleft" of the returned rectangle is at [ 0, 0]
    rt = text_surface.make_rect

    # Re-use the "topleft" of the rectangle to indicate where the text should
    # appear on screen ( in this case, 8 pixels from the top right hand corner of
    # the screen
    rt.topleft = [ surface.width - 8 - rt.width,  8]

    # Copy the pixels of the rendered text to the screen
    text_surface.blit surface, rt
  end
end