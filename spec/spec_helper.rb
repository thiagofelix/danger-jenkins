require 'pathname'
ROOT = Pathname.new(File.expand_path('../../', __FILE__))
$LOAD_PATH.unshift((ROOT + 'lib').to_s)
$LOAD_PATH.unshift((ROOT + 'spec').to_s)

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |f| require f }

require 'bundler/setup'
require 'pry'

require 'rspec'
require 'webmock/rspec'
require 'danger'

# Use coloured output, it's the best.
RSpec.configure do |config|
  config.filter_gems_from_backtrace 'bundler'
  config.color = true
  config.tty = true
  config.before(:each) do
    stub_request(:any, /jenkins.ci/).to_rack(FakeJenkins)
  end
end

WebMock.disable_net_connect!(allow_localhost: true)

require 'danger_plugin'

# These functions are a subset of https://github.com/danger/danger/blob/master/spec/spec_helper.rb
# If you are expanding these files, see if it's already been done ^.

# A silent version of the user interface,
# it comes with an extra function `.string` which will
# strip all ANSI colours from the string.

# rubocop:disable Lint/NestedMethodDefinition
def testing_ui
  @output = StringIO.new
  def @output.winsize
    [20, 9999]
  end

  cork = Cork::Board.new(out: @output)
  def cork.string
    out.string.gsub(/\e\[([;\d]+)?m/, '')
  end
  cork
end
# rubocop:enable Lint/NestedMethodDefinition

# Example environment (ENV) that would come from
# running a PR on TravisCI
def travis_env
  {
    'HAS_JOSH_K_SEAL_OF_APPROVAL' => 'true',
    'TRAVIS_PULL_REQUEST' => '800',
    'TRAVIS_REPO_SLUG' => 'artsy/eigen',
    'TRAVIS_COMMIT_RANGE' => '759adcbd0d8f...13c4dc8bb61d',
    'DANGER_GITHUB_API_TOKEN' => '123sbdq54erfsd3422gdfio'
  }
end

# Example environment (ENV) that would come from
# running a PR on Jenkins
def jenkins_env
  {
    'DANGER_GITHUB_API_TOKEN' => '123sbdq54erfsd3422gdfio',
    'ghprbPullId' => 1,
    'JENKINS_URL' => 'http://jenkins.ci',
    'BUILD_URL' => 'http://jenkins.ci/job/DemoJob/1',
    'GIT_URL' => 'https://github.com/danger/danger.git'
  }
end

# A stubbed out Dangerfile on Jenkins for use in tests
def jenkins_dangerfile
  env = Danger::EnvironmentManager.new(jenkins_env)
  ENV['BUILD_URL'] = jenkins_env['BUILD_URL']
  Danger::Dangerfile.new(env, testing_ui)
end

# A stubbed out Dangerfile on Travis for use in tests
def travis_dangerfile
  env = Danger::EnvironmentManager.new(travis_env)
  Danger::Dangerfile.new(env, testing_ui)
end
