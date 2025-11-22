

function _init()
    board = {};
    rows = 6;
    columns = 7;

    x_zero_pos = 128;
    y_zero_pos = 128;
    x_zero_pos = 0;
    y_zero_pos = 0;

    -- initialize empty field
    for col = 1,columns do
        board[col] = {}
        for row = 1,rows do
            board[col][row] = 0;
        end
    end

    player_1_to_move = true;
    current_frame = 0;

    -- everything related to delaying the inputs for a smooth experience
    input_delay = {
        frame_of_input = 0;
        input_detected = false;
        delay_margin = 2;
    }


    -- initialize players
    player_1 = {
        token_sprite = 33,
        cursor_pos = 4,
        board_id = 1,
        left_button = 0,
        right_button = 1,
    };

    player_2 = {
        token_sprite = 35,
        cursor_pos = 4,
        board_id = 2,
        left_button = 5,
        right_button = 4,
    };

    -- the active token only serves to draw the current active token.
    -- the actual position is saved in the player's cursor pos
    x_coord, y_coord = calculate_coords_from_field(1,0);
    active_token = {
        x_pos = x_coord,
        y_pos = y_coord,
        sprite = player_1.token_sprite,
    };

    -- redefine button press refresh rate
    poke(0x5f5c, 255);

    _set_fps(15);
end

function _update()
    user_input = get_user_input();
    if (user_input == "place") then
        if (player_1_to_move) then
            chosen_slot = player_1.cursor_pos;
        else
            chosen_slot = player_2.cursor_pos;
        end

        if (not (is_full(chosen_slot))) then
            send_token_down(chosen_slot);
        end

        player_1_to_move = not(player_1_to_move);
    else
        update_active_chip(user_input);
    end

    current_frame += 1;
end

function _draw()
    -- shift to debugger
    if (btn(2)) then
        x_zero_pos = 0;
        y_zero_pos = 0;
    else
        x_zero_pos = 128;
        y_zero_pos = 128;
        cls();
    end

    camera(x_zero_pos, y_zero_pos);
    paint_placed_chips();
    map();

    spr(active_token.sprite, active_token.x_pos, active_token.y_pos, 2,2);
end

-- this function checks the entire grid for tokens that have already
-- been placed and paints them accordingly
function paint_placed_chips()
    for col = 1,columns do
        for row = 1,rows do
            board_id = board[col][row];
            if (board_id == player_1.board_id) then
                sprite = player_1.token_sprite;
            elseif (board_id == player_2.board_id) then
                sprite = player_2.token_sprite;
            end

            if not (board_id == 0) then
                x_pos, y_pos = calculate_coords_from_field(col, row);
                spr(sprite, x_pos, y_pos, 2, 2);
            end
        end
    end
end

-- determines where the cursor is currently located
function update_active_chip(user_input)

    if (player_1_to_move) then
        player = player_1;
    else
        player = player_2;
    end

    if (user_input == "right") then
        player.cursor_pos += 1;
    elseif (user_input == "left") then
        player.cursor_pos -= 1;
    end

    if (player.cursor_pos <= 0) then
        player.cursor_pos = 7;
    elseif (player.cursor_pos >= 8) then
        player.cursor_pos = 1;
    end

    -- write active token state to cursor
    x_pos, y_pos = calculate_coords_from_field(player.cursor_pos,0);
    active_token.x_pos = x_pos;
    active_token.y_pos = y_pos;
    active_token.sprite = player.token_sprite;
end

-- takes in board position and calculates pixel position for sprite
function calculate_coords_from_field(column, row)
    x_coord = 16*column + x_zero_pos - 8;
    y_coord = 16*row + y_zero_pos + 16;

    if (row == 0) then
        y_coord = y_zero_pos + 4;
    end

    return x_coord, y_coord;
end

-- this function returns 1 or 2, if one of these players won, and 0 otherwise
function check_for_winner()
    -- check columns
    for col=1,7,1 do
        for row=1,3,1 do
            if not winner_found then
                winner_found = are_equal(col,row,col,row+1,col,row+2,col,row+3);
            end
        end
    end
    -- check rows
    for col=1,4,1 do
        for row=1,7,1 do
            if not winner_found then
                winner_found = are_equal(col,row,col+1,row,col+2,row,col+3,row);
            end
        end
    end
    -- check diagonals \
    for col=1,4,1 do
        for row=1,3,1 do
            if not winner_found then
                winner_found = are_equal(col,row,col+1,row+1,col+2,row+2,col+3,row+3);
            end
        end
    end
    -- check diagonals /
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

-- this function takes in for column row pairs and checks if their entries machtch up
function are_equal(col1,row1,col2,row2,col3,row3,col4,row4)
    first_entry = board[col1][row1];
    if (not(board[col2][row2] == first_entry)) then
        return false;
    end
    if (not(board[col3][row3] == first_entry)) then
        return false;
    end
    if (not(board[col4][row4] == first_entry)) then
        return false;
    end
    return true;
end

-- this function takes in a column and returns the first free entry
-- be careful, since this does not take into account columns that are already full
function send_token_down(column)
    row = 1;
    repeat
        current_slot = board[column][row];
        row+=1;
    until (not(current_slot == 0) or (row >= 6));

    if (player_1_to_move) then
        player = player_1;
    else
        player = player_2;
    end

    board[column][row] = player.board_id;
end

-- this function checks whether a given column is full or not by inspecting the top element
function is_full(column)
    if (board[column][1] == 0) then
        return false;
    else
        return true;
    end
end

-- this function registers what the user is doing
-- only takes inputs from active player
function get_user_input()

    if (player_1_to_move) then
        player = player_1;
    else
        player = player_2;
    end

    -- introcude a small delay for buttons to not clip
    if (btn() and not(input_delay.input_detected)) then
        input_delay.frame_of_input = current_frame;
        input_delay.input_detected = true;
    elseif (btn() and (input_delay.input_detected)) then
        input_delay.input_detected = true;
    else
        input_delay.input_detected = false;
    end

    -- if the delay is big enough, check for inputs now
    if (current_frame - input_delay.frame_of_input >= input_delay.delay_margin) then
        -- pressing both buttons does nothing on player 1, and
        if (btn(player.left_button) and btn(player.right_button)) then
            if (player == player_2) then
                return "place";
            elseif (player == player_1) then
                return "idle";
            end
        end

        -- pressing down button as player 1 places the chip
        if (player == player_1 and btnp(3)) then
            return "place";
        end

        -- pressing left or right button as either player moves the chip
        if (btnp(player.right_button)) then
            return "right";
        elseif (btnp(player.left_button)) then
            return "left";
        end
    end
    return "idle";
end


