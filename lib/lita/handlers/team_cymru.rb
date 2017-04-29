require "ipaddress"
require "resolv"
require "socket"

module Lita
  module Handlers
    # Implements lita-team-cymru handler
    class TeamCymru < Handler
      Lita.register_handler(self)

      WHOIS_HOST = "whois.cymru.com".freeze
      WHOIS_PORT = 43
      RR_TYPE = Resolv::DNS::Resource::IN::TXT.freeze

      route(
        /^cymru\s+lookup\s+/,
        :cymru_lookup,
        help: {
          "cymru lookup IP|AS NUM" => "Look up IP|AS information.",
        }
      )

      route(
        /^cymru\s+bogon\s+/,
        :cymru_bogon,
        help: {
          "cymru bogon IP" => "Check if IP is a bogon.",
        }
      )

      # v4_ip? returns true if given argument is a valid IPv4 address
      def v4_ip?(ip)
        v4_ip = false
        v4_ip = true if IPAddress.valid_ipv4?(ip)
      end

      # v6_ip? returns true if given argument is a valid IPv6 address
      def v6_ip?(ip)
        v6_ip = false
        v6_ip = true if IPAddress.valid_ipv6?(ip)
      end

      # cymru_lookup queries Team Cymru WHOIS server for information
      # about given IP address or AS number.
      def cymru_lookup(response)
        arg = response.args.last.to_s
        query = "-v " + arg + "\r\n"
        socket = nil

        begin
          socket = TCPSocket.open(WHOIS_HOST, WHOIS_PORT)
        rescue SocketError
          response.reply("Unable to resolve #{WHOIS_HOST}")
        rescue Errno::ECONNREFUSED
          response.reply("Connection refused #{WHOIS_HOST}:#{WHOIS_PORT}")
        rescue Errno::ETIMEDOUT
          return
        else
          socket.print(query)
          answer = socket.read
          socket.close
          response.reply(answer)
        end
      end

      # cymru_bogon queries Team Cymru bogon reference via DNS.
      def cymru_bogon(response)
        ip = response.args.last.to_s

        if v4_ip?(ip)
          reversed_ip = ip.split(".").reverse.join(".")
          bogons_host = "v4.fullbogons.cymru.com"
        elsif v6_ip?(ip)
          reversed_ip = IPAddress(ip).reverse.chomp(".ip6.arpa")
          bogons_host = "v6.fullbogons.cymru.com"
        else
          response.reply("Invalid IP address")
          return
        end

        query = "#{reversed_ip}.#{bogons_host}"
        resolver = Resolv::DNS.new
        begin
          dns_response = resolver.getresource(query, RR_TYPE)
        # FIXME: this is indistinguishable from a broken resolver or
        # broken network connectivity
        rescue Resolv::ResolvError
          response.reply("Not a bogon")
        else
          response.reply("Bogon in #{dns_response.strings[0]}")
        end
      end

    end
  end
end
