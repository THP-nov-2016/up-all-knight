class PiecesController < ApplicationController
  
  def update
    if selected_piece.valid_move?(params[:piece][:x_position].to_i,params[:piece][:y_position].to_i)
      selected_piece.update_attributes(piece_params)
      render text: "Valid Move"
    else
      render text: "Invalid Move"
    end
  end
  
  private
  
  def piece_params
    params.require(:piece).permit(:x_position,:y_position)
  end
  
  def selected_piece
    @selected_piece ||= Piece.find(params[:id])
  end
end
