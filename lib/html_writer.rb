require_relative 'script_parser/character'
require_relative 'script_parser/line'
require 'nokogiri'


def build_act(act)
  @html << "<div class='act'>"
    @html << "<h2>"
      @html << "Act #{act.attr('n')}"
    @html << "</h2>"
  @html << "</div>"
  act.xpath("//div2").each do |scene|
    build_scene(act, scene)
  end
end

def build_line
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
    puts child.name
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


def read_xml(xml_document)
  @file = xml_document
end
