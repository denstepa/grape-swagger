require 'spec_helper'
require 'i18n'

describe "API Localization" do

  before :all do
    module Entities
      module Localization
        class Something < Grape::Entity
          expose :text, :documentation => { :type => "string", :desc => "Content of something." }
        end
        class Thing < Grape::Entity
          expose :text, :documentation => { :type => "string", :desc => Proc.new{ I18n.t 'entity.thing' } }
        end
        class ThingRu < Grape::Entity
          expose :text, :documentation => { :type => "string", :desc => Proc.new{ I18n.t 'entity.thing' } }
        end
      end
    end

    class ModelsApiLocalization < Grape::API
      format :json

      desc Proc.new{ I18n.t 'desc.something' }
      get '/something' do
        something = OpenStruct.new text: 'something'
        present something, with: Entities::Localization::Something
      end


      desc 'some desc',{
          entity: Entities::Localization::Thing
      }
      get '/thing' do
        something = OpenStruct.new text: 'something'
        present something, with: Entities::Localization::Thing
      end

      desc 'some desc',{
          entity: Entities::Localization::ThingRu
      }
      get '/thing_t' do
        something = OpenStruct.new text: 'something_t'
        present something, with: Entities::Localization::ThingRu
      end

      add_swagger_documentation
    end
  end

  def app; ModelsApiLocalization; end

  it "i18n method description default language" do
    get '/swagger_doc/something.json'
    JSON.parse(last_response.body).should == {
        "apiVersion" => "0.1",
        "swaggerVersion" => "1.2",
        "basePath" => "http://example.org",
        "resourcePath" => "",
        "apis" => [{
                       "path" => "/something.{format}",
                       "operations" => [{
                                            "produces" => [
                                                "application/json"
                                            ],
                                            "notes" => "",
                                            "summary" => "Desc of smth",
                                            "nickname" => "GET-something---format-",
                                            "httpMethod" => "GET",
                                            "parameters" => []
                                        }]
                   }]

    }
  end

  it "i18n method description specified language" do
    get '/swagger_doc/something.json?locale=ru'
    JSON.parse(last_response.body).should == {
        "apiVersion" => "0.1",
        "swaggerVersion" => "1.2",
        "basePath" => "http://example.org",
        "resourcePath" => "",
        "apis" => [{
                       "path" => "/something.{format}",
                       "operations" => [{
                                            "produces" => [
                                                "application/json"
                                            ],
                                            "notes" => "",
                                            "summary" => "Russian of smth",
                                            "nickname" => "GET-something---format-",
                                            "httpMethod" => "GET",
                                            "parameters" => []
                                        }]
                   }]

    }
  end

  it "i18n entity localization" do
    get '/swagger_doc/thing.json'
    JSON.parse(last_response.body)['models'].should == {
        "Thing" => {
            "id" => "Thing",
            "name" => "Thing",
            "properties" => {
                "text" => {
                    "type" => "string",
                    "description" => "thing desc"
                }
            }
        }
    }
  end

  it "i18n entity localization" do
    @options = {}
    get '/swagger_doc/thing_t.json?locale=ru'
    JSON.parse(last_response.body)['models'].should == {
        "ThingRu" => {
            "id" => "ThingRu",
            "name" => "ThingRu",
            "properties" => {
                "text" => {
                    "type" => "string",
                    "description" => "Russian thing"
                }
            }
        }
    }
  end
end
