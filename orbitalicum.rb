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
orbit = []
path = []
drawables = []

# Create sun
sun = PhysObject.new 400, 300, 20
forces << Gravity.new( sun.pos, 1e7 )
forces << SphereRepulsion.new( sun.pos, 2e3, 20+10 )
drawables << Circle.new( sun, [255, 255, 0] )

# Create another star
star = PhysObject.new 200, 150, 30
forces << Gravity.new( star.pos, 2e7 )
forces << SphereRepulsion.new( star.pos, 2e3, 30+10 )
drawables << Circle.new( star, [255, 128, 0] )

# Create sputnik
sputnik = PhysObject.new 50, 50, 10, -40, 340
drawables << Circle.new( sputnik, [100, 100, 255] )

step = 0

app.run do |event|
  case event
  when KeyPressed
    if PhysObject.direction? event.key
      sputnik.push! event.key, 2
    end
  when ClockTicked
    step += 1
    app.draw do |screen|
      # TODO: check if it's slow
      screen.fill BG_COLOR

      dt = event.seconds

      sputnik.move! dt, forces
      orbit = sputnik.predict_orbit 5, 500, forces
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
