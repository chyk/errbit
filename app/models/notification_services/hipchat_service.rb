if defined? HipChat
  class NotificationServices::HipchatService < NotificationService
    Label = 'hipchat'
    Fields += [
      [:api_token, {
        :placeholder => "API Token"
      }],
      [:room_id, {
        :placeholder => "Room name",
        :label       => "Room name"
      }],
      [:api_version, {
        :placeholder => "v1 or v2",
        :label       => "API version"
      }]
    ]

    def check_params
      if Fields.any? { |f, _| self[f].blank? }
        errors.add :base, 'You must specify your Hipchat API token and Room ID'
      end
    end

    def url
      "https://www.hipchat.com/sign_in"
    end

    def create_notification(problem)
      url = app_problem_url problem.app, problem
      message = <<-MSG.strip_heredoc
        <strong>#{ERB::Util.html_escape problem.app.name}</strong> error in <strong>#{ERB::Util.html_escape problem.environment}</strong> at <strong>#{ERB::Util.html_escape problem.where}</strong> (<a href="#{url}">details</a>)<br>
        &nbsp;&nbsp;#{ERB::Util.html_escape problem.message.to_s.truncate(100)}<br>
        &nbsp;&nbsp;Times occurred: #{problem.notices_count}
      MSG

      client = HipChat::Client.new(api_token, api_version.blank? ? {} : {:api_version => api_version})
      client[room_id].send('Errbit', message, :color => 'red')
    end
  end
end
