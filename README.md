How to run the test:

  - `git clone https://github.com/afurmanov/test_bronto_2.git`
  - `cd test_bronto_2`
  - `bundle`
  - Replace in test.rb 'XXX' with real API key
  - `bundle exec ruby ./test.rb`

What script does:
 1. Fetch message named "Pumpkins Template Based Message"
 2. Call 'updateMessages' API method with id of message from step #1 and same HTML and Text contents

Step #2 fails and Bronto response is:
```
HTTPI executes HTTP POST using the net_http adapter
SOAP response (status 200):
<?xml version="1.0"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <ns2:updateMessagesResponse xmlns:ns2="http://api.bronto.com/v4">
      <return>
        <errors>0</errors>
        <results>
          <isError>true</isError>
          <errorCode>605</errorCode>
          <errorString>Invalid message from template: Pumpkins Template Based Message</errorString>
        </results>
      </return>
    </ns2:updateMessagesResponse>
  </soap:Body>
</soap:Envelope>
````
