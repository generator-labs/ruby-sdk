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
  # Account namespace: the account, its balance, its usage and its scheduled checks
  class Account
    def initialize(handler)
      @handler = handler
    end

    # Get the account: its balance, whether its checks are running, and plan usage
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Account data
    def get(options = nil)
      @handler.get('account', nil, options)
    end

    # Get the account balance
    # @param options [RequestOptions, nil] Request options
    # @return [Float] Account balance
    def balance(options = nil)
      Float(@handler.get_plain('account/balance', options))
    end

    # Get the account's usage by month
    # @param params [Hash] Optional parameters (months)
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Usage of each month
    def usage(params = {}, options = nil)
      @handler.get('account/usage', params, options)
    end

    # Pause the account's scheduled checks
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Result
    def pause_checks(options = nil)
      @handler.post('account/checks/pause', nil, options)
    end

    # Resume the account's scheduled checks
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Result
    def resume_checks(options = nil)
      @handler.post('account/checks/resume', nil, options)
    end
  end
end
