task :annotate_models do
  if RAILS_ENV == 'development' then
    require 'annotate_models'
    AnnotateModels.do_annotations
  end
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
