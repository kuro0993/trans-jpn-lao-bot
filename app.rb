# frozen_string_literal: true

require 'functions_framework'

FunctionsFramework.http('hello') do |request|
  "hello world!\n"
end
