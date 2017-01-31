require_relative '../../lib/script_parser'

puts "ready to parse"
@contents  = open_script("../../data/test_script.html")
get_characters
edit_characters
count_lines
self.characters_sort
@characters.each do |character|
  puts "#{character.name}\t#{character.line_count}"
end
