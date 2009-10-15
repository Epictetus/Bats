require 'bats/modules/classbaker'

module HTTPResponse
	extend ClassBaker
	
	class Response
		extend ::Wizarding
		
		traits :body, :headers, :status

		def self.call env; new.call( env ); end
		
		def self.h h
			@traits[:headers].merge!( h )
			self
		end
		
		def self.b b
			@traits[:body] = b
			self
		end

		def call env
			@headers.merge! 'Content-Length' => @body.length.to_s
			[ @status, @headers, @body ]
		end
	end
	
	require 'yaml'
	statuses = YAML.load_file( "#{File.expand_path( '../yaml', File.dirname( __FILE__ ) )}/statuses.yaml" )	# Somewhere in the nether regions beyond column 80!
	statuses.each do | k, v |
		bakeClass(
			"Status#{k}" => {
				:inherit => 'Response',
				:status => k,
				:headers => v[0],
				:body => v[1]
			}
		)
	end

end