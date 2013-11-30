require 'jekyll-less'

module Jekyll
  module Less
    class LessCssFile < Jekyll::StaticFile
      def less_config
        @site.config['less'] ||= {}
        @site.config['less']['paths'] ||= []
        @site.config['less']
      end

      def less options = {}
        options[:paths] = options[:paths] + Array(less_config['paths'])
        ::Less::Parser.new less_config.merge options
      end

      def write(dest)
        dest_path = destination(dest)

        return false if File.exist? dest_path and !modified?
        @@mtimes[path] = mtime

        FileUtils.mkdir_p(File.dirname(dest_path))
        begin
          content = less(:paths => [File.dirname(path)]).parse(File.read path).to_css
          File.open(dest_path, 'w') do |f|
            f.write(content)
          end
        rescue => e
          STDERR.puts "Less Exception: #{e.message}"
        end

        true
      end
    end
  end
end
