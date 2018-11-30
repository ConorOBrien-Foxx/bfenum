require 'io/console'

def getkey(check_terminate=true)
    key = STDIN.getch
    exit! 1 if check_terminate && key == "\x03"
    key
end

def option(prompt=nil, options="yn", show_result: true)
    unless prompt.nil?
        print prompt, " "
    end
    
    options = options.chars if options.is_a? String
    
    loop {
        print "[#{options.join "/"}] "
        result = getkey
        puts result if show_result
        
        break result if options.include? result
        
        puts "Invalid option #{result.inspect}"
    }
end

def yesno(prompt=nil)
    option(prompt, "yn")
end

def user_confirm?(prompt=nil)
    yesno(prompt) == "y"
end