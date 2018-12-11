require_relative 'script_parser/character'
require_relative 'script_parser/line'
require 'nokogiri'

@current_speaker = ''

def add_value_to_dictionary(value)
  key = value.attr('xml:id')
  @dictionary[key] = value
end

def build_act(act)
  puts "buiding act #{act.attr('n')}"
  @html << "<div class='act'>"
    @html << "<h2>"
      @html << "Act #{act.attr('n')}"
    @html << "</h2>"
  @html << "</div>"
  act.xpath("//div2").each do |scene|
    build_scene(act, scene)
  end
end

def build_dictionary
  puts "buildng dictionary"
  @dictionary = {}
  @file.xpath('//w').each do |value|
    add_value_to_dictionary(value)
  end
  @file.xpath('//pc').each do |value|
    add_value_to_dictionary(value)
  end
  @file.xpath('//c').each do |value|
    add_value_to_dictionary(value)
  end
end

def build_line
end

def build_play
  puts "building play"
  @file.xpath("//div1").each do |act|
    build_act(act)
  end
end

def build_scene(act, scene)
  puts "building scene #{scene.attr('n')}"
  @html << "<div class='scene'>"
    @html << "<h3>"
      @html << "Act #{act.attr('n')}, Scene #{scene.attr('n')}"
    @html << "</h3>"
  @html << "</div>"
  scene.children.each do |child|
    if child.name == 'text'
      process_text(child)
    elsif child.name == 'sp'
      process_speech(child)
    elsif child.name == 'stage'
      process_stage_direction(child)
    else
      # puts child.name
    end
  end
end

def build_speech
end

def build_stage_direction
end

def create_html
  date = Time.now.strftime("%d/%m/%y")
  editors = @file.search("//titleStmt//editor").map(&:text).join(", ")
  title = @file.xpath("//titleStmt//title").text
  @html = ''
  @html << "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\" \"http://www.w3.org/TR/REC-html40/loose.dtd\">"
    @html << "<head>"
      @html << "<title>"
        @html << "#{title}, modified #{date}"
      @html << "</title>"
      @html << "<link rel=\"stylesheet\" href=\"script-style.css\">"
      @html << "<link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css\">"
      @html << "<script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js\"></script>"
      @html << "<script src=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js\"></script>"
    @html << "</head>"
    @html << "<body>"
      @html << "<h1>"
        @html << "#{title}"
      @html << "</h1>"
      @html << "<h4>"
        @html << "<em>"
          @html << "Modified from the Folger Digital Texts, edited by #{editors}"
        @html << "</em>"
      @html << "</h4>"
      @html << "<div class='dramatis_personae'>"
        @html << "<h2>"
          @html << "People in the Play"
        @html << "</h2>"
        @html << "<ul class=\"characters-list\">"
          list_people
        @html << "</ul>"
      @html << "</div>"
      @html << "<div>"
        build_play
      @html << "</div>"
    @html << "</body>"
  @html << "</html>"
  html_file = File.new('data/html_output.html', 'w')
  html_file.write(@html)
end

def list_people
  people = @file.xpath("//person")
  people.each do |person|
    name = person.xpath('persName').text.strip
    if !name.empty?
      @html << "<li class='character'>"
        @html << name
      @html << "</li>"
    end
  end
  groups_of_people = @file.xpath("//personGrp")
  groups_of_people.each do |group|
    group_name = group.text.strip
    if !group_name.empty?
      @html << "<li class='character'>"
        @html << group_name
      @html << "</li>"
    end
  end
end

def map_ids_to_words_and_characters(id)

end

def process_speech(element)
  puts "processing speech"
  speaker_name = element.xpath("speaker").text
  speaker_name.strip!
  element.xpath('//milestone').each do |milestone|
    if milestone.attr('unit') == 'ftln'
      milestone_line = []
      line_pieces = milestone.attr('corresp').split(/ /)
      line_pieces.each do |id|
        id.sub!(/#/, '')
        milestone_line << @dictionary[id].text
      end
      completed_line = milestone_line.join('')
      if @current_speaker == speaker_name || @current_speaker.empty?
        @html << "#{completed_line}"
        @current_speaker = speaker_name
      else
        @current_speaker = speaker_name
        @html << "#{speaker_name}: #{completed_line}"
      end
    end
  end
end
def process_text(element)
end
def process_stage_direction(element)
end
def read_xml(xml_document)
  @file = xml_document
end
