module Lita
  module Handlers
    class TeamCymru < Handler
      # insert handler code here
      route(/^echo\s+(.+)/, :echo help: {
          "echo TEXT" => "Replies back with TEXT."
      })

      def echo(response)
        response.reply(escape("OK"))
      end

      Lita.register_handler(self)
    end
  end
end
