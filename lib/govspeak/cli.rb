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
      default_command(:convert)
      command(:convert) do |command|
        command.syntax = "govspeak convert [options] <input>"
        command.description = "Convert Govspeak into HTML, can be sourced from stdin, as an argument or from a file"
        command.option("--file FILENAME", String, "File to convert")
        command.action do |args, options|
          input = get_input($stdin, args, options)
          raise "Nothing to convert. Use --help for assistance" unless input
          puts Govspeak::Document.new(input).to_html
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
  end
end
