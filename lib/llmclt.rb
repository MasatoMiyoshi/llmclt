# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'
require 'googleauth'

require_relative 'llmclt/config'
require_relative 'llmclt/config/safety_config'
require_relative 'llmclt/config/generation_config'
require_relative 'llmclt/client'
require_relative 'llmclt/fetcher'
require_relative 'llmclt/syntax/chat'
require_relative 'llmclt/request/base'
require_relative 'llmclt/request/chat'
require_relative 'llmclt/request/non_streaming'
require_relative 'llmclt/request/streaming'
require_relative 'llmclt/http/connection'
require_relative 'llmclt/http/connection_pool'
require_relative 'llmclt/response/base'
require_relative 'llmclt/response/chat'
require_relative 'llmclt/response/non_streaming'
require_relative 'llmclt/response/streaming'
require_relative 'llmclt/version'

module Llmclt
  class Error < StandardError; end
  # Your code goes here...
end
