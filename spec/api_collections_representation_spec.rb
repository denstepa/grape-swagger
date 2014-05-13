require 'spec_helper'

describe "API Collection Representation" do

  before :all do
    module Entities
      module Collection
        class Thing < Grape::Entity
          expose :text, :documentation => { :type => "string", :desc => "Content of thing." }
        end

        class Collection < Grape::Entity
          expose :data,
                 documentation: proc { |container, options| { type: "Array[#{options[:data_using]}]", desc: "Collection of #{options[:data_using]}"} } do |container, options|
            options[:data_using].represent container.data
          end
        end
      end
    end



    class ModelsApiCollection < Grape::API
      format :json

      desc 'This gets thing.', {
        collection: { :entity => Entities::Collection::Collection, :data_using => Entities::Collection::Thing}
      }
      get "/things" do
        thing = [OpenStruct.new(text: 'thing1'), OpenStruct.new(text: 'thing2')]
        present thing, with: Entities::Collection::Collection
      end

      desc 'This gets thing.', {
        http_codes: { 200 =>  { :model => Entities::Collection::Collection, :message => "Thing details" },
                      400 => "Error" }
      }
      get "/things2" do
        thing = [OpenStruct.new(text: 'thing1'), OpenStruct.new(text: 'thing2')]
        present thing, with: Entities::Collection::Collection
      end

      desc 'This gets thing collection.', {
          http_codes: { 200 => { collection: { :entity => Entities::Collection::Collection,
                                              :data_using => Entities::Collection::Thing},
                                 message: "Thing details"},
                        400 => "Error" }
      }
      get "/things3" do
        thing = [OpenStruct.new(text: 'thing1'), OpenStruct.new(text: 'thing2')]
        present thing, with: Entities::Collection::Collection
      end

      add_swagger_documentation
    end
  end

  def app; ModelsApiCollection; end

  it "should represent collection of objects" do
    get '/swagger_doc/things.json'
    JSON.parse(last_response.body)['models'].should == {
        "Collection" => {
            "id" => "Collection",
            "name" => "Collection",
            "properties" => {
                "data" => {
                    "type" => "Array[Thing]",
                    "description" => "Collection of Thing"
                }
            }
        },
        "Thing" => {
            "id" => "Thing",
            "name" => "Thing",
            "properties" => {
                "text" => {
                    "type" => "string",
                    "description" => "Content of thing."
                }
            }
        }
    }
    JSON.parse(last_response.body)['apis'].should ==
        [{
             "path" => "/things.{format}",
             "operations" => [{
                "produces" => [
                    "application/json"
                ],
                "notes" => "",
                "type" => "Collection",
                "summary" => "This gets thing.",
                "nickname" => "GET-things---format-",
                "httpMethod" => "GET",
                "parameters" => []
            }]
         }]

  end

  it "should include collection from response codes" do
    get '/swagger_doc/things3.json'
    JSON.parse(last_response.body).should == {
        "apiVersion" => "0.1",
        "swaggerVersion" => "1.2",
        "basePath" => "http://example.org",
        "resourcePath" => "",
        "apis" => [{
                       "path" => "/things3.{format}",
                       "operations" => [{
                                            "produces" => [
                                                "application/json"
                                            ],
                                            "notes" => "",
                                            "type" => "Collection",
                                            "summary" => "This gets thing collection.",
                                            "nickname" => "GET-things3---format-",
                                            "httpMethod" => "GET",
                                            "parameters" => [],
                                            "responseMessages" => [
                                                {
                                                    "code" => 200,
                                                    "message" => "Thing details",
                                                    "responseModel" => "Collection"

                                                },
                                                {
                                                    "code" => 400,
                                                    "message" => "Error"
                                                }
                                            ]
                                        }]
                   }],
        "models" => {
            "Collection" => {
                "id" => "Collection",
                "name" => "Collection",
                "properties" => {
                    "data" => {
                        "type" => "Array[Thing]",
                        "description" => "Collection of Thing"
                    }
                }
            },
            "Thing" => {
                "id" => "Thing",
                "name" => "Thing",
                "properties" => {
                    "text" => {
                        "type" => "string",
                        "description" => "Content of thing."
                    }
                }
            }
        }
    }
  end
end
