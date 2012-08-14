require "rubygems"
require "v2d"

# A central force (actually, acceleration) field.
# It's value is A/(r^N) where A (amplitude) and N (degree)
# are constants, r is the distance from obj to pos.
# When A > 0 -- it is attraction, when A < 0 -- repulsion.
class Gravity
  def initialize(obj, amplitude, min_dist, degree = 2)
    @obj, @a, @min_dist, @n = obj, amplitude, min_dist, degree
  end

  # Returns acceleration at given position
  def at(pos)
    r = pos - @obj.pos
    return V2D[0, 0] if r.abs < @min_dist
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
