
#require 'open-uri'
require_relative 'script_parser/character'
require_relative 'script_parser/line'
require 'nokogiri'

@characters = Character.all_instances
@lines = Line.all_instances
@cut = false
@class = ""

def characters_count
	@characters.size
end
def count_lines(xml_doc)
	get_lines(xml_doc)
	@lines.size
end

def is_markup? (line)
	line =~/<\/?div.*>/
end

def find_character(name)
	@characters.find { |character| character.name == name }
end

def edit_characters
    list_characters
    puts "If all characters look good, type \"Next\.\" Otherwise, type the ID number of the character you want to edit."
	choice = gets
	if choice.downcase =~ /next/
		puts "Ready to count"
	elsif choice =~ /([0-9])+/
		puts "thanks for entering an id of #{choice}"
		id = $_.to_i
		character = @characters.find { |x| x.id == id}
		puts "You have selected #{character.name}. To delete this character, type \"delete\.\" To edit this character, type \"edit.\" To cancel, type \"cancel.\""
		choice = gets.chomp
		if choice.downcase =~ /delete/
			@characters.delete(character)
        elsif choice.downcase =~ /edit/
        	puts "You have chosen to edit #{character.name}"
        	puts "To change the character's name, just type whatever the name should be."
        	edit = gets.chomp
        	character.name = edit.upcase
        elsif choice.downcase =~ /cancel/

        else
        	puts "I'm sorry, I didn't understand that input. Try again?" #make this better so it loops back
        end
    end
end
def get_characters(xml_doc)
	xml_doc.xpath("//person").each do |person|
		name = person.xpath('persName').text
		state =  person.xpath('state').text
		sex =  person.xpath('sex').text
		xml_id = person.attr('xml:id')
		Character.new(name: name, sex: sex, xml_id: xml_id, state: state)
	end
	# puts "Created the following characters:"
	# list_characters
end
def get_lines(xml_doc)
	xml_doc.xpath("//div1").each do |act|
		act_number = act.attr('n')
		act.xpath('div2').each do |scene|
			scene_number = scene.attr('n')
			scene.xpath('sp').each do |speech|
				character_xml_id = speech.attr('who')
				speech.xpath('ab//milestone').each do |line|
					if line.attr('ana')
						xml_id = line.attr('xml:id')
						cut_hs = line.attr('cut_hs')
						cut_gen = line.attr('cut_gen')
						number = line.attr('n')
						Line.new(act: act_number, scene: scene_number, character_xml_id: character_xml_id, cut_gen: cut_gen, cut_hs: cut_hs, number: number, xml_id: xml_id, )
					end
				end
			end
		end
	end
end
def list_characters
	@characters = @characters.uniq { |p| p.xml_id }
	@characters.each do |character|
		puts "#{character.id}  #{character.name}"
	end
end
def open_script(file)
	File.exists?(file)

	script = open(file) #currently optimized for Duchess of Malfi from Project Gutenberg

	contents = script.readlines
	contents_br = []
	contents.each do |c| #cleaning data up--default parser doesn't interpret <br> as new lines. Also apparently some encoding issues going on.
		c.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
		splits = c.split(/\<br\>/)
		contents_br += splits
	end
	@contents = contents_br
end
def self.run_time_hours(cut = '')
	self.run_time_minutes(cut)/60.00
end
def self.run_time_minutes(cut = '')
	self.total_lines(cut)/20.00
end
def self.total_lines(cut = '')
	if cut == 'cut_hs'
		return @lines.reject(&:cut_hs).size
	elsif cut == 'cut_gen'
		return @lines.reject(&:cut_gen).size
	else
		return @lines.size
	end
end
def self.characters_sort
	@characters.sort! { |a,b| a.line_count <=> b.line_count }
end
