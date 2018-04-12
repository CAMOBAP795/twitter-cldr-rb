# encoding: UTF-8

# Copyright 2012 Twitter, Inc
# http://www.apache.org/licenses/LICENSE-2.0

require 'singleton'

module TwitterCldr
  module Segmentation
    class LaoBreakEngine

      include Singleton

      def each_boundary(*args, &block)
        engine.each_boundary(*args, &block)
      end

      private

      def engine
        @engine ||= BrahmicBreakEngine.new(
          lookahead: 3,
          root_combine_threshold: 3,
          prefix_combine_threshold: 3,
          min_word: 2,
          word_set: lao_word_set,
          mark_set: mark_set,
          end_word_set: end_word_set,
          begin_word_set: begin_word_set,
          dictionary: Dictionary.lao,
          advance_past_suffix: -> (*) do
            0  # not applicable to Lao
          end
        )
      end

      private

      def lao_word_set
        @lao_word_set ||= TwitterCldr::Shared::UnicodeSet.new.tap do |set|
          set.apply_pattern('[[:Laoo:]&[:Line_Break=SA:]]')
        end
      end

      def mark_set
        @mark_set ||= TwitterCldr::Shared::UnicodeSet.new.tap do |set|
          set.apply_pattern('[[:Laoo:]&[:Line_Break=SA:]&[:M:]]')
          set.add(0x0020)
        end
      end

      def end_word_set
        @end_word_set ||= TwitterCldr::Shared::UnicodeSet.new.tap do |set|
          set.add_set(lao_word_set)
          set.subtract_range(0x0EC0..0x0EC4) # prefix vowels
        end
      end

      def begin_word_set
        @begin_word_set ||= TwitterCldr::Shared::UnicodeSet.new.tap do |set|
          set.add_range(0x0E81..0x0EAE)  # basic consonants (including holes for corresponding Thai characters)
          set.add_range(0x0EDC..0x0EDD)  # digraph consonants (no Thai equivalent)
          set.add_range(0x0EC0..0x0EC4)  # prefix vowels
        end
      end

    end
  end
end
