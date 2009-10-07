require 'bats/modules/metaid'

module Wizarding
	include Metaid
	
	def traits *a
		return @traits if a.empty?
		attr_accessor *a
		a.each do | m |
			@traits ||= {}
			@traits[m] = nil
			meta_def m do | *v |
				@traits[m] = v[0] unless v.empty?
				( v.empty? ) ? @traits[m] : self
			end
		end
		class_def :initialize do
			self.class.traits.each do | k, v |
				instance_variable_set( "@#{k}", v )
			end
		end
	end

	def inherited c
		c.traits *traits.keys
		c.instance_variable_set( :@traits, traits.dup )
	end
end