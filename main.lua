

function _init()
    board = {};
    local rows = 6;
    local columns = 7;

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
    -- initialize players
    player_1 = {
        token_sprite = 33,
        cursor_pos = 4,
        left_button = 0,
        right_button = 1,
    };

    player_2 = {
        token_sprite = 35,
        cursor_pos = 4,
        left_button = 4,
        right_button = 5,
    };

    active_token = {
        x_pos = 0,
        y_pos = 0,
        sprite = player_1.token_sprite,
    };

    -- redefine button press refresh rate
    poke(0x5f5c, 255);

    _set_fps(15);
end

function _update()
    update_active_chip();
end

function _draw()
    cls();
    camera(x_zero_pos, y_zero_pos);
    map();
    spr(33, 184, 240, 2, 2);
    spr(35, 136, 160, 2, 2);

    spr(active_token.sprite, active_token.x_pos, active_token.y_pos, 2,2);
end

-- determines where the cursor is currently located
function update_active_chip()
    input = get_user_input()

    if (player_1_to_move) then
        player = player_1;
    else
        player = player_2;
    end

    if (input == "right") then
        player.cursor_pos += 1;
    elseif (input == "left") then
        player.cursor_pos -= 1;
    end

    if (player.cursor_pos == 0) then
        player.cursor_pos = 7;
    elseif (player.cursor_pos == 8) then
        player.cursor_pos = 1;
    end

    -- write active token state to cursor
    x_pos, y_pos = calculate_coords_from_field(player.cursor_pos,1);
    active_token.x_pos = x_pos;
    active_token.y_pos = y_zero_pos + 4;
    active_token.sprite = player.token_sprite;

end

-- takes in board position and calculates pixel position for sprite
function calculate_coords_from_field(row, column)
    x_coord = 16*row + x_zero_pos - 8;
    y_coord = 16*column + y_zero_pos + 16;
    return x_coord, y_coord;
end

-- this function takes in a column and returns the first free entry
function send_token_down(column)
    while field
        board[column]
end

-- this function registers what the user is doing
-- only takes inputs from active player
function get_user_input()

    if (player_1_to_move) then
        player = player_1;
    else
        player = player_2;
    end

    if (btnp(player.right_button)) then
        return "right";
    elseif (btnp(player.left_button)) then
        return "left";
    elseif (btn(player.left_button) and btn(player.right_button)) then
        return "place";
    else
        return "idle";
    end
end


