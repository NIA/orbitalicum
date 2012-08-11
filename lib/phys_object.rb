require "rubygems"
require "v2d"

# Patch class V2D to add some functionality
# TODO: push this changes to gem itself
class V2D
  def -@
    return self * (-1)
  end
  def to_a
    return [self.x, self.y]
  end
  def scalar_mult(other)
    self.x*other.x + self.y*other.y
  end
end

# An object that has its physical location and orientation
# and can move according to the laws of physics
class PhysObject
  attr_reader :pos
  attr_reader :speed
  attr_reader :acc
  attr_reader :radius
  attr_reader :gravity
  MAX_DT = 0.02

  # Initializes the object with the given position
  # and speed, each as two components of a 2D vector
  def initialize(posx, posy, radius, speedx = 0, speedy = 0)
    @pos = V2D[posx, posy]
    @radius = radius
    @speed = V2D[speedx, speedy]
    @acc = V2D[0, 0]
    # By default gravity is disabled. If needed,
    # it should be enabled with PhysObject#enable_gravity
    @gravity = Gravity.new @pos, 0, @radius
  end

  def enable_gravity!(amplitude)
    @gravity = Gravity.new @pos, amplitude, @radius
  end

  # Integrates the motion of the object for time step +dt+.
  # Gravity and collision is taken into account for +objects+
  #
  # Returns the new position of the object
  def move!(dt, objects = [])
    dt = MAX_DT if dt > MAX_DT
    @acc = objects.inject(V2D[0,0]) {|acc, o| acc + o.gravity.at(@pos)}
    @speed += @acc * dt
    objects.each {|o| self.collide_with!(o)}
    @pos += @speed * dt
  end

  # Returns an array of points of orbit, where each point is
  # a pair of digits: [x1,y1], [x2,y2], ... , [xn,yn]
  # +t+ is time for which prediction is done,
  # +points+ is the resulting number of points
  def predict_orbit(t, points, objects)
    dt = t.to_f/points
    clone = self.clone
    orbit = []
    points.times { orbit << clone.move!(dt, objects) }
    orbit.map &:to_a
  end

  # Instantly adds speed correction with given +direction+ and +value+
  def push!(direction, value)
    forward = @speed / @speed.abs
    left = V2D[forward.y, -forward.x]

    case direction
    when :left
      @speed += left*value
    when :right
      @speed -= left*value
    when :up
      @speed += forward*value
    when :down
      @speed -= forward*value
    else
      raise "Illegal direction: #{direction}!"
    end
  end

  # Changes own speed in order to stop penetrating
  # +immovable_object+ if doing so
  def collide_with!(immovable_object)
    r = @pos - immovable_object.pos
    return if r.abs > @radius + immovable_object.radius

    normal = r/r.abs
    v_normal = @speed.scalar_mult normal
    if v_normal < 0
      @speed += normal*(-2*v_normal)
    end
  end

  # Checks if given symbol is a valid direction to be
  # passed to #push! method
  def self.direction?(direction)
    [:left, :right, :up, :down].include? direction
  end

  # returns position as array [x, y]
  def pos_to_a
    [ pos.x, pos.y ]
  end
end
