

-- this function registers what the user is doing
-- only accepts inputs from the active player
-- after one action has been performed, all buttons have to be released in order
-- to input the next action
function get_user_input()
    local player;

    if (player_1_to_move) then
        left_button_pressed = btn(0);
        right_button_pressed = btn(1);
        place_button_pressed = btn(3);
    else
        left_button_pressed = btn(5);
        right_button_pressed = btn(4);
        place_button_pressed = btn(5) and btn(4);
    end

    -- if an input has been detected, increment the counter until the input shoots, else do nothing
    if (left_button_pressed or right_button_pressed or place_button_pressed) and not(input.lock) then
        if (place_button_pressed) then
            input.input = "place";
        elseif (left_button_pressed) then
            input.input = "left";
        elseif (right_button_pressed) then
            input.input = "right";
        else
            input.input = "idle";
        end

        if (input.frames_passed > input.delay_frames) then
            input.frames_passed = 0;
            input.lock = true;
            return input.input;
        end
        input.frames_passed = input.frames_passed + 1;

    elseif not( left_button_pressed or right_button_pressed or place_button_pressed) then
        input.lock = false;
    else
        input.frames_passed = 0;
        input.input = "idle";
    end
    return "idle";
end

-- determines where the cursor is currently located
function update_active_chip(user_input)
    local player;

    if (player_1_to_move) then
        player = player_1;
    else
        player = player_2;
    end

    if (user_input == "right") then
        player.cursor_pos = player.cursor_pos + 1;

    elseif (user_input == "left") then
        player.cursor_pos = player.cursor_pos - 1;
    end

    if (player.cursor_pos <= 0) then
        player.cursor_pos = 7;
    elseif (player.cursor_pos >= 8) then
        player.cursor_pos = 1;
    end

    if (user_input == "right") then
        while not(is_legal_column(player.cursor_pos)) do
            player.cursor_pos = player.cursor_pos + 1;
        end
    elseif (user_input == "left") then
        while not(is_legal_column(player.cursor_pos)) do
            player.cursor_pos = player.cursor_pos - 1;
        end
    end

    -- write active token state to cursor
    local x_pos, y_pos = calculate_coords_from_field(player.cursor_pos,0);
    active_token.x_pos = x_pos;
    active_token.y_pos = y_pos;
    active_token.sprite = player.token_sprite;
end

-- this function takes in a column and returns the first free entry
-- be careful, since this does not take into account columns that are already full
function send_token_down(column)
    local row = 0;
    local current_slot, player;
    repeat
        row = row + 1;
        current_slot = board[column][row];
    until (not(current_slot == 0) or (row >= 7));

    -- correct one down again, because row is currently set to the first
    -- encounter with chip
    row = row - 1;

    if (player_1_to_move) then
        player = player_1;
    else
        player = player_2;
    end

    board[column][row] = player.board_id;
end


