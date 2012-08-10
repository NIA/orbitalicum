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
    gravity = - r * @a / (r.abs ** (@n+1) )
    #gravity.tap {|x| puts "Gravity: #{x.x},#{x.y}" }
  end
end

# An imitaion of colision response with sphere,
# a simple Hooke's-law fore
class SphereRepulsion
  # Min distance for the force to act
  # (to avoid division by zero when normalizing ort)
  MIN_DISTANCE = 1e-6

  def initialize(center, k, radii)
    @center, @k, @radii = center, k, radii
  end

  def at(pos)
    r = pos - @center
    return V2D[0, 0] if r.abs > @radii or r.abs < MIN_DISTANCE
    ort = r / r.abs
    repulsion = ort * @k*(@radii - r.abs)
    #repulsion.tap {|x| puts "Repulsion: #{x.x},#{x.y}" }
  end
end
