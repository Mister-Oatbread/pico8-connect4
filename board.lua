

-- this function checks whether a given column is full or not by inspecting the top element
function is_full(column)
    if (board[column][1] == 0) then
        return false;
    else
        return true;
    end
end

-- this function determines whether all slots have been used already
function is_board_full()
    for column = 1,7 do
        if not(is_full(column)) do
            return false;
        end
    end
    return true;
end

-- takes in board position and calculates pixel position for sprite
function calculate_coords_from_field(column, row)
    local x_coord = 16*column + x_zero_pos - 8;
    local y_coord = 16*row + y_zero_pos + 16;

    if (row == 0) then
        y_coord = y_zero_pos + 4;
    end

    return x_coord, y_coord;
end

-- this function returns 1 or 2, if one of these players won, and 0 otherwise
function check_for_winner()
    local winner_found;

    -- check columns
    print("cols");
    for col=1,7,1 do
        for row=1,3,1 do
            if not winner_found then
                winner_found = are_equal(col,row,col,row+1,col,row+2,col,row+3);
            end
        end
    end

    -- check rows
    print("rows");
    for col=1,4,1 do
        for row=1,6,1 do
            if not winner_found then
                winner_found = are_equal(col,row,col+1,row,col+2,row,col+3,row);
            end
        end
    end

    -- check diagonals \
    print("left diag");
    for col=1,4,1 do
        for row=1,3,1 do
            if not winner_found then
                winner_found = are_equal(col,row,col+1,row+1,col+2,row+2,col+3,row+3);
            end
        end
    end

    -- check diagonals /
    print("right diag");
    for col=4,7,1 do
        for row=1,3,1 do
            if not winner_found then
                winner_found = are_equal(col,row,col-1,row+1,col-2,row+2,col-3,row+3);
            end
        end
    end

    -- this may be subject to change depending on when player to move changes
    if winner_found and player_1_to_move then
        return 1;
    elseif winner_found and not player_1_to_move then
        return 2;
    else
        return 0;
    end
end

-- this function takes in four column row pairs and check if they all belong
-- to one player
function are_equal(col1, row1, col2, row2, col3, row3, col4, row4)
    local first_entry = board[col1][row1];
    if (first_entry == 0) then
        return false;
    end
    if (not(board[col2][row2] == first_entry)) then
        return false;
    end
    if (not(board[col3][row3] == first_entry)) then
        return false;
    end
    if (not(board[col4][row4] == first_entry)) then
        return false;
    end

    -- if we reach this point, we have a winner
    -- write winning combination
    winning_tokens.x_1, winning_tokens.y_1 = calculate_coords_from_field(col1, row1);
    winning_tokens.x_2, winning_tokens.y_2 = calculate_coords_from_field(col2, row2);
    winning_tokens.x_3, winning_tokens.y_3 = calculate_coords_from_field(col3, row3);
    winning_tokens.x_4, winning_tokens.y_4 = calculate_coords_from_field(col4, row4);

    return true;
end

-- this function returns the number of tokens that have already been placed
function count_placed_tokens()
    number_of_tokens = 0;

    for col = 1,columns do
        for row = 1,rows do
            if not (board[col][row] == 0) then
                number_of_tokens = number_of_tokens + 1;
            end
        end
    end
    return number_of_tokens;
end


