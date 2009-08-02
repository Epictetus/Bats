class Object
	def self.metaclass; class << self; self; end; end
	
	def self.meta_eval &b
		metaclass.instance_eval &b
	end
	
	def self.meta_def( n, &b )
		meta_eval { define_method( n, &b ) }
	end
	
	def self.class_def( n, &b )
		class_eval { define_method( n, &b ) }
	end
end

class Module
	def magic
		self.extend MagicBag::Wizarding
	end
end

class Class
	def magic
		extend MagicBag::DwemthyPlus
	end
end

module MagicBag
	module DwemthyPlus
		def traits *a
			return @traits if a.empty?
			attr_accessor *a
			a.each do | m |
				@traits ||= {}
				@traits[ m ] = nil
				meta_def m do | v |
					@traits[ m ] = v
					self
				end
			end
			class_def :initialize do
				self.class.traits.each do | k, v |
					instance_variable_set( "@#{k}", v )
				end
			end
		end
	
		def inherited c
			c.traits *@traits.clone.keys
			c.instance_variable_set( :@traits, @traits.clone )
		end
	end

	module Wizarding
		def const_missing *n
			n.join( ' ' )
		end

		def method_missing *n
			n.join( ' ' )
		end
		
		def toClass v
			if v.kind_of?( Hash )
				hashToClass( v )
			elsif v.kind_of?( String )
				yamlToClass( v )
			end
		end

		private
			def makeClass n, c = nil
				i = ( c.nil? ) ? Class.new : Class.new( const_get( c ) )
				const_set n, i
				i
			end
			
			def hashToClass h
				h.each do | c, o |
					t = o.include?( :inherit ) ? o[ :inherit ] : nil
					o.delete( :inherit )
					i = makeClass( c, t )
					i.extend MagicBag::DwemthyPlus
					 			unless o.empty? then
						i.traits *o.keys
						o.each { | k, v | i.send( k, v ) }
					end
				end
			end
			
			def yamlToClass f
				require 'yaml' unless defined? ::YAML
				h = ::YAML.load_file( f )
				hashToClass( h )
			end
	end
end