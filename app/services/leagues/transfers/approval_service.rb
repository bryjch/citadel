module Leagues
  module Transfers
    module ApprovalService
      include BaseService
      extend CompletionMessageServicer

      def call(request, user)
        request.transaction do
          request.approve(user) || rollback!

          user   = request.user
          roster = request.roster
          notify_users(request, user, roster)
          notify_captains(request, user, roster)
        end
      end

      private

      def message(transfer_msg)
        "The request to transfer #{transfer_msg} has been approved."
      end
    end
  end
end
