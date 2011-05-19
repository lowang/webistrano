require 'capistrano/recipes/deploy/scm/base'
module Capistrano
  module Deploy
    module SCM

      # Implements the Capistrano SCM interface for the Subversion revision
      # control system (http://subversion.tigris.org).
      class Subversion < Base

        # Returns the command that will do an "svn update" to the given
        # revision, for the working copy at the given destination.
        # Extended with resolve_conflicts parameter
        def sync(revision, destination)
          scm :update, verbose, authentication, resolve_conflicts, "-r#{revision}", destination
        end

        private

          # if scm_resolve_conflicts option is specified then use it
          def resolve_conflicts
            resolve_conflicts = variable(:scm_resolve_conflicts)
            return "" unless resolve_conflicts
            return "" unless ['postpone', 'base', 'mine-full', 'theirs-full', 'edit', 'launch'].include?(resolve_conflicts)
            force = variable(:scm_force) ? ' --force ' : ''
            result = "--accept #{resolve_conflicts} #{force}"
            result
          end
      end

    end
  end
end
