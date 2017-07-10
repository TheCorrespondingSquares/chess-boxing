class GamesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]

  def index
    @available_games = Game.available
    @games = @available_games.where.not(black_player_id: current_user).or(@available_games.where.not(white_player_id: current_user))
  end

  def new
    @game = Game.new
  end

  def create
    @game = Game.create(game_params)
    redirect_to game_path(@game)
  end

  def show
    @game = Game.find(params[:id])
    @white_player = User.find(@game.white_player_id)
    if @game.black_player_id == nil
      flash[:waiting] = "Waiting for another player to join..."
    else
       @black_player = User.find(@game.black_player_id)
    end
    @pieces = @game.pieces
  end

  def edit
    @game = Game.find(params[:id])
  end

  def update
    @game = Game.find(params[:id])
    @white_player = User.find(@game.white_player_id)
    @game.update_attributes(join_params)

    Pusher.trigger('channel', 'updateOnJoin', {
      message: 'Joined Game'
    })
    
    redirect_to game_path(@game)
  end

  private

  def game_params
    params.require(:game).permit(:name, :user_id, :white_player_id, :black_player_id, :turn)
  end

  def join_params
    params.permit(:black_player_id)
  end

  def black_player?
    current_user == @game.black_player
  end
end
