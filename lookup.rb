def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")

def parse_dns(dns_raw)
  dns_raw = dns_raw.reject { |s| s.strip.empty? }
  dns_raw = dns_raw[1..-1]
  dnsreturn={}
  for i in 0..dns_raw.length-1 do
    t = dns_raw[i].split(",")
    t_hash = Hash.new
    t_hash[:type] = t[0].strip
    t_hash[:target] = t[2].strip
    dnsreturn[t[1].strip] = t_hash
  end
  return(dnsreturn)
end

def resolve(dns_records,lookup_chain,domain)
  records = dns_records[domain]
  if !(records)
    lookup_chain = []
    err_Message = "Error: record not found for "+domain.to_s
    lookup_chain.push(err_Message)
  elsif records[:type] == "A"
    lookup_chain.push(records[:target])
  elsif records[:type] == "CNAME"
    lookup_chain.push(records[:target])
    resolve(dns_records,lookup_chain,records[:target])
  end
end

dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
