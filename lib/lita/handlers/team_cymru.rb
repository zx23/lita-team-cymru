module Lita
  module Handlers
    class TeamCymru < Handler
      route(/^echo\s+(.+)/, :echo, help:
            { "echo TEXT" => "Replies back with TEXT." }
      )

      def echo(response)
        response.reply(response.args.join(" "))
      end

      Lita.register_handler(self)
    end
  end
end
