require 'annotate/annotate_models'

 def annotate_models
   AnnotateModels.do_annotations(
    :position_in_class => 'before', 
    :position_in_fixture => 'before'
    )
 end

 namespace :db do
   task :migrate do
     annotate_models
   end

   namespace :migrate do
     [:up, :down, :reset, :redo].each do |t|
       task t do
         annotate_models
       end
     end
   end
 end
