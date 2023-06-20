# shamelessly stolen and modified from
# http://jonasforsberg.se/2012/12/28/create-jekyll-posts-from-the-command-line
task :post do
  title = ENV['title']
  date = Time.now.strftime '%Y-%m-%d'
  slug = title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
  filename = "_posts/#{date}-#{slug}.md"

  if File.exist? filename
    abort "#{filename} already exists!"
  end

  puts "Creating new post: #{filename}"
  File.open(filename, 'w') do |post|
    post.puts "---"
    post.puts "layout: blog_post"
    post.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
    post.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M:%S %z')}"
    post.puts "tags: []"
    post.puts "---"
  end
end

task :gh_contribs do
  system "git submodule update --init"
  Dir.chdir "Github-contributions" do
    system "virtualenv -- venv"
    system "source venv/bin/activate"
    system "pip install -r requirements.txt"
    system "./generate_markdown.py -r glaszig"
  end
  system "cp Github-contributions/output/contribution-list.md _includes/github_contributions.md"
end
