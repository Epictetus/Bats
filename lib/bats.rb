%w( httpresponse wizarding ).each do |f|
	require 'bats/modules/httpresponse'
end

class Bats
	extend Wizarding

	traits :routes
	
	def self.inherited c
		c.traits *traits.keys
	end

	def self.addRoute m, p, o = nil, &b
		@traits[ :routes ] ||= {}
		@traits[ :routes ][ m ] ||= {}
		@traits[ :routes ][ m ][ p ] = ( block_given? ) ? b : o
	end

	def self.get p, o = nil, &b; addRoute( :get, p, o, &b ); end
	def self.post p, o = nil, &b; addRoute( :post, p, o, &b ); end
	def self.put p, o = nil, &b; addRoute( :put, p, o, &b ); end
	def self.delete p, o = nil, &b; addRoute( :delete, p, o, &b ); end
	
	def self.redirect l, isTemporary = true
		i = ( isTemporary ) ? '307' : '301'
		statusCode( i ).headers( :Location => l )
	end

	def self.statusCode i; ::HTTPResponse.const_get( "Status#{i}" ); end
	def statusCode i; ::HTTPResponse.const_get( "Status#{i}" ); end

	def self.call env; new.call( env ); end
	def call env
		method = env[ 'REQUEST_METHOD' ].downcase.to_sym
		path = env[ 'PATH_INFO' ]
		matches ||= nil
		if @routes && @routes[method] then
			if @routes[method].include?( path ) then
				route = @routes[method][ path ]
			else
				@routes[method].each do | p, b |
					if p.kind_of?( Regexp ) then
						if matches = path.match( p ) then
							matches = matches[ 1, matches.length - 1 ]
							matches.map! do | i | 
								i = ( i ) ? i : ''
								i = i.to_i if i =~ /^\d+$/
								i
							end
							route = b
							break # Eh! give me a break here!
						end
					end
				end
			end
		end
		route ||= statusCode( 404 )
		args = ( matches ) ? [ env, *matches ] : [ env ]
		begin
			route = route.call( args ) if route.kind_of?( Proc )
			route.call( env )
		rescue
			b = '<h1>Ooops... The code broke.</h1>'
			b += "<h3>#{$!.to_s}</h3>#{$!.backtrace.join( '<br/>' )}"
			route = statusCode(500).body b
			route.call( env )
		end
	end
end
