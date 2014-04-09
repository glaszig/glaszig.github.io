# http://brizzled.clapper.org/blog/2012/03/05/using-twitter-bootstrap-with-jekyll/

# Where our Bootstrap source is installed. Can be overridden by an environment variable.
BOOTSTRAP_SOURCE = ENV['BOOTSTRAP_SOURCE'] || File.expand_path("./bootstrap")

# Where to find our custom LESS file.
BOOTSTRAP_CUSTOM_LESS = File.join %w{static style.less}
JS_PATH = File.join %w{static js bootstrap all.js}

task :default => :jekyll

# shamelessly stolen and modified from
# http://jonasforsberg.se/2012/12/28/create-jekyll-posts-from-the-command-line
task :post do
  title = ENV['title']
  date = Time.now.strftime '%Y-%m-%d'
  normalized = title.gsub(/\W+/, ' ').strip.gsub(/\W+/, '_')
  filename = "_posts/#{date}-#{normalized}.md"

  if File.exist? filename
    abort "#{filename} already exists!"
  end

  puts "Creating new post: #{filename}"
  File.open(filename, 'w') do |post|
    post.puts "---"
    post.puts "layout: blog_post"
    post.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
    post.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    post.puts "tags: []"
    post.puts "---"
  end
end

task :jekyll => :bootstrap do
  sh 'jekyll build'
end

task :bootstrap => [:bootstrap_js, :bootstrap_css]

task :bootstrap_css do |t|
  puts "Compiling #{BOOTSTRAP_CUSTOM_LESS}"
  include_path = File.join BOOTSTRAP_SOURCE, 'less'
  sh %{lessc -x --include-path="#{include_path}" #{BOOTSTRAP_CUSTOM_LESS} -x > static/style.css}
end

task :bootstrap_js do
  require 'uglifier'
  require 'erb'

  template = ERB.new %q[
  <!-- AUTOMATICALLY GENERATED. DO NOT EDIT. -->
  <% paths.each do |path| %>
  <script type="text/javascript" src="/<%= JS_PATH % { file: path } %>"></script>
  <% end %>
  ]

  paths = ['all.min.js']
  minifier = Uglifier.new
  target = JS_PATH
  Dir.glob(File.join(BOOTSTRAP_SOURCE, 'js', '*.js')).each do |source|
    # base = File.basename(source).sub(/^(.*)\.js$/, '\1.min.js')
    # paths << base
    # target = JS_PATH % { file: base }
    if different?(source, target)
      File.open(target, 'w') do |out|
        out.write minifier.compile(File.read(source))
      end
    end
  end

  File.open('_includes/bootstrap.js.html', 'w') do |f|
    f.write template.result(binding)
  end
end

def different?(path1, path2)
  require 'digest/md5'
  different = false
  if File.exist?(path1) && File.exist?(path2)
    path1_md5 = Digest::MD5.hexdigest(File.read path1)
    path2_md5 = Digest::MD5.hexdigest(File.read path2)
    (path2_md5 != path1_md5)
  else
    true
  end
end
