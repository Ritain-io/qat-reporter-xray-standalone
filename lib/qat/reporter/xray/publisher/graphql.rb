require_relative 'base'
require "graphql/client"
require "graphql/client/http"

module QAT
	module Reporter
		class Xray
			module Publisher
				
				module Graphql
					# Configure GraphQL endpoint using the basic HTTP network adapter.
					HTTP = GraphQL::Client::HTTP.new(@url) do
						def headers(context)
							@headers
						end
					end
					
					# Fetch latest schema on init, this will make a network request
					GraphQL::Client.dump_schema(Graph::HTTP, "schema.json")
					Schema = GraphQL::Client.load_schema('schema.json')
					
					# However, it's smart to dump this to a JSON file and load from disk
					#
					# Run it from a script or rake task
					#   GraphQL::Client.dump_schema(SWAPI::HTTP, "path/to/schema.json")
					#
					# Schema = GraphQL::Client.load_schema("path/to/schema.json")
					
					Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
					
					TestExecution = Graph::Client.parse <<-GRAPHQL
		{
			getTestExecution(issueId: "#{@issue}") {
					issueId
					tests(limit: 100) {
							total
							start
							limit
							results {
									issueId
									testType {
											name
									}
							}
					}
			}
		}
					GRAPHQL
					
					def self.get_test_execution(issue, headers, url)
						@issue, @headers, @url = issue, headers, url
						Graph::Client.query(TestExecution)
					end
				end
			end
		end
	end
end