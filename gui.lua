

-- this function moves the x and y position to the
-- valid arguments are:
function update_canvas_position()
    if (current_canvas == "title") then
        x_zero_pos = 284;
        y_zero_pos = 148;
    elseif (current_canvas == "tutorial") then
        x_zero_pos = 0;
        y_zero_pos = 128;
    elseif (current_canvas == "field") then
        x_zero_pos = 128;
        y_zero_pos = 128;
    elseif (current_canvas == "black") then
        x_zero_pos = 0;
        y_zero_pos = 128;
    else
        print("what are you doing man");
    end

    if (debugging_mode) then
        x_zero_pos = 0;
        y_zero_pos = 0;
    end
end

-- this function takes care of displaying the title screen dialogue
function handle_title_screen_animations()
    -- randomize tokens
    for token_no = 1,#title_screen.token_positions do
        local current_token = title_screen.token_positions[token_no];
        if (current_token.y >= title_screen.token_end_position) then
            current_token.x = x_zero_pos + rnd(128);
            current_token.y = title_screen.token_start_position;
        elseif (title_screen.frame%2==0) then
            current_token.y = current_token.y + 1;
        end
        spr(current_token.sprite, current_token.x, current_token.y, 2, 2);
    end

    print("press ⬇️ to start", 315, 250, 12);
    title_screen.frame = title_screen.frame + 1;
end

-- this function takes care of guiding the users through the tutorial
function step_through_tutorial(user_input)
    local needed_move = tutorial.needed_moves[(tutorial.current_step-1)%3+1];
    local player = tutorial.player[ceil(tutorial.current_step/3)];
    if (user_input == needed_move) then
        if (user_input == "place") then
            player_1_to_move = not(player_1_to_move);
        end

        if not(user_input == needed_move) and not(user_input == "idle") then
            if (use_sound) then
                sfx(error_sound);
            end
        end
        if (user_input == "left") or (user_input == "right") then
            sfx(tutorial.player
        end
        if (tutorial.current_step == 6) then
            tutorial.finished = true;
        end

        tutorial.current_step = tutorial.current_step + 1;
    end
end
-- this function displays the current state of the tutorial
function display_tutorial()
    local player = tutorial.player[ceil(tutorial.current_step/3)];
    print(player.name, x_zero_pos+player.x_offset, y_zero_pos+30, player.id.color);
    print(tutorial.instructions[tutorial.current_step], x_zero_pos+player.x_offset+10, y_zero_pos+50, player.id.color);
end

-- this function takes care of animating a token that has been dropped
function move_camera()
    camera_x_pos = x_zero_pos;
    camera_y_pos = y_zero_pos;

    if (current_canvas == "field" or current_canvas == "tutorial") then
        if (drop_animation.active) then
            drop_animation.frame = drop_animation.frame + 1;
            camera_y_pos = y_zero_pos - drop_animation.offsets[drop_animation.frame];
        end
        if (slide_animation.active) then
            slide_animation.frame = slide_animation.frame + 1;
            local direction = 0;
            if (slide_animation.goes_to_the_right) then
                direction = -1;
            else
                direction = 1;
            end
            camera_x_pos = x_zero_pos + direction* slide_animation.offsets[slide_animation.frame];
        end

        if (drop_animation.frame == #(drop_animation.offsets)) then
            drop_animation.active = false;
            drop_animation.frame = 0;
        end
        if (slide_animation.frame == #(slide_animation.offsets)) then
            slide_animation.active = false;
            slide_animation.frame = 0;
        end
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

-- paint the available slot symbols including animation
function paint_slot_indicators()
    for index, slot_number in ipairs(slot_indicator.available_slots) do
        x_pos, _ = calculate_coords_from_field(slot_number, 0);
        spr(slot_indicator.arrow_sprite, x_pos, slot_current_positions[1], 2, 2);
        spr(slot_indicator.empty_token_sprite, x_pos, slot_current_positions[2], 2, 2);
    end
end

-- this function updates all empty positions and calculates the animation
function update_slot_indicators()
    slot_indicator.animation_frame = slot_indicator.animation_frame + 1;

    -- wrap back to 0
    if (slot_indicator.animation_frame >= slot_indicator.total_frames) then
        slot_indicator.animation_frame = 0;
    end

    -- update all available columns
    for index, slot_number in ipairs(slot_indicator.available_slots) do
        if is_full(slot_number) then
            del(slot_indicator.available_slots, slot_number);
        end
    end

    -- update positions
    for index, critical_frame in pairs(slot_indicator.critical_frames) do
        if (slot_indicator.animation_frame == critical_frame) then
            slot_current_positions[ceil(index/2)] = slot_animation_positions[index];
        end
    end
end


