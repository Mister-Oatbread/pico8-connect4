

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


