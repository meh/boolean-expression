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
	class << self
		def parse (text)
			base   = Group.new
			name   = nil
			stack  = [base]
			logic  = nil
			string = false
			quoted = false

			text.to_s.chars.each_with_index {|char, index|
				begin
					if !string && char == ')' && stack.length == 1
						raise SyntaxError, 'closing an unopened parenthesis'
					end

					if !string && (char.match(/\s|\(|\)/) || (!logic && ['|', '&', '!'].member?(char)))
						if logic || (name && name.match(/^(and|or|not)$/i) && !quoted)
							stack.last << Logic.new(logic || name)
							logic       = nil
							name        = nil
						elsif name
							stack.last << Name.new(name)
							name        = nil
							quoted      = false
						end
					end

					if name
						if char == '"'
							string = false
						else
							name << char
						end
					elsif logic
						logic << char
					else
						if char == '"'
							string = true
							quoted = true

							next
						end

						if string
							name = char unless name
						else
							case char
								when '(' then stack.push Group.new
								when ')' then stack[-2] << stack.pop
								when '|' then logic = '|'
								when '&' then logic = '&'
								when '!' then stack.last << Logic.new('!')
								else          name = char if !char.match(/\s/)
							end
						end
					end
				rescue SyntaxError => e
					raise "#{e.message} near `#{text[index - 4, 8]}` at character #{index}"
				end
			}

			raise SyntaxError, 'not all parenthesis are closed' if stack.length != 1
			
			raise SyntaxError, 'the expression cannot end with a logic operator' if logic

			base << Name.new(name) if name

			base = base.first if base.length == 1 && base.first.is_a?(Group)

			_check(base)

			new(base)
		end
		
		alias [] parse

	private
		def _check (group)
			if group.first.is_a?(Logic) && group.first.type != :not
				raise SyntaxError, "the expression cannot start with AND/OR: #{group}"
			end

			group.each_with_index {|piece, index|
				if piece.is_a?(Group)
					_check(piece)
				end

				next if index - 1 < 0

				if piece.is_a?(Logic) && piece.type == :not && !group[index - 1].is_a?(Logic)
					raise SyntaxError, "missing AND/OR before a NOT in: #{group}"
				end

				if (piece.is_a?(Name) || piece.is_a?(Group)) && !group[index - 1].is_a?(Logic)
					raise SyntaxError, "missing AND/OR in: #{group}"
				end
			}
		end
	end

	def initialize (base = Group.new)
		@base = base
	end

	def evaluate (*args)
		_evaluate(@base, args.flatten.compact.map {|piece|
			piece.to_s
		})
	end

	alias [] evaluate

	def names
		_names(@base).compact.uniq
	end

	def to_s
		@base.inspect
	end

	def to_group
		@base
	end

	def to_a
		@base.to_a
	end

private
	def _evaluate (group, pieces)
		return false if pieces.empty?

		values = []

		group.each {|thing|
			case thing
				when Logic then values << thing
				when Group then values << _evaluate(thing, pieces)
				when Name  then  values << pieces.member?(thing.to_s)
			end
		}

		at = 0
		while at < values.length
			if values[at].is_a?(Logic) && values[at].type == :not
				value = values.delete_at(at + 1)

				values[at] = !(value.is_a?(Group) ? value.evaluate(values[at]) : value)
			end

			at += 1
		end

		while values.length > 1
			a, logic, b = values.shift(3)

			values.unshift(logic.evaluate(a, b))
		end

		values.first
	end

	def _names (group, result = [])
		group.each {|piece|
			if piece.is_a?(Name)
				result.push(piece)
			elsif piece.is_a?(Group)
				_names(piece, result)
			end
		}

		result
	end
end

require 'boolean/expression/name'
require 'boolean/expression/logic'
require 'boolean/expression/group'
