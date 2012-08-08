require "rubygems"
require "rubygame"

# == Application
# A wrapper over rubygame screen and event queue
class App
  attr_reader :screen

  # Creates a new instance of app with a single window with:
  # * +w+ - width
  # * +h+ - heigth
  # * +title+ - caption of the window
  def initialize(w, h, title)
    # Open a window with a drawable area measuring w x h pixels
    @screen = Rubygame::Screen.open [w, h]
    # Set the title of the window
    @screen.title = title

    # Create a queue to receive events+
    #  + events such as "the mouse has moved", "a key has been pressed" and so on
    @event_queue = Rubygame::EventQueue.new
    # Use new style events so that this software will work with Rubygame 3.0
    @event_queue.enable_new_style_events
  end

  # Starts the main loop, invoking the given block
  # for each event that happens in run time
  def run
    # Wait for an event
    while event = @event_queue.wait
      yield event if block_given?

      # Stop this program if the user closes the window
      break if event.is_a? Rubygame::Events::QuitRequested
    end
  end
end

