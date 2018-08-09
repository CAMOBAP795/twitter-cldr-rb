# encoding: UTF-8

# Copyright 2012 Twitter, Inc
# http://www.apache.org/licenses/LICENSE-2.0

require 'fileutils'
require 'open-uri'

module TwitterCldr
  module Resources
    class SegmentDictionariesImporter < Importer

      URL_TEMPLATE = "http://bugs.icu-project.org/trac/browser/tags/%{icu_version}/%{path}?format=txt"

      DICTIONARY_FILES = [
        'icu4c/source/data/brkitr/dictionaries/burmesedict.txt',
        'icu4c/source/data/brkitr/dictionaries/cjdict.txt',
        'icu4c/source/data/brkitr/dictionaries/khmerdict.txt',
        'icu4c/source/data/brkitr/dictionaries/laodict.txt',
        'icu4c/source/data/brkitr/dictionaries/thaidict.txt'
      ]

      output_path 'segmentation/dictionaries'
      ruby_engine :mri

      def execute
        DICTIONARY_FILES.each do |test_file|
          import_dictionary_file(test_file)
        end
      end

      private

      def import_dictionary_file(dictionary_file)
        source_url = url_for(dictionary_file)
        source = open(source_url).read
        lines = source.split("\n")
        trie = TwitterCldr::Utils::Trie.new
        space_regexp = TwitterCldr::Shared::UnicodeRegex.compile('\A[[:Z:][:C:]]+').to_regexp

        lines.each do |line|
          line.sub!(space_regexp, '')
          next if line.start_with?('#')

          characters, frequency = line.split("\t")
          frequency = frequency ? frequency.to_i : 0

          trie.add(characters.unpack('U*'), frequency)
        end

        output_path = output_path_for(dictionary_file)
        File.write(output_path, Marshal.dump(trie))
      end

      def url_for(dictionary_file)
        URL_TEMPLATE % {
          icu_version: "release-#{Versions.icu_version.gsub('.', '-')}",
          path: dictionary_file
        }
      end

      def output_path_for(dictionary_file)
        file = File.basename(dictionary_file).chomp(File.extname(dictionary_file))
        File.join(params.fetch(:output_path), "#{file}.dump")
      end

    end
  end
end
