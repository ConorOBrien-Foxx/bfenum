require 'json'
require_relative 'keybdio.rb'

STATE_LOCATION = "./state.json"

if File.exists? STATE_LOCATION
    if user_confirm? "#{STATE_LOCATION} already exists. Overwrite?"
        puts "Overwriting file."
    else
        puts "Canceling."
        exit! 1
    end
end

state = {
    programs: {},
    index: 0,
}

File.write STATE_LOCATION, state.to_json
puts "Initial state successfully written to #{STATE_LOCATION}"