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
ZOOM_FACTOR = 1.2

app = App.new 1024, 768, "Orbitalicum game [work in progress]"

puts "Initializing the world...."

forces = []
drawables = []

orbit = []
path = []

# Create sun
sun = PhysObject.new 500, 400, 20
sun.enable_gravity! 1e7
drawables << Circle.new( sun, [255, 255, 0] )

# Create another star
star = PhysObject.new 300, 250, 30
star.enable_gravity! 2e7
drawables << Circle.new( star, [255, 128, 0] )

# Create little star
little = PhysObject.new 700, 300, 15
little.enable_gravity! 7.5e6
drawables << Circle.new( little, [128, 158, 255] )

stars = [sun, star, little]
stars.each { |s| s.elasticity = 0.6 }

# Create sputnik
sputnik = PhysObject.new 150, 150, 10, -40, 340
drawables << Circle.new( sputnik, [100, 100, 255] )

fire = { :normal => Fire.new( sputnik, 10, 15, [248, 238, 100] ),
         :turbo  => Fire.new( sputnik, 14, 22, [255, 245, 185] ) }

KEYS = { :left => :left, :right => :right, :forward => :up, :back => :down,
         :pause => :p, :slow => :s, :turbo => :left_shift, :drag => :mouse_left,
         :zoomin => :equals, :zoomout => :minus, :move_screen => :mouse_middle }

step = 0
paused = false
slow = false
push_dir = nil  # push direction
engine_mode = :normal
dragging = nil

background = Rubygame::Surface.load "assets/background.jpg" # Image from http://apod.nasa.gov/apod/ap050804.html
viewport = ZoomableSurface.new app.screen.size

app.run do |event|
  case event
  when KeyPressed
    case event.key
    when KEYS[:pause]
      paused = !paused
    when KEYS[:slow]
      slow = !slow
    when KEYS[:turbo]
      engine_mode = :turbo
    when KEYS[:zoomin]
      viewport.zoom *= ZOOM_FACTOR
    when KEYS[:zoomout]
      viewport.zoom /= ZOOM_FACTOR
    else
      action = KEYS.index(event.key)
      push_dir = action if PhysObject.direction? action
    end
  when KeyReleased
    case event.key
    when KEYS[push_dir]
      push_dir = nil
    when KEYS[:turbo]
      engine_mode = :normal
    end
  when MousePressed
    case event.button
    when KEYS[:drag]
      actual_pos = V2D[ *viewport.untransformed(event.pos) ]
      dragging = stars.detect { |s| s.include? actual_pos }
    when KEYS[:move_screen]
      dragging = viewport
    end
  when MouseReleased
    if [ KEYS[:drag], KEYS[:move_screen] ].include? event.button
      dragging = nil
    end
  when MouseMoved
    if dragging
      actual_rel = viewport.untransformed_vector event.rel
      dragging.shift! actual_rel
    end
  when ClockTicked
    next if paused
    step += 1
    app.draw do |screen|
      # TODO: check if it's slow
      background.blit viewport, [0,0]

      dt = slow ? 0.001 : 0.01 # event.seconds

      reaction = 2
      reaction *= 10 if engine_mode == :turbo
      reaction = [sputnik.speed.abs, reaction].min if push_dir == :back
      sputnik.push!( push_dir, reaction ) if push_dir
      sputnik.move! dt, stars

      t = 1
      orbit = sputnik.predict_orbit t, (t/dt).to_i, stars

      path.unshift(sputnik.pos_to_a) if step % 2 == 0
      path.pop if path.size > PATH_SIZE

      Graphics.draw_gradient_polyline viewport, path, [75, 75, 175], BG_COLOR
      Graphics.draw_gradient_polyline viewport, orbit, [255, 255, 255], BG_COLOR
      fire[engine_mode].draw_on viewport, -sputnik.direction_vector(push_dir) if push_dir and reaction > 0
      drawables.each {|x| x.draw_on viewport}
      Graphics.draw_text viewport, sputnik.speed.abs.to_i.to_s

      viewport.blit screen, [0, 0]
    end
  else
    # Show the details of the event
    p event
  end
end
