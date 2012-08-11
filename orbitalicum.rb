#!/usr/bin/env ruby
puts "Loading....."

$LOAD_PATH.unshift File.expand_path File.join(File.dirname(__FILE__), 'lib')
require 'app'
require 'phys_object'
require 'forces'
require 'graphics'

include Rubygame::Events
include Graphics

PATH_SIZE = 300

app = App.new 800, 600, "Orbitalicum game [work in progress]"

forces = []
drawables = []

orbit = []
path = []

# Create sun
sun = PhysObject.new 400, 300, 20
sun.enable_gravity! 1e7
drawables << Circle.new( sun, [255, 255, 0] )

# Create another star
star = PhysObject.new 200, 150, 30
star.enable_gravity! 2e7
drawables << Circle.new( star, [255, 128, 0] )

# Create little star
little = PhysObject.new 600, 200, 15
little.enable_gravity! 7.5e6
drawables << Circle.new( little, [128, 158, 255] )

stars = [sun, star, little]

# Create sputnik
sputnik = PhysObject.new 50, 50, 10, -40, 340
drawables << Circle.new( sputnik, [100, 100, 255] )

step = 0
paused = false
slow = false
push_dir = nil  # push direction


app.run do |event|
  case event
  when KeyPressed
    case event.key
    when :p
      paused = !paused
    when :s
      slow = !slow
    else
      push_dir = event.key if PhysObject.direction? event.key
    end
  when KeyReleased
    push_dir = nil
  when ClockTicked
    next if paused
    step += 1
    app.draw do |screen|
      # TODO: check if it's slow
      screen.fill BG_COLOR

      dt = slow ? 0.001 : 0.01 # event.seconds

      sputnik.push!( push_dir, 2 ) if push_dir
      sputnik.move! dt, stars

      t = 1
      orbit = sputnik.predict_orbit t, (t/dt).to_i, stars

      path.unshift(sputnik.pos_to_a) if step % 2 == 0
      path.pop if path.size > PATH_SIZE

      Graphics.draw_gradient_polyline screen, path, [75, 75, 175], BG_COLOR
      Graphics.draw_gradient_polyline screen, orbit, [255, 255, 255], BG_COLOR
      drawables.each {|x| x.draw_on screen}
      Graphics.draw_text screen, sputnik.speed.abs.to_i.to_s
    end
  else
    # Show the details of the event
    p event
  end
end
