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

# Create sun
sun = PhysObject.new *app.screen.size.map{|x| x/2}
forces << Gravity.new( sun.pos, 1e7 )
forces << SphereRepulsion.new( sun.pos, 2e3, 20+10 )

# Create another star
star = PhysObject.new *app.screen.size.map{|x| x/4}
forces << Gravity.new( star.pos, 2e7 )
forces << SphereRepulsion.new( star.pos, 2e3, 30+10 )

# Create sputnik
sputnik = PhysObject.new 50, 50, -40, 340 #app.screen.size[0], app.screen.size[1]/2, 0, 150
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
      #screen.draw_circle_s sputnik.pos_to_a, 10, BG_COLOR
      #screen.draw_polygon orbit, BG_COLOR
      screen.fill BG_COLOR

      dt = event.seconds

      sputnik.move! dt, forces
      orbit = sputnik.predict_orbit 5, 500, forces
      path.unshift(sputnik.pos_to_a) if step % 2 == 0
      path.pop if path.size > PATH_SIZE

      #screen.draw_polygon orbit, [255, 255, 255]
      Graphics.draw_gradient_polyline screen, path, [75, 75, 175], BG_COLOR
      Graphics.draw_gradient_polyline screen, orbit, [255, 255, 255], BG_COLOR
      screen.draw_circle_s star.pos_to_a, 30, [255, 128, 0]
      screen.draw_circle_s sun.pos_to_a, 20, [255, 255, 0]
      screen.draw_circle_s sputnik.pos_to_a, 10, [100, 100, 255]

      Graphics.draw_text screen, sputnik.speed.abs.to_i.to_s
    end
  else
    # Show the details of the event
    p event
  end
end
