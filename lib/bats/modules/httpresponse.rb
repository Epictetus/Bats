require 'bats/modules/classbaker'

module HTTPResponse
	extend ClassBaker
	
	class Response
		extend ::Wizarding
		
		traits :status, :headers, :body
		
		def self.headers h
			@traits[ :headers ] ||= {}
			@traits[ :headers ].merge!( h )
		end
		
		def self.body b
			headers { 'Content-Length' => b.length }
			@traits[ :body ] = b
		end

		def self.call env; new.call( env ); end

		def call env
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