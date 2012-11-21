QUOTE = '"\u201C\u201D\u201E\u201F\u2033\u2036'

Edition.all.each do |edition|
  affected = false
  new_body = edition.body.lines.map do |line|
    if line.match(/^> /)
      if line.match(/[#{QUOTE}]/)
        new_line = line.sub(/^>\s+[#{QUOTE}]/, '> ').sub(/[#{QUOTE}]\s*$/, '')
        affected = true
        puts "#{line} => #{new_line}"
        new_line
      else
        line
      end
    else
      line
    end
  end.join('\n')
end
