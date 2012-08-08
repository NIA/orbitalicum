#!/usr/bin/env ruby
puts "Loading....."

$LOAD_PATH.unshift File.expand_path File.join(File.dirname(__FILE__), 'lib')
require 'app'
require 'phys_object'

include Rubygame::Events

app = App.new 640, 480, "Orbitalicum game [work in progress]"

# Create sun
sun = PhysObject.new *app.screen.size.map{|x| x/2}
sun_gravity = Gravity.new sun.pos, 1e7

# Create sputnik
sputnik = PhysObject.new app.screen.size[0], app.screen.size[1]/2, 0, 150

app.run do |event|
  case event
  when KeyPressed
    if PhysObject.direction? event.key
      sputnik.push! event.key, 2
    end
  when ClockTicked
    app.draw do |screen|
      screen.draw_circle_s sun.pos_to_a, 20, [0, 0, 0]
      screen.draw_circle_s sputnik.pos_to_a, 10, [0, 0, 0]

      dt = event.seconds
      sputnik.move! dt, [sun_gravity]

      screen.draw_circle_s sun.pos_to_a, 20, [255, 255, 0]
      screen.draw_circle_s sputnik.pos_to_a, 10, [100, 100, 255]
    end
  else
    # Show the details of the event
    p event
  end
end
