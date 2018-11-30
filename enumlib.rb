def to_regex(c)
    case c
        when Regexp
            c
        else
            Regexp.escape c.to_s
    end
end
class String
    alias :old_lstrip   lstrip
    alias :old_rstrip   rstrip
    alias :old_strip    strip
    alias :old_lstrip!  lstrip!
    alias :old_rstrip!  rstrip!
    alias :old_strip!   strip!
    
    @@NOT_PASSED = :NOT_PASSED
    
    def lstrip!(c=@@NOT_PASSED)
        if c == @@NOT_PASSED
            old_lstrip!
        else
            gsub!(/^#{to_regex c}+/, "") || self
        end
    end
    
    def lstrip(c=@@NOT_PASSED)
        if c == @@NOT_PASSED
            old_lstrip
        else
            dup.lstrip! c
        end
    end
    
    def rstrip!(c)
        if c == @@NOT_PASSED
            old_lstrip
        else
            gsub!(/#{to_regex c}+$/, "") || self
        end
    end
    
    def rstrip(c=@@NOT_PASSED)
        if c == @@NOT_PASSED
            old_rstrip
        else
            dup.rstrip! c
        end
    end
    
    def strip!(c=@@NOT_PASSED)
        if c == @@NOT_PASSED
            old_strip!
        else
            rstrip! c
            lstrip! c
        end
    end
    
    def strip(c=@@NOT_PASSED)
        if c == @@NOT_PASSED
            old_strip
        else
            rstrip(c).lstrip(c)
        end
    end
end
<<EOF

def test(program):
    c=d=C=D=0
    for e in program:v='[<>,.-+]'.find(e);d=d*8+v;c+=c<0<6<v;c-=d>1>v;C,D=(c,C+1,d,D)[v>6::2]
    return(-~D*8**C)

-----
c = d = C = D = 0

program = "+++++>>>-<<<-"
    
    for k, v in kw.items():
        print(f"    {k} = {v}")
    
    print("-"*20)


def test(inp):
    # count leading [ and remove them
    program = inp.lstrip("[")
    
    leading_left_count = len(inp) - len(program)
    
    # ignore trailing ]
    program = program.rstrip("]")
    
    build = 0
    for i, e in enumerate(program):
        index = '[<>,.-+]'.find(e)
        # append digit
        build = build * 8 + index
    
    # + 1 to map 0 to 1
    result = (build + 1) * 8**leading_left_count

    return result

EOF

# enumeration and denumeration functions translated from
# https://codegolf.stackexchange.com/a/55368/31957
# by https://codegolf.stackexchange.com/users/32700/thenumberone
module EnumBF
    TABLE = "[<>,.-+]"
    
    def self.enumerate(input)
        program = input.lstrip "["
        
        leading_left_count = input.size - program.size
        
        program.rstrip! "]"
        
        build = 0
        
        program.each_char { |c|
            ind = TABLE.index c
            
            build = build * 8 + ind
        }
        
        build * 8**leading_left_count
    end
    
    def self.denumerate(n)
        encoded = n.digits(8).reverse!
        return "" if encoded == [0]
        
        program = encoded.map { |d| TABLE[d] } .join
        
        temp = program.gsub(/\]+$/, "")
        loop_count = program.size - temp.size
        program = temp
        
        unmatched_right = loop_count
        depth = 0
        
        program.each_char { |op|
            depth += 1 if op == "["
            
            if op == "]"
                if depth > 0
                    depth -= 1
                else
                    unmatched_right += 1
                end
            end
        }
        
        unmatched_left = depth + loop_count
        
        "[" * unmatched_right + program + "]" * unmatched_left
    end
    
    EQUIVALENTS = {
        "+" => "tape[ptr] += 1; mod[]",
        "-" => "tape[ptr] -= 1; mod[]",
        ">" => "ptr += 1; bounds[]",
        "<" => "ptr -= 1; bounds[]",
        "[" => "until tape[ptr].zero?",
        "]" => "end",
        "," => "input += STDIN.getch; tape[ptr] = input[-1].ord; mod[]",
        "." => "output += tape[ptr].chr"
    }
    def self.compile(program, max_gen=5000)
        compiled = [
            "lambda { |max_gen|",
            "tape = Hash.new{|h,k|h[k]=0}",
            "step = 0",
            "ptr = 0",
            "bound_left = 0",
            "bound_right = 0",
            "output = ''",
            "input = ''",
            "bounds = -> {\n    bound_left = ptr if ptr < bound_left\n    bound_right = ptr if ptr > bound_right\n}",
            "mod = -> { tape[ptr] %= 256 }",
            "state = '{ steps: step, tape: tape, ptr: ptr, bounds: { left: bound_left, right: bound_right }, output: output, input: input, terminated: step <= max_gen }'",
        ] + program.chars.flat_map { |e|
            [
                EQUIVALENTS[e],
                "return eval state if step > max_gen",
                "step += 1",
            ]
        } + [
            "eval state",
            "} [#{max_gen}]"
        ]
        
        compiled.join "\n"
    end
    
    def self.evaluate(*args)
        eval compile *args
    end
end