module DeploymentsHelper
  
  def input_type(name)
    if name.match(/password/)
      "password"
    else
      'text'
    end
  end
  
  def if_disabled_host?(host, text)
    (@deployment.excluded_host_ids.include?(host.id) ? text : '' rescue '')
  end
  
  def if_enabled_host?(host, text)
    (@deployment.excluded_host_ids.include?(host.id) ? '' : text rescue text)
  end

  def default_value_for(conf_name)
    RAILS_DEFAULT_LOGGER.warn("=> default_value_for")
    # get last value
    deployment = @stage.deployments.find_by_task(@deployment.task)
    return deployment.prompt_config[conf_name] if deployment && !deployment.prompt_config[conf_name].nil?
    # get default value if last one is not present
    conf = @stage.effective_configuration.collect { |c| c if c.name == conf_name }.compact.first
    conf.default_value if !conf.nil? && !conf.default_value.nil?
  end
end
