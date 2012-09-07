require 'rubygems'
require 'rubygame'

include Rubygame::Color

# A set of convenience methods for drawing
module Graphics
  BG_COLOR = [0, 0, 0, 0]

  # A visual representation of a physical object
  class Circle
    def initialize(phys_object, color)
      @obj, @color = phys_object, color
    end

    def draw_on(surface)
      surface.draw_circle_s @obj.pos_to_a, @obj.radius, @color
    end

    def erase_on(surface)
      surface.draw_circle_s @obj.pos_to_a, @obj.radius, BG_COLOR
    end
  end

  # A visual representation of reaction: a fire from engine nozzle
  class Fire
    def initialize(phys_object, w, h, color)
      @obj, @w, @h, @color = phys_object, w, h, color
    end
    def draw_on(surface, axis)
      normal = V2D[axis.y, -axis.x]
      start = @obj.pos + axis*@obj.radius

      triangle = [axis*@h, normal*(@w/2), -normal*(@w/2)]
      triangle.map! {|v| (start + v).to_a }

      surface.draw_polygon_s triangle, @color
    end
  end

  # A wrapper class over Rubygame::Surface to handle zooming of
  # drawing area with no need to zoom bitmap: by changing coordinates
  # and size of primitive shapes on-the-fly
  class ZoomableSurface < Rubygame::Surface
    attr_accessor :zoom

    def initialize(size, depth = 0, flags = [])
      super size, depth, flags
      @zoom = 1.0
      @old_center = [width/2, height/2]
      @center = @old_center.dup
    end

    # Takes [dx,dy] in actual, non-zoomed coordinates
    # and adds this change to @center position
    def shift!(dr)
      (0..1).each { |i| @center[i] += dr[i] }
    end

    def draw_circle_s(pos, radius, color)
      super transformed(pos), radius*@zoom, color
    end

    def draw_polygon_s(points, color)
      points.map! {|p| transformed(p)}
      super points, color
    end

    def draw_line_a(point1, point2, color)
      super transformed(point1), transformed(point2), color
    end

    # Takes [x,y] of **point** in actual, non-zoomed coordinates,
    # returns screen coordinates [x1,y1] transformed by zoom
    def transformed(p)
      (0..1).map do |i|
        (p[i] - @old_center[i])*@zoom + (@center[i] - @old_center[i])*@zoom + @old_center[i]
      end
    end

    # Takes [x1,y1] of **point** in zoomed screen, returns
    # [x,y] in actual, non-zoomed coordinates
    def untransformed(p)
      (0..1).map do |i|
        (p[i] - @old_center[i])/@zoom + (@old_center[i] - @center[i]) + @old_center[i]
      end
    end

    # Takes [x1,y1] of **vector** in zoomed screen, returns
    # [x,y] in actual, non-zoomed coordinates
    def untransformed_vector(v)
      v.map{|x| x/@zoom }
    end
  end

  def self.draw_gradient_polyline(surface, points, color1, color2)
    return if points.count < 2

    color1 = ColorRGB.new_from_sdl_rgba(color1)
    color2 = ColorRGB.new_from_sdl_rgba(color2)

    n = points.count
    (n-2).downto(0) do |i|
      color = color2.average color1, i.to_f/(n-1)
      surface.draw_line_a points[i], points[i+1], color
    end
  end

  def self.font
    @@font ||= Rubygame::TTF.new "assets/DejaVuSansCondensed-Bold.ttf", 25
  end

  def self.draw_text(surface, text)
    smooth = true
    text_surface = self.font.render_utf8 text, smooth, [ 0xee, 0xee, 0x33]

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
