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
          receive_text = event.message['text']
          sender_profile = @line_client.get_profile(event['source']['userId']) # source は取得できない可能性がある
          # p sender_profile
          sender = if !sender_profile.nil?
                     parsed = JSON.parse(sender_profile.read_body)
                     # p parsed
                     display_name = parsed['displayName']
                     "#{display_name} / #{display_name.romaji}"
                   else
                     '(Permission Error)'
                   end

          # translation
          translation = Translation.new
          source_language = source_language(receive_text)
          destination_language = destination_language(receive_text)
          translated_text = translation.translate(receive_text, from: source_language, to: destination_language)
          re_translated_text = translation.translate(translated_text, from: destination_language, to: source_language)

          # reply
          message = build_message(receive_text, sender, translated_text, re_translated_text)
          @line_client.reply_message(event['replyToken'], message)
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
          @line_client.reply_message(event['replyToken'], { type: 'text', text: 'Sorry, I can only handle text messages for now.' })
        end
      end
    end
    'OK'
  end

  private

  def source_language(text)
    translation = Translation.new
    @source_language ||= translation.detect_language(text)
  end

  def destination_language(text)
    source_language(text) == $first_language ? $second_language : $first_language
  end

  def build_message(text, sender, translated_text, re_translated_text)
    {
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
  end
end
