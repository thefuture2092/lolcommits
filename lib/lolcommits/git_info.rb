# -*- encoding : utf-8 -*-
module Lolcommits
  class GitInfo
    include Methadone::CLILogging
    attr_accessor :sha, :message, :repo_internal_path, :repo, :url,
                  :author_name, :author_email

    GIT_URL_REGEX = /.*[:]([\/\w\-]*).git/

    def initialize
      debug 'GitInfo: attempting to read local repository'
      g    = Mercurial::Repository.open('/Users/didia/Documents/workspace/eventbuck-fork')
      debug 'GitInfo: reading commits logs'
      commit = g.commits.all(:limit => 1).first
      debug "GitInfo: most recent commit is '#{commit}'"

      self.message = commit.message.split("\n").first
      self.sha     = commit.hash_id[0..10]
      self.repo_internal_path = g.path
      debug g.paths['default']
      if g.paths
        self.url = remote_https_url(g.paths['default'])
        match = self.url.match(GIT_URL_REGEX)
      end

      if match
        self.repo = match[1]
      elsif !g.path.empty?
        self.repo = g.path.split(File::SEPARATOR)[-2]
      end

      if commit.author
        self.author_name = commit.author
        self.author_email = commit.author_email
      end

      debug 'GitInfo: parsed the following values from commit:'
      debug "GitInfo: \t#{message}"
      debug "GitInfo: \t#{sha}"
      debug "GitInfo: \t#{repo_internal_path}"
      debug "GitInfo: \t#{repo}"
      debug "GitInfo: \t#{author_name}" if author_name
      debug "GitInfo: \t#{author_email}" if author_email
    end

    private

    def remote_https_url(url)
      url.gsub(':', '/').gsub(/^hg@/, 'https://').gsub(/\.hg$/, '') + '/commit/'
    end
  end
end

