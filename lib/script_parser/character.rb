class Character
	attr_accessor(:name, :line_count, :id)
	@@characters = []
    @@character_id = 0
	def initialize(name)
		@name = name.upcase
		@line_count = 0
		@@character_id += 1
		@id = @@character_id
		@@characters << self
		
	end

	def increment_line_count
		self.line_count += 1
	end

	def self.all_instances
		@@characters
	end

end
