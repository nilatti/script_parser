require_relative '../../lib/script_parser'
require_relative '../../lib/html_writer'

puts "ready to parse"
@contents  = open_script("./data/richard3.txt")
xml_doc = File.read("./data/FolgerDigitalTexts_XML_R3/R3.xml") #for Folger Digital Texts, must remove the TEI tags at beginning and end
parsed_xml = Nokogiri::XML.parse(xml_doc)

# get_characters(parsed_xml)
# count_lines(parsed_xml)
# goal_time = 90 #minutes
# run_time_minutes = self.run_time_minutes('cut_hs')
# if run_time_minutes > goal_time
#   puts "I hate to tell you this, but you still need to cut #{(run_time_minutes - goal_time).round(2)} minutes from this text."
# end
read_xml(parsed_xml)
build_dictionary
create_html
# puts "HS cut"
# puts "#{self.total_lines('cut_hs')} lines"
# puts "#{self.run_time_hours('cut_hs')} hours"
# puts "#{self.run_time_minutes('cut_hs')} minutes"
#
# puts "Gen cut"
# puts "#{self.total_lines('cut_gen')} lines"
# puts "#{self.run_time_hours('cut_gen')} hours"
# puts "#{self.run_time_minutes('cut_gen')} minutes"

# @characters.each do |character|
#   puts "#{character.name}\t#{character.line_count}"
# end
