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
end

# An object that has its physical location and orientation
# and can move according to the laws of physics
class PhysObject
  attr_reader :pos
  attr_reader :speed
  attr_reader :acc
  MAX_DT = 0.02

  # Initializes the object with the given position
  # and speed, each as two components of a 2D vector
  def initialize(posx, posy, speedx = 0, speedy = 0)
    @pos = V2D[posx, posy]
    @speed = V2D[speedx, speedy]
    @acc = V2D[0, 0]
  end

  # Integrates the motion of the object for time step +dt+.
  # Forces are objects implementing #at method, which
  # takes 2D vector of position and returns 2D vector of
  # acceleration at this position
  #
  # Returns the new position of the object
  def move!(dt, forces = [])
    dt = MAX_DT if dt > MAX_DT
    @acc = forces.inject(V2D[0,0]) {|acc, f| acc + f.at(@pos)}
    @speed += @acc * dt
    @pos += @speed * dt
  end

  # Returns an array of points of orbit, where each point is
  # a pair of digits: [x1,y1], [x2,y2], ... , [xn,yn]
  # +t+ is time for which prediction is done,
  # +points+ is the resulting number of points
  def predict_orbit(t, points, forces = [])
    dt = t.to_f/points
    clone = self.clone
    orbit = []
    points.times { orbit << clone.move!(dt, forces) }
    orbit.map &:to_a
  end

  # Instantly adds speed correction with given +direction+ and +value+
  def push!(direction, value)
    case direction
    when :left
      @speed.x -= value
    when :right
      @speed.x += value
    when :up
      @speed.y -= value
    when :down
      @speed.y += value
    else
      raise "Illegal direction: #{direction}!"
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
