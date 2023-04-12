require_relative 'base'
require 'zip'

module QAT
	module Reporter
		class Xray
			module Publisher
				# QAT::Reporter::Xray::Publisher::Cloud integrator class
				class Cloud < Base
					
					def get_jira_issue(issue_key)
						headers = { 'Content-Type': 'application/json' }.merge(auth_headers)
						Client.new(base_url).get("/rest/api/3/issue/#{issue_key}", headers)
					end
					
					def get_jira_linked_issue(linked_issue_id)
						headers = { 'Content-Type': 'application/json' }.merge(auth_headers)
						Client.new(base_url).get("/rest/api/3/issueLink/#{linked_issue_id}", headers)
					end
					
					def get_project(project_key)
						headers = { 'Content-Type': 'application/json' }.merge(auth_headers)
						Client.new(base_url).get("/rest/api/3/project/#{project_key}", headers)
					end
					
					# Get workflow transitions of an issue
					def get_transitions(issue_key)
						headers = { 'Content-Type': 'application/json', 'Accept': "application/json" }.merge(auth_headers)
						Client.new(base_url).get("/rest/api/2/issue/#{issue_key}/transitions", headers)
					end
					
					# Change transition issue
					def transitions_issue(issue_key, payload)
						headers = { 'Content-Type': 'application/json', 'Accept': "application/json" }.merge(auth_headers)
						Client.new(base_url).post("/rest/api/2/issue/#{issue_key}/transitions", payload, headers)
					end
					
					# Posts the execution json results in Xray
					def send_execution_results(results)
						headers = { 'Content-Type': 'application/json' }.merge(auth_token)
						Client.new(default_cloud_api_url).post('/api/v1/import/execution', results.to_json, headers)
					end
					
					# Get the Authorization Token based on client_id & client_secret (ONLY FOR CLOUD XRAY)
					def auth_token
						return @auth_token if @auth_token
						
						client_id         = cloud_xray_api_credentials[0]
						client_secret     = cloud_xray_api_credentials[1]
						auth_header_cloud = {
							client_id:     client_id,
							client_secret: client_secret
						}
						
						response    = Client.new(default_cloud_api_url).post('/api/v1/authenticate', auth_header_cloud).body
						bearer      = JSON.parse(response)
						@auth_token = {
							Authorization: "Bearer #{bearer}"
						}
					end
					
					def import_cucumber_behave_tests(info, results)
						headers = { 'Content-Type': 'multipart/form-data' }.merge(auth_token)
						payload = {
							info:    File.new(info, 'rb'),
							results: File.new(results, 'rb')
						}
						
						Client.new(default_cloud_api_url).post('/api/v2/import/execution/behave/multipart', payload, headers)
					end
					
					# Import Cucumber features files as a zip file via API
					# @param project_key [String] JIRA's project key
					# @param file_path [String]  Cucumber features files' zip file
					# @see https://confluence.xpand-it.com/display/XRAYCLOUD/Importing+Cucumber+Tests+-+REST
					def import_cucumber_tests(project_key, file_path, project_id = nil)
						headers = auth_token.merge({
																				 multipart: true,
																				 params:    {
																					 projectKey: project_key,
																					 projectId:  project_id,
																					 source:     project_key
																				 }
																			 })
						payload = { file: File.new(file_path, 'rb') }
						
						Client.new(default_cloud_api_url).post('/api/v1/import/feature', payload, headers)
					end
					
					# Export Xray test scenarios to a zip file via API
					# @param keys [String] test scenarios
					# @param filter [String] project filter
					# @see https://confluence.xpand-it.com/display/XRAYCLOUD/Exporting+Cucumber+Tests+-+REST
					def export_test_scenarios(keys, filter = nil)
						params          = {
							keys: keys,
						}
						params[:filter] = filter if filter.present?
						
						headers = auth_token.merge(params: params)
						
						puts "Exporting features from: #{default_cloud_api_url}/api/v1/export/cucumber"
						all_tests = RestClient.get("#{default_cloud_api_url}/api/v1/export/cucumber", headers)
						raise(NoTestsFoundError, "No Tests found for keys: #{keys}") if all_tests.code != 200
						all_test_keys = all_tests.body.to_s.scan(/(@TEST_\w+-\d+)/).flatten
						(0...all_test_keys.count).to_a.map do |index|
							{ test_issue_key: all_test_keys[index].gsub('@TEST_', '') }
						end
					end
				end
				
				# Error returned when no tests are found
				class NoTestsFoundError < StandardError
				end
			end
		end
	end
end