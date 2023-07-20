--[[
   * ReaScript Name: Virtual Showcaller
   * Author: FLPRX
   * Author URI: http://flprx.it
   * Licence: Copyright © 2023, Filippo Rossi
]]


-- Global reference track
local reference_track = nil

function set_reference_track()
    reference_track = reaper.GetSelectedTrack(0, 0)
end

function get_previous_and_next_item()
    if reference_track == nil then
        return "No track selected", "No track selected", "No track selected", 0, 0
    end
    
    local track_items = reaper.CountTrackMediaItems(reference_track)
    if track_items == 0 then
        return "No items on track", "No items on track", "No items on track", 0, 0
    end

    local playhead_position = reaper.GetPlayPosition()
    local previous_item = "No previous item"
    local current_item = "No current item"
    local next_item = "No next item"
    local next_item_time = 0
    local current_item_end_time = 0
    for i = 0, track_items - 1 do
        local item = reaper.GetTrackMediaItem(reference_track, i)
        local item_position = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        local item_length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
        local item_note = reaper.ULT_GetMediaItemNote(item)
        if item_position + item_length < playhead_position then
            previous_item = check_empty(item_note)
        elseif item_position > playhead_position then
            next_item = check_empty(item_note)
            next_item_time = item_position - playhead_position
            break
        elseif item_position < playhead_position and item_position + item_length > playhead_position then
            current_item = check_empty(item_note)
            current_item_end_time = item_position + item_length - playhead_position
        end
    end
    
    return previous_item, current_item, next_item, next_item_time, current_item_end_time
end

function check_empty(item)
    if item == "" then
        return "[Empty item]"
    else
        return item
    end
end

function format_time(time)
    local minutes = math.floor(time / 60)
    local seconds = time % 60
    if minutes > 0 then
        return string.format("%d minutes and %.2f seconds", minutes, seconds)
    else
        return string.format("%.2f seconds", seconds)
    end
end

function format_short_time(time)
    local minutes = math.floor(time / 60)
    local seconds =  math.ceil(time % 60)
    if minutes > 0 then
        return string.format("%dm%ds", minutes, seconds)
    else
        return string.format("%ds", seconds)
    end
end

function draw_window()
    local previous_item, current_item, next_item, next_item_time, current_item_end_time = get_previous_and_next_item()
    gfx.init("Virtual Showcaller", 600, 400)

    -- Calculate font sizes and positions based on window size
    local font_size1 = math.max(10, gfx.h / 20)
    local font_size2 = math.max(10, gfx.h / 15)
    local line_spacing = gfx.h / 4
    
    local track_color = reaper.GetTrackColor(reference_track)
    if track_color == 0 then
        track_color = 25198720
    end
    
    local r, g, b = reaper.ColorFromNative(track_color)
    r = r / 255
    g = g / 255
    b = b / 255
    
    local _, track_name = reaper.GetTrackName(reference_track)

    
    gfx.set(r+0.3, g+0.3, b+0.3, 1)
    gfx.rect(0, 0, gfx.w, line_spacing * 0.4, 1)
    gfx.set(0, 0, 0, 1)    
    gfx.x = gfx.w * 0.02
    gfx.y = line_spacing * 0.1
    gfx.drawstr("Track: " .. track_name)
    
    gfx.setfont(1, "Arial", font_size1)
    gfx.set(r-0.3, g-0.3, b-0.3, 1)
    gfx.x = gfx.w * 0.02
    gfx.y = line_spacing * 0.5
    gfx.drawstr("Previous cue:")
    gfx.setfont(1, "Arial", font_size2)
    gfx.x = gfx.w * 0.02
    gfx.y = line_spacing * 0.7
    gfx.drawstr(previous_item)

    gfx.setfont(1, "Arial", font_size1)
    gfx.set(r, g, b, 1)
    gfx.x = gfx.w * 0.02
    gfx.y = line_spacing * 1.3
    gfx.drawstr("Current cue:")
    gfx.setfont(1, "Arial", font_size2*2)
    gfx.x = gfx.w * 0.65
    gfx.y = line_spacing * 1.5
    gfx.drawstr(format_short_time(current_item_end_time))
    gfx.setfont(1, "Arial", font_size2)
    gfx.x = gfx.w * 0.02
    gfx.y = line_spacing * 1.5
    gfx.drawstr(current_item)
    gfx.setfont(1, "Arial", font_size1)
    gfx.x = gfx.w * 0.02
    gfx.y = line_spacing * 1.9
    gfx.drawstr("Time to end of current cue: ")
    gfx.setfont(1, "Arial", font_size2)
    gfx.x = gfx.w * 0.02
    gfx.y = line_spacing * 2.1
    gfx.drawstr(format_time(current_item_end_time))
    gfx.setfont(1, "Arial", font_size1)
    
    gfx.set(r+0.3, g+0.3, b+0.3, 1)
    gfx.x = gfx.w * 0.02
    gfx.y = line_spacing * 2.7
    gfx.drawstr("Next cue:")
    gfx.setfont(1, "Arial", font_size2*2)
    gfx.x = gfx.w * 0.65
    gfx.y = line_spacing * 2.7
    gfx.drawstr(format_short_time(next_item_time))
    gfx.setfont(1, "Arial", font_size2)
    gfx.x = gfx.w * 0.02
    gfx.y = line_spacing * 2.9
    gfx.drawstr(next_item)
    gfx.setfont(1, "Arial", font_size1)
    gfx.x = gfx.w * 0.02
    gfx.y = line_spacing * 3.3
    gfx.drawstr("Time to next cue: ")
    gfx.setfont(1, "Arial", font_size2)
    gfx.x = gfx.w * 0.02
    gfx.y = line_spacing * 3.5
    gfx.drawstr(format_time(next_item_time))
end



function main()
    draw_window()
    gfx.update()
    
    -- If right mouse button is down, change reference track
    if gfx.mouse_cap == 2 then
        set_reference_track()
    end
    
  char = gfx.getchar()
  if char == 27 or char == -1 then gfx.quit() else reaper.defer(main) end
  
end

function Quit()
  gfx.quit()
end

-- Set the reference track when the script is run
set_reference_track()

-- Start the main loop

main()
reaper.atexit(Quit)
