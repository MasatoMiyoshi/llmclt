# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'
require 'googleauth'

require_relative 'llmclt/config'
require_relative 'llmclt/config/safety_config'
require_relative 'llmclt/config/generation_config'
require_relative 'llmclt/client'
require_relative 'llmclt/request'
require_relative 'llmclt/http/connection'
require_relative 'llmclt/http/connection_pool'
require_relative 'llmclt/response'
require_relative 'llmclt/version'

module Llmclt
  class Error < StandardError; end
  # Your code goes here...
end
