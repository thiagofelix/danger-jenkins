require File.expand_path('../spec_helper', __FILE__)

module Danger
  describe Danger::DangerJenkins do
    it 'should be a plugin' do
      dangerfile = jenkins_dangerfile
      expect(Danger::DangerJenkins.new(dangerfile)).to be_a Danger::Plugin
    end

    #
    # You should test your custom attributes and methods here
    #
    describe 'with Dangerfile' do
      before do
        @dangerfile = jenkins_dangerfile
        @jenkins = @dangerfile.jenkins
      end

      it 'raise if not Jenkins CI' do
        expect { travis_dangerfile }.to raise_error(RuntimeError)
      end

      it "raise if can't determine current build" do
        ENV.delete 'BUILD_URL'
        expect { travis_dangerfile }.to raise_error(RuntimeError)
      end

      it 'queries current build on Jenkins' do
        expect(@jenkins.build.id).to eq('2')
        expect(@jenkins.build.number).to eq(2)
        expect(@jenkins.build.displayName).to eq('#2')
        expect(@jenkins.build.fullDisplayName).to eq('DemoJob #2')
        expect(@jenkins.build.nextBuild.number).to eq(3)
        expect(@jenkins.build.nextBuild.url).to eq('http://jenkins.ci/job/DemoJob/3/')
        expect(@jenkins.build.previousBuild.number).to eq(1)
        expect(@jenkins.build.previousBuild.url).to eq('http://jenkins.ci/job/DemoJob/1/')
        expect(@jenkins.build.result).to eq('SUCCESS')

        artifacts = ['report.html', 'App.ipa']
        expect(@jenkins.build.artifacts.map(&:displayPath)).to eq(artifacts)
      end

      it 'prints artifacts' do
        expected = <<-EOF
### Jenkins artifacts:

<img width='40' align='right' src='https://wiki.jenkins-ci.org/download/attachments/2916393/headshot.png'></img>
* <a href=http://jenkins.ci/job/DemoJob/1/artifact/output/report.html target='_blank'>output/report.html</a>
* <a href=http://jenkins.ci/job/DemoJob/1/artifact/output/App.ipa target='_blank'>output/App.ipa</a>
        EOF

        @jenkins.print_artifacts
        markdowns = @dangerfile.status_report[:markdowns].map(&:message)
        expect(markdowns).to eq([expected])
      end

      it 'prints console output' do
        @jenkins.print_console_output
        markdowns = @dangerfile.status_report[:markdowns].map(&:message)
        expected = [
          "### Jenkins console output:\n\n",
          '<details>',
          '<summary>Details</summary>',
          '<pre>console output</pre>',
          "</details>"
        ].join
        expect(markdowns).to eq([expected])
      end
    end
  end
end
