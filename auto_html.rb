def auto_html(text)
  text.gsub(/http:\/\/.+\.(jpg|gif|png)/i) do |match|
    return "<center><img src='#{match}' alt='' width='80%' /></center>"
  end
  text.gsub(/http:\/\/(www.)?vimeo\.com\/([A-Za-z0-9._%-]*)[&\w;=\+_\-]*/) do
    vimeo_id = $2
    return %{<center><object width="80%" height="320"><param name="allowfullscreen" value="true" /><param name="allowscriptaccess" value="always" /><param name="movie" value="http://vimeo.com/moogaloop.swf?clip_id=#{vimeo_id}&amp;server=vimeo.com&amp;show_title=0&amp;show_byline=0&amp;show_portrait=0&amp;color=00adef&amp;fullscreen=1" /><embed src="http://vimeo.com/moogaloop.swf?clip_id=#{vimeo_id}&amp;server=vimeo.com&amp;show_title=0&amp;show_byline=0&amp;show_portrait=0&amp;color=00adef&amp;fullscreen=1" type="application/x-shockwave-flash" allowfullscreen="true" allowscriptaccess="always" width="80%" height="320"></embed></object></center>}    
  end
  text.gsub(/http:\/\/(www.)?youtube\.com\/watch\?v=([A-Za-z0-9._%-]*)[&\w;=\+_\-]*/) do
    youtube_id = $2
    return %{<center><object width="80%" height="320"><param name="movie" value="http://www.youtube.com/v/#{youtube_id}"></param><param name="wmode" value="transparent"></param><embed src="http://www.youtube.com/v/#{youtube_id}" type="application/x-shockwave-flash" wmode="transparent" width="80%" height="320"></embed></object></center>}
  end
  text.gsub(/http:\/\/.+?/) do
    return %{<a href="#{text}">#{text}</a>}
  end
  return text
end