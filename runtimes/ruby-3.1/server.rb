require 'sinatra'
require 'json'

DEFAULT_PATH = '/usr/code-start';
DEFAULT_FILE = 'index.rb';

before do
  content_type :json
end

class RuntimeRequest
  def initialize(payload = '{}', env = {}, headers = {})
    if payload == nil
      payload = '{}'
    end

    if headers == nil
      headers = {}
    end

    if env == nil
      env = {}
    end

    @payload = payload
    @env = env
    @headers = headers
  end

  def payload
    @payload
  end

  def env
    @env
  end

  def headers
    @headers
  end
end

class RuntimeResponse
  def send(message)
    @response = message
  end

  def json(object)
    @response = object.to_json
  end
end

post '/' do
  challenge = request.env['HTTP_X_INTERNAL_CHALLENGE'] || ''

  if challenge == ''
    status 401
    content_type :json
    return { code: 401, message: 'Unauthorized' }.to_json
  end

  if challenge != ENV['INTERNAL_RUNTIME_KEY']
    status 401
    content_type :json
    return { code: 401, message: 'Unauthorized' }.to_json
  end

  request.body.rewind
  data = JSON.parse(request.body.read)

  requestFile = data['file'] || DEFAULT_FILE
  requestPath = data['path'] || DEFAULT_PATH

  if requestPath.nil? || requestPath == '' || requestFile.nil? || requestFile == ''
    status 400
    content_type :json
    return { code: 500, message: 'Bad Request' }.to_json
  end

  requestData = RuntimeRequest.new(data['payload'], data['env'], data['headers'])
  runtimeResponse = RuntimeResponse.new

  begin
    load(requestPath + '/' + requestFile)
  rescue Exception => e
    p e
    status 500
    content_type :json
    return { code: 500, message: 'File not found or is not a valid ruby file. ' }.to_json
  end

  unless defined?(main = ())
    status 500
    content_type :json
    return { code: 500, message: 'File does not specify a main() function.' }.to_json
  end

  begin
    response = main(requestData, runtimeResponse)
  rescue Exception => e
    p e
    status 500
    content_type :json
    return { code: 500, message: e.backtrace.join("\n") }.to_json
  end

  status 200
  return response
end

error do
  status 500
  content_type :json
  return { code: 500, message: env['sinatra.error'].message }.to_json
end