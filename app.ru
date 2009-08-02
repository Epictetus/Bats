# Include all of our helper functions for various libraries
Dir[ 'helpers/*.rb' ].each { | f | require f }

require 'markaby'

class Rapp::Router
	# create a loop route for each REST method
	%w( get post put delete ).each do | m |
		# create our block
		b = lambda do
			b = Markaby::Template.new(
				File.open( 'views/restform.mab' ).read
			).render( :m => m )
		end
		send( m.to_s, %r{^/loop$}, &b )
	end
	
	get '/', redirect( '/loop' )
end


# include some rack middleware
# use Rack::ShowExceptions
use Rack::MethodOverride

# Run the app!
run Rapp