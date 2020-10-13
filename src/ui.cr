require "keimeno"
require "colorize"
require "fuzzy"

module Rf
  alias SelectionRecord = Array(String | Array(Int32))

  class Menu < Keimeno::Base
    CRLF = "\n\r"

    def initialize(@dirs : Array(Dir), max_entries_shown : Int32)
      @selected_line = 0
      @buffer = [] of Char
      @shown = [] of SelectionRecord
      @dirs.each do |dir|
        @shown << [dir.path, [] of Int32]
      end
      @window_height = max_entries_shown
      @show_cursor = 0
    end

    def puts(thing) : Nil
      STDERR.print thing
      STDERR.print CRLF
      STDERR.flush
    end

    def print(thing)
      STDERR.print thing
    end

    def colorize_selected(str : String, selected : Bool)
      if selected
        return str.colorize(:black).back(:white)
      end
      str
    end

    def colorize_match(str : String, selected : Bool)
      str = str.colorize(:light_red)
      if selected
        return str.back(:white)
      end
      str
    end

    def highlight_colorized(str : String, highlights : Array(Int32), selected : Bool)
      pad = "#{" ".colorize.back(:white)} "
      if selected
        cursor = "> ".colorize(:blue).mode(:bold)
        pad = "#{cursor}".colorize.back(:white)
      end

      if highlights.empty?
        return "#{pad}#{colorize_selected(str, selected)}"
      end

      highlights_cpy = highlights.dup.reverse
      build_str = "#{pad}"

      color_idx = highlights_cpy.pop

      str.each_char_with_index do |c, ix|
        chr = "#{c}"
        if color_idx == ix
          color_idx = highlights_cpy.pop?
          chr = colorize_match(chr, selected)
        else
          chr = colorize_selected(chr, selected)
        end
        build_str += "#{chr}"
      end
      build_str
    end

    def display
      @window_height.times do |ix|
        if !@shown[ix + @show_cursor]?
          next
        end
        dir = @shown[ix + @show_cursor]
        puts highlight_colorized(dir[0].as(String), dir[1].as(Array(Int32)), @selected_line.not_nil! == ix + @show_cursor)
      end
      puts "  [#{@shown.size}/#{@dirs.size}]".colorize(:dark_gray)
    end

    def run
      print SAVE_CURSOR
      loop do
        clear_line
        display
        show_input
        wait_for_input
        break if finished?
      end

      cleanup
      return_value
    end

    def wait_for_input
      keystroke = nil
      STDIN.raw do |stdin|
        @read_buffer = Bytes.new 12
        count = stdin.read @read_buffer

        keystroke = nil
        return if count == 0

        @read_string = @read_buffer.map(&.chr).join("").rstrip('\u{0}')

        if count == 1
          keystroke = process_input_char
        else
          keystroke = decode_function_character
        end
      end

      return unless keystroke
      key_pressed keystroke
    end

    def return_value
      @shown[@selected_line][0]
    end

    def cleanup
      clear_line
    end

    def key_ctrl_w
      while @buffer.size > 0 && @buffer[-1] != ' '
        @buffer.pop
      end
      @buffer.pop if @buffer.size > 0
      filter
    end

    def key_enter
      finish!
    end

    def key_escape
      key_ctrl_c
    end

    def key_up_arrow
      cursor_up
      # update view from the bottom
      if @selected_line == @shown.size - 1 && @show_cursor == 0
        @show_cursor = @shown.size - @window_height if @window_height < @shown.size
      end

      # scroll up
      if @show_cursor > @selected_line
        @show_cursor -= 1
      end
    end

    def key_down_arrow
      cursor_down
      # update view from the top
      if @selected_line == 0 && @show_cursor == @shown.size - @window_height
        @show_cursor = 0
      end

      # scroll down
      if @show_cursor + @window_height <= @selected_line
        @show_cursor += 1
      end
    end

    def key_backspace : Nil
      return unless @buffer.size > 0
      @buffer.pop
      filter
    end

    def character_key(keystroke) : Nil
      @buffer.push keystroke.data
      filter
    end

    def clear_line
      print RESTORE_CURSOR
      print CLEAR_DOWN
    end

    def show_input
      cursor = ">".colorize(:green)
      print "#{cursor} #{@buffer.join("")}"
    end

    def filter
      pattern = Fuzzy::Pattern.new(@buffer.join(""))
      to_show = [] of SelectionRecord
      @dirs.each do |dir|
        if pattern.match? dir.path
          matches = pattern.match(dir.path)
          to_show << [dir.path, matches.not_nil!]
        end
      end
      # reinit view
      @selected_line = 0
      @show_cursor = 0
      @shown = to_show
    end

    def cursor_up
      @selected_line -= 1
      @selected_line = @shown.size - 1 if @selected_line < 0
    end

    def cursor_down
      @selected_line += 1
      @selected_line = 0 if @selected_line == @shown.size
    end
  end
end
