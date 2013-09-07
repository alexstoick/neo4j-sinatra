require 'sinatra'
require 'sinatra/json'
require 'multi_json'
require 'json'
require 'neography'

class Subscribers < Sinatra::Base

	use Rack::Deflater

	def get_conn ( )

		if ( @conn.nil? )
			Neography.configure do |config|
			  config.protocol       = "http://"
			  config.server         = "37.139.8.146"
			  config.port           = 7474
			  config.directory      = ""  # prefix this path with '/'
			  config.cypher_path    = "/cypher"
			  config.gremlin_path   = "/ext/GremlinPlugin/graphdb/execute_script"
			  config.log_file       = "@neography.log"
			  config.log_enabled    = false
			  config.max_threads    = 20
			  config.authentication = nil  # 'basic' or 'digest'
			  config.username       = nil
			  config.password       = nil
			  config.parser         = MultiJsonParser
			end

			@conn = Neography::Rest.new()
			return @conn
		else
			return @conn
		end
	end

	def get_feed ( id , conn )

		feed = Neography::Node.find( "feed" , "id" , id )

		if ( feed.nil? )
			puts "Feed does not exist"

			feed = Neography::Node.create( "feed_id" => id )
			conn.add_node_to_index( "feed" , "id" , id , feed )
			conn.add_label( feed , "feed" )

			puts "Created feed with id " + feed.neo_id

			return feed
		else
			puts "Feed exists with id " + feed.neo_id
			return feed
		end

	end


	get '/subscribers/:feedid' do

		content_type :json
		feed = params[:feedid]


		conn = get_conn()
		users = Array.new()
		feed = get_feed( feed , conn )

		feed.rels.outgoing.map do |node|
			users.push(node.end_node.user_id.to_i)
			#puts node.end_node.user_id
		end
		{ :id => params[:feedid] , :subscribers => users.length , :users => users }.to_json

	end
end