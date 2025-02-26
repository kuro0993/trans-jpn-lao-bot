# frozen_string_literal: true

require 'functions_framework'
require 'line/bot'
require 'sinatra'
require 'dotenv'
require 'pry-byebug'

require './translation.rb'
require './reply_message.rb'

Dotenv.load

$first_language = 'ja'
$second_language = 'th'
# $second_language = 'lo'

# App Class
class App < Sinatra::Base
  use Rack::ShowStatus

  get '/' do
    'Hello World!'
  end

  post '/line-callback' do
    # binding.pry
    action = ReplyMessage.new(request)
    unless action.validate_signature?
      error 400 do
        'Bad Request'
      end
    end
    action.call
  end

  # for test
  get '/translate' do
    text = params['text']
    translation = Translation.new
    translated_text = translation.translate(text, from: source_language(text), to: destination_language(text))
    re_translated_text = translation.trans(translated_text, from: destination_language(text), to: source_language(text))
    "#{translated_text} | #{re_translated_text}"
  end

  private

  def source_language(text)
    translation = Translation.new
    @source_language ||= translation.detect_language(text)
  end

  def destination_language(text)
    source_language(text) == $first_language ? $second_language : $first_language
  end
end

FunctionsFramework.http('translate') do |request|
  App.call request.env
end
