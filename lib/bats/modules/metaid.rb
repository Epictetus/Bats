# Sorry _why I don't feel like extending Ruby's Object class.
module Metaid
	def metaclass; class << self; self; end; end
	
	def meta_eval &b
		metaclass.instance_eval &b
	end
	
	def meta_def( n, &b )
		meta_eval { define_method( n, &b ) }
	end
	
	def class_def( n, &b )
		class_eval { define_method( n, &b ) }
	end
end