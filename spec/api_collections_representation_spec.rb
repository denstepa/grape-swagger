require 'spec_helper'

describe "API Collection Representation" do

  before :all do
    module Entities
      class Thing < Grape::Entity
        expose :text, :documentation => { :type => "string", :desc => "Content of thing." }
      end

      class Collection < Grape::Entity
        expose :text, :documentation => { :type => "string", :desc => "Content of Collection." }

        expose :data,
               documentation: proc { |container, options|
                 { type: "#{options[:data_using]}",
                   desc: "Collection of #{options[:data_using]}"} } do |container, options|
          options[:data_using].represent container.data
        end
      end
    end

    class ModelsApiCollection < Grape::API
      format :json

      desc 'This gets thing.', {
        collection: { :entity => Entities::Collection, :data_using => Entities::Thing}
      }
      get "/things" do
        things_col = [OpenStruct.new(text: 'thing1'), OpenStruct.new(text: 'thing2')]
        present things_col, with: Entities::Collection
      end

      desc 'This gets thing.', {
        http_codes: { 200 =>  { :entity => Entities::Collection, :message => "Thing details" },
                      400 => "Error" }
      }
      get "/things2" do
        thing = [OpenStruct.new(text: 'thing1'), OpenStruct.new(text: 'thing2')]
        present thing, with: Entities::Collection
      end


      desc 'This gets thing collection.', {
          http_codes: { 200 => { collection: { :entity => Entities::Collection,
                                              :data_using => Entities::Thing},
                                 message: "Thing details"},
                        400 => "Error" }
      }
      get "/things3" do
        thing = [OpenStruct.new(text: 'thing1'), OpenStruct.new(text: 'thing2')]
        present thing, with: Entities::Collection
      end

      add_swagger_documentation
    end
  end

  def app; ModelsApiCollection; end

  it "should represent collection of objects" do
    get '/swagger_doc/things.json'
    response = JSON.parse(last_response.body)
    expect(response['models']).to eq({
          "Collection" => {
            "id" => "Collection",
            "properties" => {
              "text" => {
                "type" => "string",
                "description" => "Content of Collection."
              },
              "data" => {
                #    "type" => "Thing",
                "description" => "Collection of Thing",
                "$ref" => "Thing"
              }
            }
          },
          "Thing" => {
            "id" => "Thing",
            "properties" => {
              "text" => {
                "type" => "string",
                "description" => "Content of thing."
              }
            }
          }
        })
    expect(response['apis']).to eq(
        [{
            "path" => "/things.{format}",
            "operations" => [{
                "notes" => "",
                "summary" => "This gets thing.",
                "nickname" => "GET-things---format-",
                "method" => "GET",
                "parameters" => [],
                "type" => "void"
              }]
          }])
  end

  it "should include collection from response codes" do
    get '/swagger_doc/things3.json'
    response = JSON.parse(last_response.body)
    expect(response['apis'].first['operations'].first).to match({
          "notes" => "",
          "type" => "void",
          "summary" => "This gets thing collection.",
          "nickname" => "GET-things3---format-",
          "method" => "GET",
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
        })
    expect(response['models']).to match({
            "Collection" => {
              "id" => "Collection",
              "properties" => {
                "data" => {
                  "description" => "Collection of Thing",
                  "$ref" => "Thing"
                },
                "text" => {
                  "type" => "string",
                  "description" => "Content of Collection."
                }
              }
            },
            "Thing" => {
              "id" => "Thing",
              "properties" => {
                "text" => {
                  "type" => "string",
                  "description" => "Content of thing."
                }
              }
            }
          })
  end
end
