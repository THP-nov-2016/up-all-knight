class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :update, :destroy, :draw, :reject_draw, :forfeit, :add_player]
  before_action :set_user_color, :set_opponent_id, only: [:show, :draw, :reject_draw, :forfeit]
  before_action :authenticate_player!, only: [:show, :new, :create, :update, :destroy, :add_player, :draw, :reject_draw, :forfeit]
  
  
  attr_accessor :name
  
  def name
    "Game #{self.id}"
  end
  
  # GET /games
  # GET /games.json
  def index
    @games = Game.is_available
  end
  
  # GET /games/1
  # GET /games/1.json
  def show
    @game = Game.find(params[:id])
    @pieces = @game.pieces
    @white_player_timer = @game.timers.where(:player_id => @game.white_player_id).last
    @black_player_timer = @game.timers.where(:player_id => @game.black_player_id).last
  end
  
  # GET /games/new
  def new
    @game = Game.new
  end
  
  # GET /games/1/edit
  def edit
  end
  
  # POST /games
  # POST /games.json
  def create
    @game = Game.new(game_params)
    if @game.white_player_id == 0
      @game.black_player_id = current_player.id
    else
      @game.black_player_id = 0
    end
    @game.save
    @game.set_default_turn!

    if @game.save && @game.is_blitz
      @game.create_timers(params[:time_left])
    end
    redirect_to game_path(@game)
  end
  
  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { render :edit }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @game.destroy
    redirect_to root_path
  end
  
  def add_player
    current_player.join_game!(@game)
    @game.update_timer(current_player)
    redirect_to game_path
  end
  
  def draw
    if @game.white_draw && @game.black_draw
      Pusher["broadcast_#{@game.id}"].trigger!('draw_forfeit', {
      :message => "The game has come to a draw."
      })

      Pusher["broadcast_#{@game.id}"].trigger!('hide_buttons', {})
      Player.where(id: @game.white_player_id).take.add_draw!
      Player.where(id: @game.black_player_id).take.add_draw!
    elsif @game.white_draw && !@game.black_draw
      Pusher["broadcast_#{@game.id}"].trigger!('draw_forfeit', {
      :message => "White has requested a draw. Black may accept or reject the draw."
      })
      if @color == :white
        Pusher["private-user_#{current_player.id}"].trigger!('hide_buttons', {})
        Pusher["private-user_#{@opponent_id}"].trigger!('show_draw_response_buttons', {})
      elsif @color == :black
        Pusher["private-user_#{current_player.id}"].trigger!('show_draw_response_buttons', {})
        Pusher["private-user_#{@opponent_id}"].trigger!('hide_buttons', {})
      end
    elsif @game.black_draw && !@game.white_draw
      Pusher['broadcast_#{@game.id}'].trigger!('draw_forfeit', {
      :message => "Black has requested a draw. White may accept or reject the draw."
      })
      if @color == :black
        Pusher["private-user_#{current_player.id}"].trigger!('hide_buttons', {})
        Pusher["private-user_#{@opponent_id}"].trigger!('show_draw_response_buttons', {})
      elsif @color == :white
        Pusher["private-user_#{current_player.id}"].trigger!('show_draw_response_buttons', {})
        Pusher["private-user_#{@opponent_id}"].trigger!('hide_buttons', {})
      end
    end
  end

  def reject_draw
    if @game.white_draw && !@game.black_draw
      Pusher["broadcast_#{@game.id}"].trigger!('draw_forfeit', {
      :message => "Black has rejected the draw. White, you may forfeit or play on."
      })
      if @color == :white
        Pusher["private-user_#{current_player.id}"].trigger!('show_forfeit_button', {})
        Pusher["private-user_#{@opponent_id}"].trigger!('show_default_button', {})
      elsif @color == :black
        Pusher["private-user_#{current_player.id}"].trigger!('show_default_button', {})
        Pusher["private-user_#{@opponent_id}"].trigger!('show_forfeit_button', {})
      end
    elsif @game.black_draw && !@game.white_draw
      Pusher["broadcast_#{@game.id}"].trigger!('draw_forfeit', {
      :message => "White has rejected the draw. Black, you may forfeit or play on."
      })
      if @color == :black
        Pusher["private-user_#{current_player.id}"].trigger!('show_forfeit_button', {})
        Pusher["private-user_#{@opponent_id}"].trigger!('show_default_button', {})
      elsif @color == :white
        Pusher["private-user_#{current_player.id}"].trigger!('show_default_button', {})
        Pusher["private-user_#{@opponent_id}"].trigger!('show_forfeit_button', {})
      end
    end
  end
            
  def forfeit
    if @game.white_forfeit
      Pusher["broadcast_#{@game.id}"].trigger!('draw_forfeit', {
      :message => "White has forfeited. Black is the victor. Congratulations!"
      })
      Player.where(id: @game.white_player_id).take.add_loss!
      Player.where(id: @game.black_player_id).take.add_win!
    elsif @game.black_forfeit
      Pusher["broadcast_#{@game.id}"].trigger!('draw_forfeit', {
      :message => "Black has forfeited. White is the victor. Congratulations!"
      })
      Player.where(id: @game.white_player_id).take.add_win!
      Player.where(id: @game.black_player_id).take.add_loss!
    end
    Pusher["broadcast_#{@game.id}"].trigger!('hide_buttons', {})
  end
                
  private
                
  def set_user_color
    if current_player.id == @game.black_player_id
      @color = :black
    elsif current_player.id == @game.white_player_id
      @color = :white
    else
      @color = nil
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def game_params
    params.require(:game).permit(:current_turn, :white_player_id, :is_blitz, :black_draw, :white_draw, :black_forfeit, :white_forfeit)

  end
  
end

