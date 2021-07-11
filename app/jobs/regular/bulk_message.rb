module Jobs
  class BulkMessage < Base
    sidekiq_options retry: false

    def initialize
      super
      @logs = []
      @sent = 0
      @failed = 0
    end

    def execute(args)
      @anonymous = args[:anonymous] == "true"
      @closed = args[:closed] == "true"
      @group = args[:group]
      @raw = args[:raw]
      @title = args[:title]
      @usernames = args[:usernames]

      raise Discourse::InvalidParameters.new(:usernames) if @usernames.blank?
      raise Discourse::InvalidParameters.new(:raw) if @raw.blank?
      raise Discourse::InvalidParameters.new(:title) if @title.blank?

      @current_user = User.find_by(id: args[:current_user_id])

      @sender = @anonymous ? Discourse.system_user : @current_user
      @base_target = @anonymous ? [] : [@current_user.username]
      @target_group_names = @group.blank? ? nil : [@group]

      process_usernames
    ensure
      notify_user
    end

    def process_usernames
      @usernames.each do |username|
        if User.find_by(username: username).present?
          send_message(username)
          @sent += 1
        else
          save_log "Invalid username #{username}"
          @failed += 1
        end
      end
    end

    def send_message(username)
      begin

        post = PostCreator.new(@sender,
          title: @title,
          raw: @raw.gsub("%USER%", username),
          archetype: Archetype.private_message,
          target_group_names: @target_group_names,
          target_usernames: @base_target + [username],
          skip_validations: true
        ).create!

        post.topic.update("closed" => true) if @closed

      rescue => e
        save_log "Error inviting #{username} -- #{Rails::Html::FullSanitizer.new.sanitize(e.message)}"
        @sent -= 1
        @failed += 1
      end
    end

    def save_log(message)
      @logs << "[#{Time.now}] #{message}"
    end

    def notify_user
      if @current_user
        if @sent > 0 and @failed == 0
          SystemMessage.create_from_system_user(
            @current_user,
            :bulk_message_succeeded,
            sent: @sent
          )
        else
          SystemMessage.create_from_system_user(
            @current_user,
            :bulk_message_failed,
            sent: @sent,
            failed: @failed,
            logs: @logs.join("\n"),
          )
        end
      end
    end
  end
end
