#!/usr/bin/env ruby
puts "Loading....."

$LOAD_PATH.unshift File.expand_path File.join(File.dirname(__FILE__), 'lib')
require 'app'

app = App.new 640, 480, "Orbitalicum game [work in progress]"
screen = app.screen

app.run do |event|
  # Show the details of the event
  p event

  if event.is_a? Rubygame::Events::MouseMoved
    if event.buttons.include? :mouse_left
      screen.draw_circle_s event.pos, 30, [0, 0, 255]
    elsif event.buttons.include? :mouse_right
      screen.draw_circle_s event.pos, 30, [0, 0, 0]
    end

    # Show the changes to the screen surface by flipping the buffer that is visible
    # to the user.  All changes made to the screen surface will appear
    # simultaneously
    screen.flip
  end
end
