task :annotate_models do
  require 'annotate_models'
  AnnotateModels.do_annotations
end

task "db:migrate" do
  Rake::Task['annotate_models'].invoke
end

task "db:rollback" do
  Rake::Task['annotate_models'].invoke
end

task "db:create" do
  Rake::Task['annotate_models'].invoke
end