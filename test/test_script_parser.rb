require 'test/unit'
#require_relative '../../script_parser/lib/script_parser/character'
require_relative '../bin/script_parser/script_parser.rb'
class CharacterTest < Test::Unit::TestCase


  def test_initialize
    a = Character.new("Jane")
    b = Character.new("Steve")
    assert_equal("JANE",a.name)
    assert_block do
    	b.id > a.id
    end
  end

  def test_incrementer
  	a = Character.new("Susan")
  	assert_equal(0, a.line_count)
  	a.increment_line_count
  	assert_equal(1, a.line_count)
  end
end

class ScriptParserTest < Test::Unit::TestCase
 def test_character_list
  @characters = Character.all_instances
  
  assert_not_same(@characters[0], @characters[1])
  assert_equal(3, @characters.size)

 end

 def test_open_script
  open_script("./data/test_script.html")
  assert_not_nil(@contents)
 end

 def test_get_characters
  
  open_script("./data/test_script.html")
  @characters = Character.all_instances
  get_characters
  assert_equal(20, @characters.size)
 end

 def test_count_lines
  open_script("./data/test_script.html")
  @characters = Character.all_instances
  get_characters
  count_lines
  cardinal = @characters.find { |x| x.name == "CARDINAL" }
  delio = @characters.find { |x| x.name == "DELIO"}
  duchess = @characters.find { |x| x.name == "DUCHESS"}
  assert_equal(1, cardinal.line_count )
  assert_equal(4, delio.line_count)
  assert_equal(0, duchess.line_count)
  assert_same(@current_character, cardinal)

 end


end