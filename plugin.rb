# name: discourse-bulk-messages
# version: 1.0.3
# authors: boyned/Kampfkarren, buildthomas

enabled_site_setting :bulk_messages_enabled

add_admin_route "discourse_bulk_messages.title", "discourse-bulk-messages"

after_initialize do
	require_dependency "staff_constraint"

  module ::DiscourseBulkMessages
    class Engine < ::Rails::Engine
      engine_name "discourse_bulk_messages"
      isolate_namespace DiscourseBulkMessages
    end
  end

  class DiscourseBulkMessages::DiscourseBulkMessagesController < ::ApplicationController
    def action
      Jobs.enqueue(:bulk_message,
        anonymous: params[:anonymous],
        closed: params[:closed],
        group: params[:group],
        raw: params[:raw],
        title: params[:title],
        usernames: params[:usernames],
        current_user_id: current_user.id,
      )

      render json: []
    end
  end

  DiscourseBulkMessages::Engine.routes.draw do
    post "/admin/plugins/discourse-bulk-messages" => "discourse_bulk_messages#action", constraints: StaffConstraint.new
  end

  Discourse::Application.routes.append do
		get "/admin/plugins/discourse-bulk-messages" => "admin/plugins#index", constraints: StaffConstraint.new
    mount ::DiscourseBulkMessages::Engine, at: "/"
  end

  load File.expand_path("../app/jobs/regular/bulk_message.rb", __FILE__)
end
