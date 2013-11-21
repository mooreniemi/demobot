class CommandList

  def initialize(&default_block)
    @commands = {}
    @exclusive_commands = {}
    @ambiguity_handler = default_block unless default_block == nil
    @error_handler = nil
  end

  def to_s
    @commands.each {|c| p c}
  end

  def register(full_command, is_exclusive = false, &block)
    if not is_exclusive
      @commands[full_command] = block
    else
      @exclusive_commands[full_command] = block
    end
  end

  def register_ambiguity_handler(&block)
    @ambiguity_handler = block
  end

  def register_error_handler(&block)
    @error_handler = block
  end

  def execute(given_line, context)
    given_line.rstrip!
    parts = given_line.partition(" ")
    exclusive_match = @exclusive_commands[parts[0]]
    if exclusive_match.present?
      return exclusive_match.yield(parts[2], context)
    end
    matches = look_up(parts[0])
    if matches.length == 0
      if @error_handler != nil
        @error_handler.yield(given_line, context)
      end
      return
    elsif matches.length > 1
      if matches.find_index(parts[0])
        @commands[parts[0]].yield(parts[2], context)
      elsif @ambiguity_handler != nil
        @ambiguity_handler.yield(matches, given_line, context)
      end
    else
      @commands[matches[0]].yield(parts[2], context)
    end
  end

  def look_up(given_command)
    @commands.keys.find_all { |val| val.start_with?(given_command) }
  end

end

