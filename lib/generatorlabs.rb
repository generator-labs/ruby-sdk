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
require_relative 'generatorlabs/client'
require_relative 'generatorlabs/request_handler'
require_relative 'generatorlabs/rbl'
require_relative 'generatorlabs/contact'

# Generator Labs API SDK
module GeneratorLabs
  class Error < StandardError; end
end
