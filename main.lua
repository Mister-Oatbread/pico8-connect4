

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
    board_is_full = false;
    victory_sound = 60;
    victory_sound_started = false;

    -- everything related to delaying the inputs for a smooth experience
    input = {
        frames_passed = 0,
        input = "idle",
        delay_frames = 4,
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

    slot_indicator = {
        arrow_sprite = 9,
        empty_token_sprite = 37,

        error_sound = 59,
        current_available_slot_index = 4,
        available_slots = {
            1, 2, 3, 4, 5, 6, 7,
        },

        animation_frame = 0,
        total_frames = 60,
        critical_frames = {
            arrow_down = 15,
            arrow_up = 45,
            empty_token_down = 30,
            empty_token_up = 0,
        },

        animation_distance = 3,
        arrow_offset = 20,
        empty_token_offset = 10,
    };

    slot_animation_positions = {
        arrow_down = y_zero_pos + slot_indicator.arrow_offset + slot_indicator.animation_distance,
        arrow_up = y_zero_pos + slot_indicator.arrow_offset,
        empty_token_down = y_zero_pos + slot_indicator.empty_token_offset + slot_indicator.animation_distance,
        empty_token_up = y_zero_pos + slot_indicator.empty_token_offset,
    };

    slot_current_positions = {
        arrow_pos = slot_animation_positions[2],
        empty_token_pos = slot_animation_positions[4],
    },

    -- redefine button press refresh rate
    poke(0x5f5c, 255);

    _set_fps(60);
end

function _update60()

    if (use_sound) then
        handle_music();
    end

    if not(winner_detected) and not(board_is_full) then
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
        update_slot_indicators();
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
    paint_slot_indicators();
    map();

    if not(winner_detected) then
        spr(active_token.sprite, active_token.x_pos, active_token.y_pos, 2,2);
    end
end


