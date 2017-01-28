require 'socket'

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
        response.reply(query_cymru(response.args.last.to_s))
      end

      def query_cymru(arg)
        query = '-p ' + arg + '\r\n'

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
