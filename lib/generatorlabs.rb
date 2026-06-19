# frozen_string_literal: true

#
# This file is part of the Generator Labs Ruby SDK package.
#
# (c) Generator Labs <support@generatorlabs.com>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

require_relative 'generatorlabs/version'
require_relative 'generatorlabs/config'
require_relative 'generatorlabs/rate_limit_info'
require_relative 'generatorlabs/response'
require_relative 'generatorlabs/client'
require_relative 'generatorlabs/request_handler'
require_relative 'generatorlabs/webhook'
require_relative 'generatorlabs/rbl'
require_relative 'generatorlabs/contact'
require_relative 'generatorlabs/cert'

# Generator Labs API SDK
module GeneratorLabs
  class Error < StandardError
    attr_reader :status_code

    def initialize(message = nil, status_code: nil)
      super(message)
      @status_code = status_code
    end
  end
end
