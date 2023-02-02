# frozen_string_literal: true

require 'google/cloud/translate'

# Translation Class
class Translation
  def initialize
    @client = Google::Cloud::Translate.translation_service
  end

  def detect_language(text)
    detect = @client.detect_language content: text,
                                     parent: 'projects/trans-jpn-lao-bot'
    detect.languages.first.language_code
  end

  def trans(text, target_lang_code)
    result = @client.translate_text contents: [text],
                                    # mime_type: 'text/plain',
                                    # source_language_code: 'en-US',
                                    target_language_code: target_lang_code,
                                    parent: 'projects/trans-jpn-lao-bot'
    result.translations.first.translated_text
  end
end
