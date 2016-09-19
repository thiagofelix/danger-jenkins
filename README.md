

### jenkins

Get access to Jenkins information right into your Dangerfile

<blockquote>Configure credentials to access the Jenkins API
  <pre>jenkins.user_id = YOUR_USER_ID
jenkins.api_token = YOUR_API_TOKEN</pre>
</blockquote>

<blockquote>Print list of artifacts in the PR page
  <pre>jenkins.print_artifacts</pre>
</blockquote>

<blockquote>Print console output in the PR page
  <pre>jenkins.print_console_output</pre>
</blockquote>

<blockquote>Get access to the build properties
  <pre>message "The spent #{jenkins.build.duration} time"</pre>
</blockquote>

<blockquote>Customize how you want to present the console output
  <pre>markdown "### Console output: \n\n #{jenkins.console_text}"</pre>
</blockquote>



#### Attributes

`user_id` - User to authenticate with Jenkins REST API

`api_token` - API token to authenticate with Jenkins REST API




#### Methods

`build` - Hash containing details about the build which triggered
the danger process

`console_html` - Console output in html format

`console_text` - Console output in text format

`print_artifacts` - Adds a list of artifacts to the danger comment

`print_console_output` - Adds a collapsable console output to danger comment




