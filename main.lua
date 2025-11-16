

function _init()
    board = {};
    local rows = 6;
    local columns = 7;

    x_zero_pos = 128;
    y_zero_pos = 128;

    -- initialize empty field
    for col = 1,columns do
        board[col] = {}
        for row = 1,rows do
            board[col][row] = 0;
        end
    end

    -- initialize players
    player_1 = {
        token_sprite = 33,
        to_move = true,
    };

    player_2 = {
        token_sprite = 35,
        to_move = false,
    };
end

function _update()
end

function _draw()
    cls();
    camera(128,128);
    map();
    spr(33, 184, 240, 2, 2);
    spr(35, 136, 160, 2, 2);

    print(get_user_input());
end

-- takes in board position and calculates pixel position for sprite
function calculate_coords_from_field(row, column)
    x_coord = 16*row + x_zero_pos - 8;
    y_coord = 16*column + y_zero_pos + 16;
    return {x_coord, y_coord};
end

-- this function registers what the user is doing
-- only takes inputs from active player
function get_user_input()

    if (player_1.to_move) then
        player = 1;
    elseif (player_2.to_move) then
        player = 2;
    else
        print("it seems like it is neither player's turn");
    end

    if (btnp(1, player)) then
        return "right";
    elseif (btnp(0, player)) then
        return "left";
    else
        return "idle";
    end
end


