%w( metaid wizarding ).each { | f | require "bats/modules/#{f}" }

module ClassBaker
	include Metaid
	
	def makeClass n, c = nil
		c = ( c.nil? ) ? Class.new : c
		c = ( c.is_a?( String ) ) ? Class.new( const_get( c ) ) : c
		const_set n, c
		c
	end
	
	def bakeClass h
		h.each do | c, o |
			t = o.include?( :inherit ) ? o[ :inherit ] : nil
			o.delete( :inherit )
			i = makeClass( c, t )
			i.extend( Wizarding )
			unless o.empty? then
				i.traits *o.keys
				o.each { | k, v | i.send( k, v ) }
			end
		end
	end

end