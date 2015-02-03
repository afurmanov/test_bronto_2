How to run the test:

  - `git clone https://github.com/afurmanov/test_bronto.git`
  - `cd test_bronto`
  - `bundle`
  - `bundle exec ruby ./test.rb`

Script will:
 1. Create copy of message "Green Template Message" with identical HTML and subject,
 the message name is going to be 'New Copied Message [latest_time_stamp]'
 2. Then it fetches HTML of newly created message
 3. Saves both original and copied messages HTML content into
 local directory in files:
 `new_copied_message.html` and `original_message.html`

After running the script, compare content of HTML of two messages:

  `diff original_message.html new_copied_message.html` - shows they are identical

Now go to Bronto UI, find new message named 'New Copied Message [latest_time_stamp]' and try
edit its HTML content. You will see it is shown very differently than original message has, regardless
it has same HTML content. It misses header image and navigational links.

Note: while script is running, all SOAP communication with Bronto end-point is printed, so
you should see all API calls on 'low' level.
