require 'net/http'
require 'uri'

module Danger
  # Get access to Jenkins information right into your Dangerfile
  #
  # @example Configure credentials to access the Jenkins API
  #          jenkins.user_id = YOUR_USER_ID
  #          jenkins.api_token = YOUR_API_TOKEN
  #
  # @example Print list of artifacts in the PR page
  #          jenkins.print_artifacts
  #
  # @example Print console output in the PR page
  #          jenkins.print_console_output
  #
  # @example Get access to the build properties
  #          message "The spent #{jenkins.build.duration} time"
  #
  # @example Customize how you want to present the console output
  #          markdown "### Console output: \n\n #{jenkins.console_text}"
  #
  # @see  thiagofelix/danger-jenkins
  # @tags jenkins
  #
  class DangerJenkins < Plugin
    JENKINS_ICON = 'https://wiki.jenkins-ci.org/download/attachments/2916393/headshot.png'.freeze

    # User to authenticate with Jenkins REST API
    #
    # @return   String
    attr_accessor :user_id

    # API token to authenticate with Jenkins REST API
    #
    # @return   String
    attr_accessor :api_token

    def initialize(dangerfile)
      super(dangerfile)

      @env = dangerfile.env
      @user_id = ENV['JENKINS_USER_ID']
      @api_token = ENV['JENKINS_API_TOKEN']
      @build_url = ENV['BUILD_URL']

      raise 'Invalid CI for Jenkins plugin.' unless jenkins?
      raise "Can't find current build" if @build_url.nil?
    end

    # Hash containing details about the build which triggered
    # the danger process
    #
    # @return OpenStruct
    def build
      @current_build ||= fetch_current_build
    end

    # Console output in html format
    #
    # @return String
    def console_html
      @console_html_format ||= fetch_console(:html)
    end

    # Console output in text format
    #
    # @return String
    def console_text
      @console_text_format ||= fetch_console(:text)
    end

    # Adds a list of artifacts to the danger comment
    #
    # @return [void]
    #
    def print_artifacts
      artifacts = build.artifacts
      return if artifacts.empty?

      content = "### Jenkins artifacts:\n\n"
      content << "<img width='40' align='right' src='#{JENKINS_ICON}'></img>\n"

      artifacts.each do |artifact|
        content << "* #{artifact_link(artifact)}\n"
      end

      markdown content
    end

    # Adds a collapsable console output to danger comment
    #
    # @return [void]
    #
    def print_console_output
      content =  "### Jenkins console output:\n\n"
      content << '<details>'
      content << '<summary>Details</summary>'
      content << "<pre>#{console_html}</pre>"
      content << '</details>'
      markdown content
    end

    private

    def jenkins?
      !@env.ci_source.nil? && @env.ci_source.is_a?(Danger::Jenkins)
    end

    def artifact_link(artifact)
      href = "#{@build_url}/artifact/#{artifact.relativePath}"
      "<a href=#{href} target='_blank'>#{artifact.relativePath}</a>"
    end

    def fetch_console(type = :text)
      case type
      when :text then
        fetch("#{@build_url}/logText/progressiveText")
      when :html then
        fetch("#{@build_url}/logText/progressiveHtml")
      end
    end

    def fetch_current_build
      url = "#{@build_url}/api/json"
      body = fetch(url)
      JSON.parse(body, object_class: OpenStruct)
    end

    def fetch(url, limit = 10)
      res = request(url)

      case res
      when Net::HTTPSuccess then
        res.body
      when Net::HTTPRedirection then
        fetch(res['location'], limit - 1)
      else
        res.value
      end
    end

    def request(url)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      req = Net::HTTP::Get.new(uri.request_uri)
      req.basic_auth(@user_id, @api_token)

      http.request(req)
    end
  end
end
