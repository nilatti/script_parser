
#require 'open-uri'
require_relative 'script_parser/character'
@characters = Character.all_instances

def list_characters
	@characters = @characters.uniq { |p| p.name }
	@characters.each do |character|
		puts "#{character.id}  #{character.name}"
	end
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

def characters_count
	@characters.size
end
def self.characters_sort
	@characters.sort! { |a,b| a.line_count <=> b.line_count }
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

def get_characters
	dp = @contents.index { |x| x.include?("Dramatis Personae") } #where does the Dramatis Personae start?
	dp += 1 #we know we don't want the line that says "Dramatis Personae"

	end_dp = @contents.index { |x| x.include?("ACT I")} #where does the Dramatis Personae end?
	end_dp -= 1 #let's not include our end marker "act 1" as a character

	dramatis = @contents.slice!(dp..end_dp)

	dramatis.each do |line|
		if line =~ /([A-Z]{3,})/
		  newbie = Character.new($1) #will need some edits, such as where Duchess script lists "BOSOLA" as BOSOLA throughout script but as "DANIEL DE BOSOLA" in the DP.
		end
	end

	puts "Created the following characters:"
	list_characters

end

def count_lines
	@contents.each do |line|
		if line =~ /([A-Z]{3,})/
	        a = @characters.find { |x| x.name == $1 }
			if a.class == Character
				@current_character = a
	        end
		end
        if line =~ /\[|Enter|Exeunt|Scene|^\s$/
        	@current_character = nil
        end

        unless @current_character.nil?
			@current_character.increment_line_count
		    puts @current_character.name
		    puts line
		end
	end

end
