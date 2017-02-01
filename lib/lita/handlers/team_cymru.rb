require 'socket'
require 'resolv'
require 'ipaddress'

module Lita
  module Handlers
    # Implements lita-team-cymru handler
    class TeamCymru < Handler
      WHOIS_HOST = 'whois.cymru.com'.freeze
      WHOIS_PORT = 43

      route(
        /^cymru\s+(.+)/,
        :cymru,
        help: { 'cymru IP / AS NUM' => 'Looks up IP / AS information.' }
      )

      def cymru(response)
        case response.args.first
        when 'bogon'
          response.reply(bogon_cymru(response.args.last.to_s))
        when 'lookup'
          response.reply(query_cymru(response.args.last.to_s))
        else
          response.reply("I don't know how to do that")
        end
      end

      def bogon_cymru(ip)
        # FIXME: this needs to be a dedicated method to also validate
        # IPs given to "lookup" command
        if IPAddress.valid_ipv4?(ip)
          reversed_ip = ip.split('.').reverse.join('.')
          bogons_host = 'v4.fullbogons.cymru.com'
        elsif IPAddress.valid_ipv6?(ip)
          reversed_ip = IPAddress(ip).reverse.chomp('.ip6.arpa')
          bogons_host = 'v6.fullbogons.cymru.com'
        else
          return "That doesn't look like an IP address"
        end

        query = "#{reversed_ip}.#{bogons_host}"
        begin
          resolver = Resolv::DNS.new
          response = resolver.getresource(
            query, Resolv::DNS::Resource::IN::TXT
          ).strings[0]
          "bogon in #{response}"
        # FIXME: this is indistinguishable from a broken resolver or
        # broken network connectivity
        rescue Resolv::ResolvError
          'not a bogon'
        end
      end

      def query_cymru(arg)
        query = '-p ' + arg + "\r\n"

        socket = TCPSocket.open(WHOIS_HOST, WHOIS_PORT)
        socket.print(query)
        answer = socket.read
        socket.close
        answer
      end

      Lita.register_handler(self)
    end
  end
end
