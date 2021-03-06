class Knight < Piece
  
  
  def unicode_symbol
    if self.get_color == WHITE
      return "&#9816;"
    else
      return "&#9822;"
    end
  end
  
  def valid_move?(destination_x, destination_y)
    valid = super
    if valid
      if (destination_x - self.x_position).abs != 2 || (destination_y - self.y_position).abs != 1
        if (destination_x - self.x_position).abs != 1 || (destination_y - self.y_position).abs != 2
          valid = false
        end
      end
    end
    return valid
  end
  
  def  is_obstructed?(destination_x, destination_y)
    return false
  end
end
