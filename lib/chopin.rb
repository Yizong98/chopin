require 'chopin/namespace'
require 'chopin/pygments_renderer'
require 'erb'
require 'fileutils'
require 'redcarpet'
require 'sass'

module Chopin
  def self.copy(source, dest_root, layout = nil)
    @root = source unless @root

    if File.directory?(source)
      destination = "#{dest_root}/#{File.basename(source).sub(@root, '')}".chomp('/')

      unless Dir.exists?(destination)
        Dir.mkdir(destination)
        puts " #{GREEN}Create#{WHITE} #{destination}"
      end

      layout = "#{source}/layout.erb" if File.exist?("#{source}/layout.erb")

      Dir.new(source).each do |file|
        next if file == '.' || file == '..'

        if file[0] == '.'
          puts " #{RED}Ignore#{WHITE} #{source}/#{file}"
          next
        end

        copy("#{source}/#{file}", destination, layout)
      end
    else
      case File.extname(source)
        when '.erb'
          process_erb(source, dest_root, layout) unless File.basename(source, '.erb') == 'layout'

        when '.md'
          process_markdown(source, dest_root, layout)

        when '.sass'
          process_sass(source, dest_root, :sass) unless File.basename(source)[0] == '_'

        when '.scss'
          process_sass(source, dest_root, :scss) unless File.basename(source)[0] == '_'

        else
          puts " #{BLUE}Copy#{WHITE} #{source} -> #{destination}"
          FileUtils.cp(source, dest_root)
      end
    end
  end

  private

  def self.get_page_name(file_name)
    File.dirname(file_name).sub(@root, '').split('/')
      .reject { |dir| dir == ''}
      .push(File.basename(file_name, File.extname(file_name)))
      .join('-')
  end

  def self.process_erb(source, dest_dir, layout)
    base_name = File.basename(source, '.erb')
    destination = "#{dest_dir}/#{base_name}.html"

    if layout == nil
      puts " #{PURPLE}Parse#{WHITE} #{source} -> #{destination}"

      File.new(destination, 'w').write(
        ERB.new(File.read(source)).result(Namespace.new({
          page_name: get_page_name(source)
        }).get_binding)
      )
    else
      puts " #{PURPLE}Parse#{WHITE} #{source} (into #{layout}) -> #{destination}"

      render_template(destination, layout, Namespace.new({
        page_name: get_page_name(source),
        content: ERB.new(File.read(source)).result
      }))
    end
  end

  def self.process_markdown(source, dest_dir, layout)
    base_name = File.basename(source, '.md')
    destination = "#{dest_dir}/#{base_name}.html"
    puts " #{PURPLE}Parse#{WHITE} #{source} (into #{layout}) -> #{destination}"

    render_template(destination, layout, Namespace.new({
      page_name: get_page_name(source),
      content: MD.render(File.new(source).read)
    }))
  end

  def self.process_sass(source, dest_dir, type)
    base_name = File.basename(source, File.extname(source))
    destination = "#{dest_dir}/#{base_name}.css"
    puts " #{CYAN}Convert#{WHITE} #{source} -> #{destination}"

    File.new(destination, 'w').write(
      Sass::Engine.new(File.new(source).read,
        load_paths: [File.dirname(source)],
        syntax: type
      ).render
    )
  end

  def self.render_template(destination, layout, namespace)
    File.new(destination, 'w').write(
      ERB.new(File.read(layout)).result(namespace.get_binding)
    )
  end

  BLUE = "\033[0;34m"
  CYAN = "\033[0;36m"
  GREEN = "\033[0;32m"
  PURPLE = "\033[0;35m"
  RED = "\033[0;31m"
  WHITE = "\033[0m"

  MD = Redcarpet::Markdown.new(PygmentsRenderer,
    disable_indented_code_blocks: true,
    fenced_code_blocks: true,
    footnotes: true,
    no_intra_emphasis: true,
    prettify: true,
    quote: true,
    tables: true
  )
end
