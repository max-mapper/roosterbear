require File.dirname(__FILE__) + "/pop"
require File.dirname(__FILE__) + "/imap"
require "rubygems"
require "yaml"
require "tmail"
require "activesupport"

def fetch(server, username, password, port)
  @retrieved_messages = []
  puts "Retrieving new e-growlclucks from: #{server} #{username} #{password} #{port}"
  imap = Net::IMAP.new(server, port, true)
  imap.login(username, password)
  imap.examine('INBOX')
  imap.search(['ALL']).each do |message_id|
    email = TMail::Mail.parse(imap.fetch(message_id,'RFC822')[0].attr['RFC822'])
    puts email
    email.parts.each do |part|
      if part.disposition == "attachment"
        filename = part.disposition_param('filename') 
          if filename[0,2] == '=?' 
            filename.gsub!(/=\?[^\?]+\?(.)\?([^\?]+)\?=$/){ $1 == 'B' ? $2.unpack('m*') : $2.unpack('M*') } 
          end 
        puts "Attachment: #{filename}"
        File.open(filename,'wb') { |f| f.write(part.body) }
      end
      if part.multipart?
        part.parts.each do |yodawg| #i herd u liek parts so i put a multipart in your multipart
          if yodawg.content_type =~ /html/i
            message = {}
            message["body"] = yodawg.body
            message["subject"] = email.subject
            message["from"] = email.from
            @retrieved_messages << message
          end
        end
      end
    end
    imap.copy(message_id, "[Gmail]/All Mail")
    imap.store(message_id, "+FLAGS", [:Deleted])
  end
  imap.close
  return @retrieved_messages
end

@mail = fetch("imap.gmail.com", "post@glitterbacon.com", "!glitterbacon", "993")