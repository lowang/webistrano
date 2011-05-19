# http://gist.github.com/57165

module Capistrano::Configuration::Connections
  alias_method :execute_on_servers_without_ignoring_no_matching_server_error, :execute_on_servers
  def execute_on_servers_with_ignoring_no_matching_server_error(*args, &block)
    execute_on_servers_without_ignoring_no_matching_server_error(*args, &block)
  rescue Capistrano::NoMatchingServersError => e
    logger.info "skipping `#{current_task.fully_qualified_name}' because no servers matched"
  end
  alias_method :execute_on_servers, :execute_on_servers_with_ignoring_no_matching_server_error
end

module Capistrano::Configuration::Servers
  protected
  def role_list_from(roles)
    roles = roles.split(/,/) if String === roles
    roles = build_list(roles)
    roles.map do |role|
      role = String === role ? role.strip.to_sym : role
      self.roles.key?(role) ? role : nil
    end.flatten
  end
end