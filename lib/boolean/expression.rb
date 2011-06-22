#--
# Copyleft meh. [http://meh.paranoid.pk | meh@paranoici.org]
#
# This file is part of boolean-expression.
#
# boolean-expression is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# boolean-expression is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with boolean-expression. If not, see <http://www.gnu.org/licenses/>.
#++

unless defined?(Boolean)
  class Boolean; end
end

class Boolean::Expression
  EvaluationError = Class.new(Exception)

  class << self
    def parse (text)
      base  = Group.new
      name  = nil
      stack = [base]
      logic = nil

      text.to_s.each_char.to_a.each_with_index {|char, index|
        begin
          if char == ')' && stack.length == 1
            raise SyntaxError.new('Closing an unopened parenthesis')
          end

          if char.match(/\s|\(|\)/) || (!logic && ['|', '&', '!'].member?(char))
            if logic || (name && name.match(/(and|or|not)/i))
              stack.last << Logic.new(logic || name)
              logic       = nil
              name        = nil
            elsif name
              stack.last << Name.new(name)
              name        = nil
            end
          end

          if name || logic
            name  << char if name
            logic << char if logic
          else
            case char
              when '('; stack.push Group.new
              when ')'; stack[-2] << stack.pop
              when '|'; logic = '|'
              when '&'; logic = '&'
              when '!'; stack.last << Logic.new('!')
              else;     name = char if !char.match(/\s/)
            end
          end
        rescue SyntaxError => e
          raise "#{e.message} near `#{text[index - 4, 8]}` at character #{index}"
        end
      }

      if stack.length != 1
        raise SyntaxError.new('Not all parenthesis are closed')
      end

      if logic
        raise SyntaxError.new('The expression cannot end with a logic operator')
      end

      base << Name.new(name) if name

      if base.length == 1 && base.first.is_a?(Group)
        base = base.first
      end

      self.new(base)
    end

    alias [] parse
  end

  attr_reader :base

  def initialize (base=Group.new)
    @base = base
  end

  def evaluate (*args)
    _evaluate(@base, args.flatten.compact.map {|piece|
      piece.to_s
    })
  end

  alias [] evaluate

  def to_s
    @base.inspect
  end

  private
    def _evaluate (group, pieces)
      return false if pieces.empty?

      values = []

      group.each {|thing|
        case thing
          when Logic; values << thing
          when Group; values << _evaluate(thing, pieces)
          when Name;  values << pieces.member?(thing.to_s)
        end
      }

      at = 0
      while at < values.length
        if values[at].is_a?(Logic) && values[at].type == :not
          values[at] = values.delete_at(at).evaluate(values[at])
          values[at] = !values[at]
        end 

        at += 1
      end 

      while values.length > 1
        a, logic, b = values.shift(3)

        values.unshift(logic.evaluate(a, b))
      end

      values.first
    end
end

require 'boolean/expression/name'
require 'boolean/expression/logic'
require 'boolean/expression/group'
