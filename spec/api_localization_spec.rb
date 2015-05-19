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
          expose :text, :documentation => { :type => "string", :desc => 'thing desc' }
        end
        class ThingRu < Grape::Entity
          expose :text, :documentation => { :type => "string", :desc_t => 'entity.thing' }
        end
      end
    end

    class ModelsApiLocalization < Grape::API
      format :json

      desc_t 'desc.something'
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
    json = JSON.parse(last_response.body)
    expect(json['apis'].first['operations'].first['summary']).to eq "Desc of smth"
  end

  it "i18n method description specified language" do
    get '/swagger_doc/something.json?locale=ru'
    json = JSON.parse(last_response.body)
    expect(json['apis'].first['operations'].first['summary']).to eq "Russian of smth"
  end

  it "i18n entity localization" do
    get '/swagger_doc/thing.json'
    expect(JSON.parse(last_response.body)['models']).to match({
          "Localization::Thing" => {
            "id" => "Localization::Thing",
            "properties" => {
              "text" => {
                "type" => "string",
                "description" => "thing desc"
              }
            }
          }
        })
  end

  it "i18n entity localization" do
    @options = {}
    get '/swagger_doc/thing_t.json?locale=ru'
    expect(JSON.parse(last_response.body)['models']).to match({
          "Localization::ThingRu" => {
            "id" => "Localization::ThingRu",
            "properties" => {
              "text" => {
                "type" => "string",
                "description" => "Russian thing"
              }
            }
          }
        })
  end
end
