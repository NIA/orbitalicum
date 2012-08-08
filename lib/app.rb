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
    puts "Initializing..."
    # Open a window with a drawable area measuring w x h pixels
    @screen = Rubygame::Screen.open [w, h]
    # Set the title of the window
    @screen.title = title

    # Create a queue to receive events+
    #  + events such as "the mouse has moved", "a key has been pressed" and so on
    @event_queue = Rubygame::EventQueue.new

    # Don't care about mouse movement, so let's ignore it.
		@event_queue.ignore = [Rubygame::Events::MouseMoved]

    # Use new style events so that this software will work with Rubygame 3.0
    @event_queue.enable_new_style_events

    setup_clock
  end

  def setup_clock
    @clock = Rubygame::Clock.new
    @clock.target_framerate = 60

    # Adjust the assumed granularity to match the system.
    # This helps minimize CPU usage on systems with clocks
    # that are more accurate than the default granularity.
    print "Calibrating clock..."
    @clock.calibrate
    puts "Done"

    # Make Clock#tick return a ClockTicked event.
    @clock.enable_tick_events
  end
  private :setup_clock

  # Drawing code should be passed as block.
  # This function invokes it and then flips screen
  def draw
    yield @screen

    # Show the changes to the screen surface by flipping the buffer that is visible
    # to the user.  All changes made to the screen surface will appear
    # simultaneously
    @screen.flip
  end

  # Starts the main loop, invoking the given block
  # for each event that happens in run time
  def run
    catch :quit do
      loop do
        # Prepare events
        @event_queue.fetch_sdl_events
        @event_queue << @clock.tick

        # Handle events
        @event_queue.each do |event|
          yield event if block_given?
          # Stop this program if the user closes the window
          throw :quit if event.is_a? Rubygame::Events::QuitRequested
        end
      end
    end
  end
end

