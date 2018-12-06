class Line
  attr_accessor(:act, :character_xml_id, :cut_gen, :cut_hs, :number, :scene, :xml_id)
  @@lines = []
  def initialize(act:, character_xml_id:, cut_gen:, cut_hs:, number:, scene:, xml_id:)
    @act = act
    @character_xml_id = character_xml_id
    @cut_gen = get_bool_from_int(cut_gen)
    @cut_hs = get_bool_from_int(cut_hs)
    @number = number
    @scene = scene
    @xml_id = xml_id
    @@lines << self
    add_to_character
  end

  def add_to_character
    character_xml_id = @character_xml_id.sub(/#/,'')
    character = Character.all_instances.find {|x| x.xml_id == character_xml_id}
    if character
      character.lines << self
    else
      puts "no character"
      puts "#{@number}"
    end
  end

  def get_bool_from_int(int)
    if int.to_i == 1
      return true
    else
      return false
    end
  end

  def self.all_instances
    @@lines
  end
end
