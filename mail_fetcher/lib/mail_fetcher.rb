require File.dirname(__FILE__) + "/pop"
require File.dirname(__FILE__) + "/imap"
require "rubygems"
require "yaml"
require "tmail"
require "activesupport"
require "mms2r"
require "fileutils"

def fetch(server, username, password, port, save_path)
  @retrieved_messages = []
  puts "#{Time.now.strftime("%m/%d/%Y %I:%M%p")} Checking for new e-growlclucks from mail.glitterbacon.com..."
  imap = Net::IMAP.new(server, port, true)
  imap.login(username, password)
  imap.examine('INBOX')
  imap.search(['ALL']).each do |message_id|
    puts "Processing email #{message_id}..."
    @email = TMail::Mail.parse(imap.fetch(message_id,'RFC822')[0].attr['RFC822'])
    mms = MMS2R::Media.new(@email)
    @caption = "#{mms.subject} #{mms.body}"
    @attachment = mms.default_media
    @attachment.path.gsub(/\.([^\.]+)$/) do |match|
      @filetype = match
    end
    if (@filetype == ".jpg" || @filetype == ".JPG" || @filetype == ".jpeg" || @filetype == ".JPEG" || @filetype == ".png" || @filetype == ".PNG" || @filetype == ".gif" || @filetype == ".GIF") == false
      puts "No attachment found"
      @message = @caption
    else
      puts "Attachment found. Saving..."
      @name = "#{attachment_name(5)}#{@filetype}"
      @image_path = "#{save_path}/#{@name}"
      @message = "http://www.glitterbacon.com/uploads/#{@name} #{@caption}"
      FileUtils.cp @attachment.path, @image_path, :verbose => true
    end
    @retrieved_messages << {"#{@email.from}" => "#{@message}"}
    puts @retrieved_messages.inspect 
  end
  imap.copy(1..-1, "[Gmail]/All Mail")
  imap.store(1..-1, "+FLAGS", [:Deleted])
  imap.close
  return @retrieved_messages
end

def attachment_name(len)
    sweet = %w[alpha space beta omega zone base bass centaur official free fresh freedom power black synth com lazer gamma red green ultra net cafe secret blossoming open track wisdom genghis tron grid plus max maximum pre post mid pyramid core hard fast dragon wizard yak  crystal electric rizzle tiny panty pantry moist dry bleeding fruit mower whiskey bat venti marble cake skinny whip meat donkey tata wewo banana rooster bear bacon moon glitter grandma walrus butts party junk crazy turbo hyper mega boss dunk pow icy bobo pile sick tight browns tater butts wiz tek gnarl mix pop reef mustard bizzler bo-be-ba fog punch neckfat planar]
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    name = ""
    1.upto(3) { |i| name << chars[rand(chars.size-1)] }
    1.upto(len) { |i| name << sweet[rand(sweet.size-1)] }
    return name
end

# for in file run testing
# fetch("imap.gmail.com", "post@glitterbacon.com", "!glitterbacon", "993", "/")