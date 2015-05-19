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
    json = JSON.parse(last_response.body)
    expect(json['apis']).to eq([{
        "path" => "/thing.{format}",
        "operations" => [{
                "notes" => "",
                "summary" => "This gets thing.",
                "nickname" => "GET-thing---format-",
                "method" => "GET",
                "parameters" => [],
                "type" => "void",
          "responseMessages" => [
              {
                  "code" => 200,
                  "message" => "Thing details",
                  "responseModel" => "ResponseCodes::Thing"

              },
              {
                  "code" => 400,
                  "message" => "Error"
              }
          ]
        }]
      }])
  end

  it "should add model from responce messages" do
    get '/swagger_doc/other.json'
    json = JSON.parse(last_response.body)
    expect(json['apis']).to match([{
            "path" => "/other.{format}",
            "operations" => [{
                "notes" => "",
                "type" => "void",
                "summary" => "This gets other thing.",
                "nickname" => "GET-other---format-",
                "method" => "GET",
                "parameters" => [],
                "responseMessages" => [
                  {
                    "code" => 200,
                    "message" => "Other details",
                    "responseModel" => "ResponseCodes::Other"
                  },
                  {
                    "code" => 400,
                    "message" => "Error"
                  }
                ]
              }]
          }])

    expect(json['models']).to eq({
        "ResponseCodes::Other" => {
            "id" => "ResponseCodes::Other",
            "properties" => {
                "text" => {
                    "type" => "string",
                    "description" => "Content of other."
                }
            }
        }
    })
  end
end
