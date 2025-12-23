

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

-- paint the available slot symbols including animation
function paint_slot_indicators()
    for name,slot in slot_indicator.available_slots do
        x_pos, y_pos = calculate_coords_from_field(slot, 0);
        spr(slot_indicator.arrow_sprite, x_pos, slot_current_positions.arrow_pos, 2, 2);
        spr(slot_indicator.epty_token_sprite, x_pos, slot_current_positions.empty_token_pos, 2, 2);
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

-- this function updates all empty positions and calculates the animation
function update_slot_indicators()
    slot_indicator.animation_frame = slot_indicator.animation_frame + 1;

    if (slot_indicator.animation_frame >= slot_indicator.total_frames) then
        slot_indicator.animation_frame = 0;
    end

    -- update all available slots
    for name,slot in slot_indicator.available_slots do
        if is_full(slot) then
            slot_indicator.available_slots.remove(slot);
        end
    end

    -- update positions
    for index = 1,4 do
        if (slot_indicator.animation_frame == slot_indicator.critical_frames[index]) then
            slot_current_positions[math.ceil(index/2)] = slot_animation_positions[index];
        end
    end
end


