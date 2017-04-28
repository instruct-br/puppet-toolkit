require 'English'
require 'reek'
require 'rubocop/rake_task'
require 'yamllint/rake_task'

YamlLint::RakeTask.new do |t|
  t.paths = %w[
    environment.yaml
    .rubocop.yml
    .travis.yml
  ]
end

desc 'Reek code smells'
task :reek do
  reporter = Reek::Report::TextReport.new
  vagrantfile_examiner = Reek::Examiner.new File.open('Vagrantfile')
  rakefile_examiner = Reek::Examiner.new File.open('Rakefile')
  reporter.add_examiner vagrantfile_examiner
  reporter.add_examiner rakefile_examiner
  if reporter.smells?
    reporter.show
    raise 'Smell violations found using Reek'
  end
end

RuboCop::RakeTask.new

desc 'Validate shell script installer'
task :shellcheck do
  system('shellcheck puppet-agent-installer.sh')
  raise 'Violations found using ShellCheck' unless $CHILD_STATUS.success?
end
