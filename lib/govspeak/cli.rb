require 'govspeak/version'
require 'govspeak'
require 'commander'

module Govspeak
  class CLI
    include Commander::Methods

    def run
      program(:name, 'Govspeak')
      program(:version, Govspeak::VERSION)
      program(:description, "A tool for rendering the GOV.UK dialect of markdown into HTML")
      default_command(:render)
      command(:render) do |command|
        command.syntax = "govspeak render [options] <input>"
        command.description = "Render Govspeak into HTML, can be sourced from stdin, as an argument or from a file"
        command.option("--file FILENAME", String, "File to render")
        command.option("--options JSON", String, "JSON to use as options")
        command.option("--options-file FILENAME", String, "A file of JSON options")
        command.action do |args, options|
          input = get_input($stdin, args, options)
          raise "Nothing to render. Use --help for assistance" unless input

          puts Govspeak::Document.new(input, govspeak_options(options)).to_html
        end
      end
      run!
    end

  private

    def get_input(stdin, args, options)
      return stdin.read unless stdin.tty?
      return read_file(options.file) if options.file

      args.empty? ? nil : args.join(" ")
    end

    def read_file(file_path)
      path = Pathname.new(file_path).realpath
      File.read(path)
    end

    def govspeak_options(command_options)
      string = if command_options.options_file
                 read_file(command_options.options_file)
               else
                 command_options.options
               end
      string ? JSON.parse(string) : {}
    end
  end
end
