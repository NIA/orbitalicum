require "rubygems"
require "v2d"

# A central force (actually, acceleration) field.
# It's value is A/(r^N) where A (amplitude) and N (degree)
# are constants, r is the distance from center to pos.
# When A > 0 -- it is attraction, when A < 0 -- repulsion.
class Gravity
  # Min distance for the force to act
  # (to avoid division by zero)
  MIN_DISTANCE = 1e-6

  def initialize(center, amplitude, degree = 2)
    @center, @a, @n = center, amplitude, degree
  end

  # Returns acceleration at given position
  def at(pos)
    r = pos - @center
    return V2D[0, 0] if r.abs < MIN_DISTANCE
    gravity = r * (-@a) / (r.abs ** (@n+1) )
  end
end

# An object that has its physical location and orientation
# and can move according to the laws of physics
class PhysObject
  attr_reader :pos
  attr_reader :speed
  attr_reader :acc
  MAX_DT = 0.02

  def initialize(posx, posy, speedx = 0, speedy = 0)
    @pos = V2D[posx, posy]
    @speed = V2D[speedx, speedy]
    @acc = V2D[0, 0]
  end

  def move!(dt, forces = [])
    dt = MAX_DT if dt > MAX_DT
    @acc = forces.inject(V2D[0,0]) {|acc, f| acc + f.at(@pos)}
    @speed += @acc * dt
    @pos += @speed * dt
  end

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

  def self.direction?(direction)
    [:left, :right, :up, :down].include? direction
  end

  # returns position as array [x, y]
  def pos_to_a
    [ pos.x, pos.y ]
  end
end
