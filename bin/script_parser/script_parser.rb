require_relative '../../lib/script_parser'

puts "ready to parse"
@contents  = open_script("./data/antony_and_cleopatra.html")
get_characters
edit_characters
count_lines
self.characters_sort

puts self.total_lines
puts self.run_time_hours
# @characters.each do |character|
#   puts "#{character.name}\t#{character.line_count}"
# end
