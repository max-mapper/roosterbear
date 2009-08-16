def embed(type, match)
  case type
    when "image"
      return "<center><img src='#{match}' alt='' width='80%' /></center>"
    when "vimeo"
      return %{<center><object width="80%" height="320"><param name="allowfullscreen" value="true" /><param name="allowscriptaccess" value="always" /><param name="movie" value="http://vimeo.com/moogaloop.swf?clip_id=#{match}&amp;server=vimeo.com&amp;show_title=0&amp;show_byline=0&amp;show_portrait=0&amp;color=00adef&amp;fullscreen=1" /><embed src="http://vimeo.com/moogaloop.swf?clip_id=#{match}&amp;server=vimeo.com&amp;show_title=0&amp;show_byline=0&amp;show_portrait=0&amp;color=00adef&amp;fullscreen=1" type="application/x-shockwave-flash" allowfullscreen="true" allowscriptaccess="always" width="80%" height="320"></embed></object></center>}
    when "youtube"
      return %{<center><object width="80%" height="320"><param name="movie" value="http://www.youtube.com/v/#{match}"></param><param name="wmode" value="transparent"></param><embed src="http://www.youtube.com/v/#{match}" type="application/x-shockwave-flash" wmode="transparent" width="80%" height="320"></embed></object></center>}
    when "link"
      return %{<a style='color:#000;text-decoration:underline' href="#{match}">#{match}</a>}
    when "string"
      return match
  end
end

def auto_html(post)
  matches = []
  string = ""
  words = post.split(" ").each do |text|
    text.gsub!(/(http:\/\/.\S+\.(jpg|png|gif|bmp))/i, "")
    matches << {"image" => $1} unless $1.nil?
    text.gsub!(/http:\/\/(www.)?vimeo\.com\/([A-Za-z0-9._%-]*)[&\w;=\+_\-]*/, "")
    matches << {"vimeo" => $2} unless $2.nil?
    text.gsub!(/http:\/\/(www.)?youtube\.com\/watch\?v=([A-Za-z0-9._%-]*)[&\w;=\+_\-]*/, "")
    matches << {"youtube" => $2} unless $2.nil?
    text.gsub!(/(http:\/\/.+)/, "")
    matches << {"link" => $1} unless $1.nil?
    string = (string.to_s + " " + text).gsub!(/\s+/," ").lstrip unless text.nil?
  end
  matches << {"string" => string}
  result = ""
  matches.each do |match|
    match.each do |type, value|
      result << embed(type, value)
    end
  end
  puts result
end