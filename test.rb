require 'savon'
require 'hashie'
require 'active_support/all'

class Script
  def initialize
    Savon.configure { |config|  config.pretty_print_xml = true }
    @client = Savon::Client.new do
      wsdl.endpoint = "https://api.bronto.com/v4"
      wsdl.namespace = "http://api.bronto.com/v4"
    end
    @messages = {}
  end

  def login
    resp = @client.request(:v4, :login) { soap.body = { :api_token => 'XXX' }}
    @soap_header = { "v4:sessionHeader" => { :session_id => resp.body[:login_response][:return] }}
  end

  def request(method, message)
    soap_header = @soap_header
    resp = @client.request(:v4, method.to_sym) do
      soap.header = soap_header
      soap.body = message
    end
    response = resp.body["#{method}_response".to_sym]
    check_response_for_errors(response)
    response = response[:return]
    response = response[:results] if response.is_a?(Hash) && response.key?(:results)
    return case response
           when Hash
             Hashie::Mash.new(response)
           when Array
             response.map { |e| Hashie::Mash.new(e) }
           else
             nil
           end
  end

  def check_response_for_errors(resp)
    retrn = Array.wrap(resp[:return]).first
    if (retrn && retrn[:errors].present?)
      result_index = retrn[:errors].first.to_i
      error = "results[#{result_index}] has an error"
      error_result = retrn[:results][result_index] if retrn[:results]
      error = "#{error} #{error_result}" if error_result && error_result[:is_error]
      raise "There was an error with the request: #{error}"
    end
  end

  def fetch_messages(message_names)
    all = request("read_messages", :filter => {:type => "AND"}, :includeContent => true, :pageNumber => 1)
    message_names.each do |key, name|
      @messages[key] = all.find { |m| m["name"] == name }
    end
  end

  def current_path
    File.expand_path(File.dirname(__FILE__))
  end

  def save_messages
    `rm -rf #{current_path}/*.html`
    @messages.each do |key, message|
      File.open("#{current_path}/#{key}.html", "w") do |f|
        content = Array.wrap(message["content"])
        html_content = content.find { |c| c["type"] == "html" }
        f.write html_content["content"]
      end
    end
  end

  def clone_original_message(new_message_name)
    original_message = @messages[:original_message]
    raise "Original message has not been fetched yet" unless original_message

    original_message_html_content = original_message.content.find {|c| c.type == "html"}["content"]
    original_message_html_subject = original_message.content.find {|c| c.type == "html"}["subject"]

    new_message = {content: []}
    new_message[:content] << {type: "html", subject: original_message_html_subject, content: original_message_html_content}
    folder_id = @messages[:original_message]["message_folder_id"]
    new_message = Hashie::Mash.new(new_message)
    new_message.name = new_message_name
    new_message.messageFolderId = folder_id
    request "add_messages", :messages => [new_message]
  end

  def update_message_with_original_content(key)
    raise "Message #{key} was not loaded yet" if @messages[key].blank?

    message = @messages[key]

    html_content = message.content.find {|c| c.type == "html" }
    text_content = message.content.find {|c| c.type == "text" }

    updated_message = Hashie::Mash.new
    updated_message.id = message.id
    updated_message.messageFolderId = message.message_folder_id
    updated_message.content = []
    updated_message.content << {:type => "text", :subject => text_content.subject, :content => text_content.content}
    updated_message.content << {:type => "html", :subject => html_content.subject, :content => html_content.content }

    request "update_messages", :messages => [updated_message]
  end
end


script = Script.new
script.login

script.fetch_messages(:original_pumpkin_message => "Pumpkins Template Based Message")
script.save_messages
script.update_message_with_original_content(:original_pumpkin_message)
