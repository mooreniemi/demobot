desc "This task is called by the Heroku scheduler add-on to end sentences by their punishment definition."
task :review_sentences => :environment do
  bar = RakeProgressbar.new($unended_sentences)
  
  $unended_sentences.each do |s|
  	s.over if s.release_date_now?
  	bar.inc
  end

  bar.finished
end
