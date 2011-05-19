module Nokaut
  module CapistranoExt
    def nokaut_invoke_tasks(*tasks)
      nokaut_invoker = fetch(:nokaut_invoker)
      tasks = tasks.first if tasks.first.kind_of?(Array)
      raise "No :nokaut_invoker set!" unless nokaut_invoker
      tasks.each do |task|
        sudo nokaut_invoker+ " #{task}"
      end
    end
  
    def chown(user,group,*paths)
      cmd = "chown --silent -R "
      cmd << "#{user}"   if user
      cmd << ":#{group}" if group
      paths = paths.first if paths.first.kind_of?(Array)
      paths.each do |path|
        sudo cmd + " #{path}"
      end
    end
  
    def chmod(rights,*paths)
      cmd = "chmod --silent -R #{rights}"
      paths = paths.first if paths.first.kind_of?(Array)
      paths.each do |path|
        sudo cmd + " #{path}"
      end
    end
  
    def target_dir
      fetch(:deploy_to)+fetch(:application)
    end

    def clear_shm
      raise "No :shm_path set!" unless fetch(:shm_path)
      _shm_path = fetch(:shm_path)
      return if _shm_path.blank?
      _shm_path = [_shm_path] unless _shm_path.kind_of?(Array)
      _shm_path.each do |path|
        sudo "rm -rf #{path}"
      end
    end
  end
end

Capistrano.plugin :nokaut_project, Nokaut::CapistranoExt
