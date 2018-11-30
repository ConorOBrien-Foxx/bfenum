require 'json'
require_relative 'enumlib.rb'
require_relative 'keybdio.rb'
require 'tempfile'

STATE_LOCATION = "./state.json"
EDITOR="np.bat"

def get_input(initial="")
    temp = Tempfile.new("input.txt", "./")
    begin
        temp.write initial
        temp.rewind
        system "#{EDITOR} #{temp.path}"
        temp.read
    ensure
        temp.close
        temp.unlink
    end
end

def get_body(name)
    parse_body get_input(
        "\n\n# Please enter text for property #{name.inspect}"
    )
end

def parse_body(body)
    body.lines.reject { |e|
        e[0] == "#" || e.empty?
    }.map(&:strip).join("\n").strip
end

def show(obj, indent=0)
    case obj
        when Hash
            obj.each { |k, v|
                print " " * indent + k.inspect + " => "
                show v, indent + 4
            }
        # when Array
            # show obj.map.with_index { |a, b| [b, a] }.to_h
        else
            puts obj.inspect
    end
end



json = File.read STATE_LOCATION

state = JSON::parse json

program = EnumBF.denumerate state["index"]

puts "The following program has been generated for index #{state["index"]}:"
p program

puts "Press enter to continue..."
STDIN.gets
stats = {
    index: state["index"],
    program: program,
    size: program.size,
    comments: nil,
    executions: [],
    infinite: 0,
}

if user_confirm? "Does this program terminate?"
    unless user_confirm? "Does the program always terminate?"
        stats[:infinite] = 1
    end
    loop {
        print "Enter maximum amount of generations [default: 5000] "
        trials = STDIN.gets.strip
        trials = trials.empty? ? nil : trials.to_i
        stats[:executions].push EnumBF.evaluate program, *trials
        p stats[:executions].last
        break unless user_confirm? "Run again?"
        
        unless user_confirm? "Keep last trial?"
            stats[:executions].pop
        end
    }
else
    stats[:infinite] = 2
end

BODY_PROPERTIES = %w(comments).map(&:to_sym)

BODY_PROPERTIES.each { |property|
    stats[property] = get_body property
}

stats["tags"] = []

puts "Enter this program's tags (empty line = stop)"
loop {
    line = STDIN.gets.strip
    break if line.empty?
    stats["tags"] << line
}

puts "Stats for #{program.inspect}:"
show stats

if user_confirm? "Save these stats?"
    state["programs"][state["index"].to_s] = stats
    state["index"] += 1
    File.write STATE_LOCATION, state.to_json
else
    puts "Aborting."
end