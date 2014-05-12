require 'spec_helper'

describe "API Response Codes" do

  before :all do
    module Entities
      module Some
        class Thing < Grape::Entity
          expose :text, :documentation => { :type => "string", :desc => "Content of thing." }
        end
      end

      module Some
        class Other < Grape::Entity
          expose :text, :documentation => { :type => "string", :desc => "Content of other." }
        end
        class ErrorMessage < Grape::Entity
          expose :text, :documentation => { :type => "string", :desc => "Content of error." }
        end
      end

    end



    class ModelsApi < Grape::API
      format :json

      desc 'This gets thing.', {
          http_codes: { 200 =>  { :model => Entities::Some::Thing, :message => "Thing details" },
                        400 => "Error" },
          entity: Entities::Some::Thing
      }
      get "/thing" do
        thing = OpenStruct.new text: 'thing'
        present thing, with: Entities::Some::Thing
      end

      desc 'This gets other thing.', {
          http_codes: { 200 =>  { :model => Entities::Some::Other, :message => "Other details" },
                        400 => "Error" }
      }
      get "/other" do
        thing = OpenStruct.new( text: 'other' )
        present thing, with: Entities::Some::Other
      end

      add_swagger_documentation
    end
  end

  def app; ModelsApi; end

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
