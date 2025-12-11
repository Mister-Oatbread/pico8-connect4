

-- hello :3
function _init()
    debugging_mode = false;
    use_sound = true;

    board = {};
    rows = 6;
    columns = 7;

    if (debugging_mode) then
        x_zero_pos = 0;
        y_zero_pos = 0;
    else
        x_zero_pos = 128;
        y_zero_pos = 128;
    end

    camera_x_pos = x_zero_pos;
    camera_y_pos = y_zero_pos;

    if debugging_mode then
        cls();
    end

    -- initialize empty field
    for col = 1,columns do
        board[col] = {}
        for row = 1,rows do
            board[col][row] = 0;
        end
    end

    -- misc
    player_1_to_move = true;
    winner_detected = false;
    victory_sound = 60;
    victory_sound_started = false;

    -- everything related to delaying the inputs for a smooth experience
    input = {
        frames_passed = 0,
        input = "idle",
        delay_frames = 6,
    }

    -- initialize players
    player_1 = {
        token_sprite = 33,
        sound = 63,
        cursor_pos = 4,
        board_id = 1,
    };

    player_2 = {
        token_sprite = 35,
        sound = 62,
        cursor_pos = 4,
        board_id = 2,
    };

    -- the active token only serves to draw the current active token.
    -- the actual position is saved in the player's cursor pos
    local x_coord, y_coord = calculate_coords_from_field(1,0);
    active_token = {
        x_pos = x_coord,
        y_pos = y_coord,
        sprite = player_1.token_sprite,
    };

    songs = {
        switch_should_happen = true,
        current_song_index = 1,
        song_parts = {
            8,
            4,
            0,
        },
        thresholds = {
            0,
            4,
            8,
        },
    }

    drop_animation = {
        active = false,
        frame = 0,
        offsets = {
            1, 2, 4, 2, 1,
        },
    }

    winning_tokens = {
        sprite = 39,
        x_1 = 0,
        y_1 = 0,
        x_2 = 0,
        y_2 = 0,
        x_3 = 0,
        y_3 = 0,
        x_4 = 0,
        y_4 = 0,
    };

    available_slots = {
        1, 2, 3, 4, 5, 6, 7,
    };

    -- redefine button press refresh rate
    poke(0x5f5c, 255);

    _set_fps(60);
end

function _update60()

    if (use_sound) then
        handle_music();
    end

    if not(winner_detected) then
        local user_input = get_user_input();
        if (user_input == "place") then
            drop_animation.active = true;
            if (player_1_to_move) then
                chosen_slot = player_1.cursor_pos;
                if (use_sound) then
                    sfx(player_1.sound);
                end
            else
                chosen_slot = player_2.cursor_pos;
                if (use_sound) then
                    sfx(player_2.sound);
                end
            end

            if (not (is_full(chosen_slot))) then
                send_token_down(chosen_slot);
            end
            winner = check_for_winner();
            if (not(winner == 0)) then
                print("we have a winner");
                winner_detected = true;
            end

            player_1_to_move = not(player_1_to_move);
        else
            update_active_chip(user_input);
        end
    end
end

function _draw()
    -- shift to debugger
    if not(debugging_mode) then
        cls();
    end
    move_camera();

    camera(camera_x_pos, camera_y_pos);
    paint_placed_chips();
    map();

    if not(winner_detected) then
        spr(active_token.sprite, active_token.x_pos, active_token.y_pos, 2,2);
    end
end

-- this function takes care of animating a token that has been dropped
function move_camera()
    if (drop_animation.active) then
        drop_animation.frame = drop_animation.frame + 1;
        camera_y_pos = y_zero_pos - drop_animation.offsets[drop_animation.frame];
    else
        camera_y_pos = y_zero_pos;
    end

    if (drop_animation.frame == #(drop_animation.offsets)) then
        drop_animation.active = false;
        drop_animation.frame = 0;
    end
end

-- this function checks the entire grid for tokens that have already
-- been placed and paints them accordingly
function paint_placed_chips()
    local sprite;

    for col = 1,columns do
        for row = 1,rows do
            local board_id = board[col][row];
            if (board_id == player_1.board_id) then
                sprite = player_1.token_sprite;
            elseif (board_id == player_2.board_id) then
                sprite = player_2.token_sprite;
            end

            if not (board_id == 0) then
                local x_pos, y_pos = calculate_coords_from_field(col, row);
                spr(sprite, x_pos, y_pos, 2, 2);
            end

            -- paint winning tokens over other tokens
            if (winner_detected) then
                spr(winning_tokens.sprite, winning_tokens.x_1, winning_tokens.y_1, 2, 2);
                spr(winning_tokens.sprite, winning_tokens.x_2, winning_tokens.y_2, 2, 2);
                spr(winning_tokens.sprite, winning_tokens.x_3, winning_tokens.y_3, 2, 2);
                spr(winning_tokens.sprite, winning_tokens.x_4, winning_tokens.y_4, 2, 2);
            end
        end
    end
end

-- checks which columns are not already full, and stores information
-- in "available slots"
function update_available_slots()
    available_slots = {};
    for column = 1,columns do
        if (is_full()) then
            available_slots.add(column);
        end
    end
end

-- this function takes care of playing music
function handle_music()
    if not(winner_detected) then
        number_of_tokens = count_placed_tokens();

        -- if enough tokens have been placed, change song index
        for index = 1,#(songs.thresholds) do
            if (number_of_tokens >= songs.thresholds[index]) then
                songs.current_song_index = index;
            end
        end
        print(songs.current_song_index);

        -- if no song is playing, then do something
        if (stat(16) == -1) then
            next_song = songs.song_parts[songs.current_song_index];
            music(next_song);
        end
    else
        if not(victory_sound_started) then
            music(victory_sound);
            victory_sound_started = true;
        end
    end
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

    -- write active token state to cursor
    local x_pos, y_pos = calculate_coords_from_field(player.cursor_pos,0);
    active_token.x_pos = x_pos;
    active_token.y_pos = y_pos;
    active_token.sprite = player.token_sprite;
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

-- this function checks whether a given column is full or not by inspecting the top element
function is_full(column)
    if (board[column][1] == 0) then
        return false;
    else
        return true;
    end
end

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
    if (left_button_pressed or right_button_pressed or place_button_pressed) then
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
            return input.input;
        end

        input.frames_passed = input.frames_passed + 1;

    else
        input.frames_passed = 0;
        input.input = "idle";
    end
    return "idle";
end


