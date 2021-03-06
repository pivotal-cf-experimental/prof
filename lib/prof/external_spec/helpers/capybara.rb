# Copyright (c) 2014-2015 Pivotal Software, Inc.
# All rights reserved.
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
# PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
# USE OR OTHER DEALINGS IN THE SOFTWARE.
#

require 'capybara/poltergeist'
require 'capybara/webkit'

module Prof
  module ExternalSpec
    module Helpers
      module Capybara
        def setup_browser(driver = :poltergeist)
          unless %i{poltergeist webkit}.include?(driver)
            raise StandardError.new("invalid driver")
          end

          ::Capybara.default_max_wait_time = 60
          ::Capybara.default_driver    = driver
          ::Capybara.javascript_driver = driver


          ::Capybara.register_driver :poltergeist do |app|
            ::Capybara::Poltergeist::Driver.new(
              app,
              debug:             ENV.key?('DEBUG'),
              timeout:           240,
              js_errors:         false,
              phantomjs_logger:  null_io_object,
              phantomjs_options: ['--ignore-ssl-errors=yes'],
              window_size:       [1300, 1000]
            )
          end

          ::Capybara::Webkit.configure do |config|
            config.block_unknown_urls
            config.ignore_ssl_errors
          end
        end

        def null_io_object
          f            = File.open('/dev/null')
          io           = IO.for_fd(f.fileno)
          io.autoclose = true
          io
        end
      end
    end
  end
end
