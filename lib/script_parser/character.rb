class Character
	attr_accessor(:name, :xml_id, :line_count, :id, :lines)
	@@characters = []
    @@character_id = 0
	def initialize(name:, sex:, xml_id:, state:)
		if name.empty?
			@name = xml_id
		else
			@name = name
		end
		@line_count = 0
		@@character_id += 1
		@id = @@character_id
		@xml_id = xml_id
		@@characters << self
		@lines = ['test','this','is']
	end

	def increment_line_count
		self.line_count += 1
	end

	def self.all_instances
		@@characters
	end
end
