# frozen_string_literal: true

# rubocop:disable Gitlab/StrongMemoizeAttr
module Ci
  module Deployable
    extend ActiveSupport::Concern

    included do
      prepend_mod_with('Ci::Deployable') # rubocop: disable Cop/InjectEnterpriseEditionModule

      has_one :deployment, as: :deployable, class_name: 'Deployment', inverse_of: :deployable

      state_machine :status do
        after_transition any => [:success] do |job|
          job.run_after_commit do
            Environments::StopJobSuccessWorker.perform_async(id)
          end
        end

        # Synchronize Deployment Status
        # Please note that the data integirty is not assured because we can't use
        # a database transaction due to DB decomposition.
        after_transition do |job, transition|
          next if transition.loopback?
          next unless job.project

          job.run_after_commit do
            job.deployment&.sync_status_with(job)
          end
        end
      end
    end

    def outdated_deployment?
      strong_memoize(:outdated_deployment) do
        deployment_job? &&
          project.ci_forward_deployment_enabled? &&
          (!project.ci_forward_deployment_rollback_allowed? || incomplete?) &&
          deployment&.older_than_last_successful_deployment?
      end
    end

    # Virtual deployment status depending on the environment status.
    def deployment_status
      return unless deployment_job?

      if success?
        return successful_deployment_status
      elsif failed?
        return :failed
      end

      :creating
    end

    def successful_deployment_status
      if deployment&.last?
        :last
      else
        :out_of_date
      end
    end

    def persisted_environment
      return unless has_environment_keyword?

      strong_memoize(:persisted_environment) do
        # This code path has caused N+1s in the past, since environments are only indirectly
        # associated to builds and pipelines; see https://gitlab.com/gitlab-org/gitlab/-/issues/326445
        # We therefore batch-load them to prevent dormant N+1s until we found a proper solution.
        BatchLoader.for(expanded_environment_name).batch(key: project_id) do |names, loader, args|
          Environment.where(name: names, project: args[:key]).find_each do |environment|
            loader.call(environment.name, environment)
          end
        end
      end
    end

    def persisted_environment=(environment)
      strong_memoize(:persisted_environment) { environment }
    end

    # If build.persisted_environment is a BatchLoader, we need to remove
    # the method proxy in order to clone into new item here
    # https://github.com/exAspArk/batch-loader/issues/31
    def actual_persisted_environment
      persisted_environment.respond_to?(:__sync) ? persisted_environment.__sync : persisted_environment
    end

    def expanded_environment_name
      return unless has_environment_keyword?

      strong_memoize(:expanded_environment_name) do
        # We're using a persisted expanded environment name in order to avoid
        # variable expansion per request.
        if metadata&.expanded_environment_name.present?
          metadata.expanded_environment_name
        else
          ExpandVariables.expand(environment, -> { simple_variables.sort_and_expand_all })
        end
      end
    end

    def expanded_kubernetes_namespace
      return unless has_environment_keyword?

      namespace = options.dig(:environment, :kubernetes, :namespace)

      if namespace.present? # rubocop:disable Style/GuardClause
        strong_memoize(:expanded_kubernetes_namespace) do
          ExpandVariables.expand(namespace, -> { simple_variables })
        end
      end
    end

    def has_environment_keyword?
      environment.present?
    end

    def deployment_job?
      has_environment_keyword? && environment_action == 'start'
    end

    def stops_environment?
      has_environment_keyword? && environment_action == 'stop'
    end

    def environment_action
      options.fetch(:environment, {}).fetch(:action, 'start') if options
    end

    def environment_tier_from_options
      options.dig(:environment, :deployment_tier) if options
    end

    def environment_tier
      environment_tier_from_options || persisted_environment.try(:tier)
    end

    def environment_url
      options&.dig(:environment, :url) || persisted_environment.try(:external_url)
    end

    def environment_slug
      persisted_environment.try(:slug)
    end

    def environment_status
      strong_memoize(:environment_status) do
        if has_environment_keyword? && merge_request
          EnvironmentStatus.new(project, persisted_environment, merge_request, pipeline.sha)
        end
      end
    end

    def on_stop
      options&.dig(:environment, :on_stop)
    end

    def stop_action_successful?
      success?
    end
  end
end
# rubocop:enable Gitlab/StrongMemoizeAttr
