require 'magicbag'

# The basis for all of our output classes and middleware
class RackInit
	# Create a new instance and execute that object's call method
	def self.call env
		new.call( env )
	end
end

# 
class Rapp
	extend ::MagicBag::Wizarding
	
	def self.call env
		Router.call( env )
	end
	
	class Output < ::RackInit
		magic
		traits :status, :headers, :body
		
		def self.headers h
			@traits[ :headers ] ||= {}
			@traits[ :headers ].merge!( h )
		end

		# Returns a Rack response
		def call env
			[ @status, @headers, @body.to_s ]
		end
	end
	
	require 'yaml'
	statuses = YAML.load_file( 'helpers/statuses.yaml' )
	statuses.each do | k, v |
		toClass({
			"Status#{k}" => {
				:inherit => 'Output',
				:status => k,
				:headers => v[ 0 ],
				:body => v[ 1 ]
			}
		})
	end
	
	class Router < ::RackInit
		magic
		traits :routes
		routes Hash.new

		def self.addRoute m, p, o = nil, &b
			@traits[ :routes ] ||= {}
			@traits[ :routes ][ m ] ||= {}
			@traits[ :routes ][ m ][ p ] = ( block_given? ) ? b : o
		end

		def self.get p, o = nil, &b; addRoute( :get, p, o, &b ); end
		def self.post p, o = nil, &b; addRoute( :post, p, o, &b ); end
		def self.put p, o = nil, &b; addRoute( :put, p, o, &b ); end
		def self.delete p, o = nil, &b; addRoute( :delete, p, o, &b ); end
		
		def self.redirect l
			Class.new( Status303 ).headers( :location => l )
		end

		def call env
			method = env[ 'REQUEST_METHOD' ].downcase.to_sym
			path = env[ 'PATH_INFO' ]
			if @routes[ method ] then
				if @routes[ method ].include?( path ) then
					route = getRoute( @routes[ method ][ path ] )
				else
					@routes[ method ].each do | p, b |
						if p.kind_of?( Regexp ) then
							if matches = path.match( p ) then
								matches = matches[ 1, matches.length - 1 ]
								matches.map! do | i | 
									i = ( i ) ? i : ''
									i = i.to_i if i =~ /[\d]+/
									i
								end
								route = getRoute( b, *matches )
							end
						end
					end
				end
			else
				route = Status200
			end
			route ||= Status404
			route.call( env )
		end
		
		private
			def getBody t
				lambda do | env |
					Class.new( Status200 ).body( t ).call( env )
				end
			end
			
			def getRoute r, *a
				r = getBody( r.call( *a ) ) if r.kind_of?( Proc )
				r
			end
	end
end