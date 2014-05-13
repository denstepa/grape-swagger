require 'spec_helper'

describe "API Response Codes" do

  before :all do
    module Entities
      module ResponseCodes
        class Thing < Grape::Entity
          expose :text, :documentation => { :type => "string", :desc => "Content of thing." }
        end
        class Other < Grape::Entity
          expose :text, :documentation => { :type => "string", :desc => "Content of other." }
        end
        class ErrorMessage < Grape::Entity
          expose :text, :documentation => { :type => "string", :desc => "Content of error." }
        end
      end
    end

    class ModelsApiResponseCodes < Grape::API
      format :json

      desc 'This gets thing.', {
          http_codes: { 200 =>  { :entity => Entities::ResponseCodes::Thing, :message => "Thing details" },
                        400 => "Error" },
      }
      get "/thing" do
        thing = OpenStruct.new text: 'thing'
        present thing, with: Entities::ResponseCodes::Thing
      end

      desc 'This gets other thing.', {
          http_codes: { 200 =>  { :entity => Entities::ResponseCodes::Other, :message => "Other details" },
                        400 => "Error" }
      }
      get "/other" do
        thing = OpenStruct.new( text: 'other' )
        present thing, with: Entities::ResponseCodes::Other
      end

      add_swagger_documentation
    end
  end

  def app; ModelsApiResponseCodes; end

  it "http codes should allow both with and without model valriants" do
    get '/swagger_doc/thing.json'
    JSON.parse(last_response.body)['apis'].should ==
        [{
        "path" => "/thing.{format}",
        "operations" => [{
          "produces" => [
            "application/json"
          ],
          "notes" => "",
          "type" => "Thing",
          "summary" => "This gets thing.",
          "nickname" => "GET-thing---format-",
          "httpMethod" => "GET",
          "parameters" => [],
          "responseMessages" => [
              {
                  "code" => 200,
                  "message" => "Thing details",
                  "responseModel" => "Thing"

              },
              {
                  "code" => 400,
                  "message" => "Error"
              }
          ]
        }]
      }]
  end

  it "should add model from responce messages" do
    get '/swagger_doc/other.json'
    JSON.parse(last_response.body)['apis'].should ==
        [{
             "path" => "/other.{format}",
             "operations" => [{
                                  "produces" => [
                                      "application/json"
                                  ],
                                  "notes" => "",
                                  "type" => "Other",
                                  "summary" => "This gets other thing.",
                                  "nickname" => "GET-other---format-",
                                  "httpMethod" => "GET",
                                  "parameters" => [],
                                  "responseMessages" => [
                                      {
                                          "code" => 200,
                                          "message" => "Other details",
                                          "responseModel" => "Other"

                                      },
                                      {
                                          "code" => 400,
                                          "message" => "Error"
                                      }
                                  ]
                              }]
         }]

    JSON.parse(last_response.body)['models'].should == {
        "Other" => {
            "id" => "Other",
            "name" => "Other",
            "properties" => {
                "text" => {
                    "type" => "string",
                    "description" => "Content of other."
                }
            }
        }
    }
  end
end
