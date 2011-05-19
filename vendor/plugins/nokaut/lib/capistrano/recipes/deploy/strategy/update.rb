require 'capistrano/recipes/deploy/dependencies'
require 'capistrano/recipes/deploy/strategy/remote'
# load nokaut extension to subversion scm
require 'capistrano/recipes/deploy/scm/subversion_ext'

module Capistrano
  module Deploy
    module Strategy

      # This class implements the strategy for deployments which work
      # by updating the source code on each target host directory.
      class Update < Capistrano::Deploy::Strategy::Remote
        attr_reader :configuration

        # Instantiates a strategy with a reference to the given configuration.
        def initialize(config={})
          @configuration = config
        end

        # Executes the necessary commands to deploy the revision of the source
        # code identified by the +revision+ variable. Additionally, this
        # should write the value of the +revision+ variable to a file called
        # REVISION, in the base of the deployed revision. This file is used by
        # other tasks, to perform diffs and such.
        def deploy!
          write_previous_revision
          update_repository
          write_revision
        end

        # Performs a check on the remote hosts to determine whether everything
        # is setup such that a deploy could succeed.
        def check!
          # does not inherit any dependencies (super.check will inherit)
          Dependencies.new(configuration) do |d|
            d.remote.directory(configuration[:deploy_to]).or("`#{configuration[:deploy_to]}' does not exist.")
            d.remote.writable(configuration[:deploy_to], :via => :sudo).or("You do not have permissions to write to `#{configuration[:deploy_to]}'.")
            d.remote.command("svn")
            d.remote.match("cd #{repository_dir}; svn info|grep URL", configuration[:repository])
          end
        end

        # get lastest revision from remote server
        def last_revision
          get_revision('REVISION')
        end

        # get previously deployed revision from remote server
        def previous_revision
          get_revision('PREVIOUS_REVISION')
        end


        protected


          def get_revision(remote_file)
            out = ""
            last_revision_file = File.join(strategy.send(:repository_dir), remote_file)
            rev = nil
            run "if [ -e #{last_revision_file} ]; then cat #{last_revision_file}; else echo HEAD; fi" do |channel, stream, data|
              rev = data.chomp
            end
            rev
          end

          def get_repository
            command = "#{source.send(:scm, :info, repository_dir, source.send(:authentication))}|grep URL; true"
            out = nil
            run command do |channel, stream, data|
              out = data.chomp.gsub(/URL:\s*/, '')
            end
            unless out =~ /:\/\//
              logger.trace "wrong remote repository found: #{out}"
              out = nil
            end
            return out
          end
        
          def repository_dir
            File.join(configuration[:deploy_to], configuration[:application])
          end

          def update_repository
            logger.trace "updating the repository on all servers"
            _repository = get_repository
            logger.trace "remote repos: #{_repository}, given repos: #{repository}"
            # checkout
            if _repository.nil?
              scm_run("#{source.checkout(revision, repository_dir)}")
            # update, $ at the end because branches/frontend-category was matching branches/frontend
            elsif _repository.gsub(/\/$/,'').match(repository.gsub(/\/$/,'')+'$')
              scm_run("#{source.send(:scm, :cleanup, repository_dir)}; #{source.sync(revision, repository_dir)}")
            # switch
            else
              scm_run("#{source.send(:scm, :cleanup, repository_dir)}; #{source.send(:scm, :switch, repository, source.send(:authentication), source.send(:resolve_conflicts), repository_dir)}")
            end
          end

          def write_revision
            sudo("sh -c 'echo \"#{revision}\">#{repository_dir}/REVISION'")
          end

          def write_previous_revision
            sudo("sh -c 'if [ -e #{repository_dir}/REVISION ]; then cp #{repository_dir}/REVISION #{repository_dir}/PREVIOUS_REVISION; fi'")
          end
      end

    end
  end
end
