# Copyright (c) 2014-2015 Pivotal Software, Inc.
# All rights reserved.
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
# PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
# USE OR OTHER DEALINGS IN THE SOFTWARE.
#

require 'spec_helper'
require 'prof/external_spec/helpers/capybara'
require 'prof/ops_manager/web_app_internals/page/checkbox_field'

RSpec.configure do |config|
  config.include Prof::ExternalSpec::Helpers::Capybara
end

module Prof
  class OpsManager
    class WebAppInternals
      module Page
        describe FormField do
           let(:form) do
            <<-HTML
            <html>
            <body>
              <form>
                <input type="checkbox" name="rabbitmq-broker[plugins][]" value="mqtt"/>
                <input type="checkbox" name="rabbitmq-broker[plugins][]" value="stomp" checked="checked" />
              </form>
              </body>
              </html>
            HTML
          end
          let(:session) { Capybara::Session.new(:poltergeist, app) }
          let(:app) do
            proc do |env|
              [200, {"Content-Type" => "text/html"}, [form]]
            end
          end

          before { session.visit('/') }

          describe "#set" do
            context "when the checkbox is unchecked" do
              it "can check the checkbox" do
                subject = CheckboxField.new(name: "rabbitmq-broker[plugins][]", value: "mqtt", checked: true)

                expect {
                  subject.set(session)
                }.to change {
                  session.find('[name$="rabbitmq-broker[plugins][]"][value$="mqtt"]').checked?
                }.from(false).to(true)
              end

              it "can leave the checkbox untouched" do
                subject = CheckboxField.new(name: "rabbitmq-broker[plugins][]", value: "mqtt", checked: false)

                expect {
                  subject.set(session)
                }.to_not change {
                  session.find('[name$="rabbitmq-broker[plugins][]"][value$="mqtt"]').checked?
                }
              end
            end

            context "when the checkbox is checked" do
              it "can uncheck the checkbox" do
                subject = CheckboxField.new(name: "rabbitmq-broker[plugins][]", value: "stomp", checked: false)

                expect {
                  subject.set(session)
                }.to change {
                  session.find('[name$="rabbitmq-broker[plugins][]"][value$="stomp"]').checked?
                }.from(true).to(false)
              end

              it "can leave the checkbox untouched" do
                subject = CheckboxField.new(name: "rabbitmq-broker[plugins][]", value: "stomp", checked: true)

                expect {
                  subject.set(session)
                }.to_not change {
                  session.find('[name$="rabbitmq-broker[plugins][]"][value$="stomp"]').checked?
                }
              end
            end

            context "when the field cannot be found" do
              let(:form) do
                <<-HTML
                <html><body><form></form></body></html>
                HTML
              end

              it "raises an error" do
              subject = CheckboxField.new(name: "rabbitmq-broker[plugins][]", value: "mqtt", checked: true)

                expect {
                  subject.set(session)
                }.to raise_error(/Could not find element with name rabbitmq-broker\[plugins\]\[\] and selector/)
              end
            end
          end

        end
      end
    end
  end
end

