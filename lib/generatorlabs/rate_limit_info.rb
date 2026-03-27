# frozen_string_literal: true

#
# This file is part of the Generator Labs Ruby SDK package.
#
# (c) Generator Labs <support@generatorlabs.com>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module GeneratorLabs
  # Rate limit information from API response headers.
  class RateLimitInfo
    # @return [String] Active rate limit policies, e.g. "1000;w=3600, 100;w=1"
    attr_reader :limit

    # @return [Integer] Requests remaining in the most restrictive active window
    attr_reader :remaining

    # @return [Integer] Seconds until the most restrictive window resets
    attr_reader :reset

    def initialize(limit:, remaining:, reset:)
      @limit = limit
      @remaining = remaining
      @reset = reset
    end
  end
end
