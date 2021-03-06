class Admin::StatsController < Admin::ApplicationController
  newrelic_ignore

  def index
    @recent_users = User.order('created_at DESC').limit(19)
    @recent_subscriptions = Subscription.where(repository_subscription_id: nil).order('created_at DESC').limit(7)
    @recent_watches = RepositorySubscription.order('created_at DESC').limit(7)

    @new_projects       = stats_for(Project)
    @new_versions       = stats_for(Version)
    @new_users          = stats_for(User)
    @new_subscriptions  = stats_for(Subscription)
    @new_repo_subs      = stats_for(RepositorySubscription)
    @new_web_hooks      = stats_for(WebHook)
  end

  def repositories
    @new_users          = stats_for(GithubUser)
    @new_manifests      = stats_for(Manifest)
    @new_readmes        = stats_for(Readme)
    @new_orgs           = stats_for(GithubOrganisation)
  end

  def overview

  end

  def graphs
    @platform = params[:platform] || 'Rubygems'
    @projects = Project.platform(@platform).where('projects.created_at > ?', 3.months.ago).group_by_day(:created_at).count
    @versions = Version.joins(:project).where('lower(projects.platform) = ?', @platform.downcase).where('versions.created_at > ?', 3.months.ago).group_by_day('versions.created_at').count
  end

  private

  def stats_for(klass)
    period = 3.days.ago.beginning_of_day
    klass.where('created_at > ?', period).group("date(created_at)").count.sort_by{|k,_v| k }.reverse
  end
end
