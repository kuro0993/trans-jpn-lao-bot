# frozen_string_literal: true

require 'google/cloud/translate'

# Translation Class
class Translation
  def initialize
    @client = Google::Cloud::Translate::V2.new project: 'projects/trans-jpn-lao-bot'
  end

  def detect_language(text)
    detection = @client.detect text
    detection.language
  end

  def translate(text, from: nil, to: 'lo')
    translation = @client.translate text, from:, to:, model: 'nmt'
    translation.text
  end
end
