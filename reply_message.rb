# frozen_string_literal: true

require 'line/bot'
require 'romaji'
require 'romaji/core_ext/string'

# ReplayMessage
class ReplyMessage
  attr_accessor :line_client, :request, :body
  private :line_client, :request, :body

  def initialize(request)
    @request = request
    @body = request.body.read

    @line_client = Line::Bot::Client.new do |config|
      config.channel_id = ENV['LINE_CHANNEL_ID']
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
  end

  def validate_signature?
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    line_client.validate_signature(body, signature)
  end

  def call
    events = line_client.parse_events_from(body)
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          text = event.message['text']
          sender_profile = @line_client.get_profile(event['source']['userId']) # source は取得できない可能性がある
          p sender_profile
          sender = if !sender_profile.nil?
                     parsed = JSON.parse(sender_profile.read_body)
                     p parsed
                     display_name = parsed['displayName']
                     "#{display_name} / #{display_name.romaji}"
                   else
                     '(Permission Error)'
                   end
          translation = Translation.new
          detect_lang_code = translation.detect_language(text)
          target_lang_code = detect_lang_code == $first_language ? $second_language : $first_language
          translated_text = translation.trans(text, target_lang_code)
          re_translated_text = translation.trans(translated_text, detect_lang_code)
          message = {
            type: 'flex',
            altText: text,
            contents: {
              type: 'bubble',
              body: {
                type: 'box',
                layout: 'vertical',
                contents: [
                  {
                    type: 'box',
                    layout: 'vertical',
                    contents: [
                      {
                        type: 'text',
                        text: 'hello, world',
                        contents: [
                          {
                            type: 'span',
                            text: 'Sender ',
                            size: 'xxs'
                          },
                          {
                            type: 'span',
                            text: sender,
                            size: 'xs',
                            style: 'normal',
                            decoration: 'none'
                          }
                        ],
                        color: '#1DB446'
                      },
                      {
                        type: 'text',
                        text: translated_text,
                        wrap: true
                      }
                    ]
                  },
                  {
                    type: 'separator',
                    margin: '10px'
                  },
                  {
                    type: 'box',
                    layout: 'vertical',
                    contents: [
                      {
                        type: 'text',
                        text: 'Re translate',
                        margin: 'lg',
                        size: 'xxs',
                        color: '#aaaaaa'
                      },
                      {
                        type: 'text',
                        text: re_translated_text,
                        wrap: true,
                        size: 'xs',
                        color: '#aaaaaa'
                      }
                    ]
                  }
                ]
              },
              styles: {
                footer: {
                  separator: true
                }
              }
            }
          }
          @line_client.reply_message(event['replyToken'], message)
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
          # response = @line_client.get_message_content(event.message['id'])
          # tf = Tempfile.open('content')
          # tf.write(response.body)
        end
      end
    end
    'OK'
  end
end
