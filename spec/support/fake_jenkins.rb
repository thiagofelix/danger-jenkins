require 'sinatra/base'

class FakeJenkins < Sinatra::Base
  get '/job/:job/:build_number/api/json' do
    json_response 200, "#{underscore(params['job'])}.json"
  end

  get '/job/:job/:build_number/logText/progressiveHtml' do
    content_type :html
    [200, 'console output']
  end

  private

  def underscore(camel_cased_word)
    camel_cased_word.to_s.gsub(/::/, '/')
                    .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                    .gsub(/([a-z\d])([A-Z])/, '\1_\2')
                    .tr('-', '_')
                    .downcase
  end

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/fixtures/' + file_name, 'rb').read
  end
end
