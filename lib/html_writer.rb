require_relative 'script_parser/character'
require_relative 'script_parser/line'
require 'nokogiri'

@current_speaker = ''
def add_value_to_dictionary(value)
  key = value.attr('xml:id')
  @dictionary[key] = value
end

def build_act(act)
  @html << "<div class='act'>"
    @html << "<h2>"
      @html << "Act #{act.attr('n')}"
    @html << "</h2>"
  @html << "</div>"
  act.xpath("div2").each do |scene|
    build_scene(act, scene)
  end
end

def build_dictionary
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

def build_line(milestone, next_milestone = nil)
  milestone_line = []
  line_pieces = milestone.attr('corresp').split(/ /)
  next_line = []
  if next_milestone && next_milestone.attr('rend') == 'turnunder'
    next_line_pieces = next_milestone.attr('corresp').split(/ /)
    next_line_pieces.each do |id|
      id.sub!(/#/, '')
      next_line << @dictionary[id].text
    end
    next_line[0] = " #{next_line[0]}"
  end
  line_pieces.each do |id|
    id.sub!(/#/, '')
    milestone_line << @dictionary[id].text
  end
  completed_line = milestone_line.flatten.join
  completed_line = completed_line + next_line.join
end

def build_play
  @file.xpath("//div1").each do |act|
    build_act(act)
  end
end

def build_scene(act, scene)
  @html << "<div class='scene'>"
    @html << "<h3>"
      @html << "Act #{act.attr('n')}, Scene #{scene.attr('n')}"
    @html << "</h3>"
  @html << "</div>"
  scene.children.each do |child|
    if child.name == 'sp'
      process_speech(child)
    elsif child.name == 'stage'
      process_stage_direction(child)
    else
      
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
      @html << "<div class='container'>"
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
      @html << "</div>" #closing bootstrap container
    @html << "</body>"
  @html << "</html>"
  html_file = File.new('data/html_output.html', 'w')
  html_file.write(@html)
end

def line_cut(milestone)
  classes = []
  if milestone.attr('cut_hs').to_i == 1
    classes << 'cut-hs'
  end
  if milestone.attr('cut_gen').to_i == 1
    classes << 'cut-gen'
  end
  return classes.join(' ')
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

def process_speech(element)
  speaker_name = element.xpath("speaker").text
  speaker_name.strip!
  character_xml_id = element.attr('who').sub(/#/, '')
  element.xpath('ab//milestone').each do |milestone|
    if milestone.attr('unit') == 'ftln'
      next_milestone = element.xpath('ab//milestone')[element.xpath('ab//milestone').index(milestone) + 1]
      completed_line = build_line(milestone, next_milestone)
      if milestone.attr('rend') == 'turnunder'
        next
      end
      if @current_speaker == speaker_name
        @html << "<div class='row line'>"
        @html << "<div class='col-md-2'></div><div class='col-md-10 #{line_cut(milestone)} #{character_xml_id}'>#{completed_line}<br /></div>"
        @html << "</div>"
      else
        @current_speaker = speaker_name
        @html << "<div class='row speech-start line'>" #start row of speech
        @html << "<div class='col-md-2 character-name'>#{speaker_name}:</div><div class='col-md-10 #{line_cut(milestone)} #{character_xml_id}'> #{completed_line}<br /></div>"
        @html << "</div>"
      end
    end
  end
end

def process_stage_direction(element)
  stage_direction_pieces = element.children
  stage_direction = stage_direction_pieces.map(&:text)
  stage_direction = stage_direction.join
  stage_direction.gsub!(/\s+\./, '.')
  stage_direction.gsub!(/\s+\,/, ',')
  @html << "<div class='stage-direction'>#{stage_direction}</div>"

end
def read_xml(xml_document)
  @file = xml_document
end
