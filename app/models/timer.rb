class Timer < ActiveRecord::Base

  belongs_to :player
  belongs_to :game

  def timed_game
    game_message = "Ready to challenge yourself at blitz chess? How many minutes?"
    puts game_message
    game(%Q{say -v "White Player" #{game_message}})
    minutes = gets.chomp.to_i
  end

  def start_time  
    @running = true 
    @start_time = Time.now
    seconds = minutes * 60
  end
  
  def stop_time
    if @running
      defuse
      @stop_time = Time.now
      @running = false
      @time_left -= (@stop_time - @start_time)
      time = @time_left
    else
      nil
    end
    puts "Your time is up."
  end
end
# ----------------------------------------------------
# EXAMPLE OF COUNTDOWN CODE
# t = Time.new(0)
# countdown_time_in_minutes = 300 # change this value

# countdown_time_in_minutes.downto(0) do |minutes|
#   puts (t + seconds).strftime('%H:%M:%S')
# end