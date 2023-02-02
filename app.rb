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

  get '/translate' do
    text = params['text']
    translation = Translation.new
    detect_lang_code = translation.detect_language(text)
    target_lang_code = detect_lang_code == $first_language ? $second_language : $first_language
    translated_text = translation.trans(text, target_lang_code)
    re_translated_text = translation.trans(translated_text, detect_lang_code)
    "#{translated_text} | #{re_translated_text}"
  end
end

FunctionsFramework.http('translate') do |request|
  App.call request.env
end
