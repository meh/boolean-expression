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

class Boolean::Expression::Logic
	attr_reader :type

	def initialize (what)
		@type = case what
			when '!',  /not/i then :not
			when '&&', /and/i then :and
			when '||', /or/i  then :or
			else raise SyntaxError, 'invalid logical operator, logical fallacies everywhere'
		end
	end

	def evaluate (a, b=nil)
		case @type
			when :not then !a
			when :and then !!(a && b)
			when :or  then !!(a || b)
		end
	end

	def inspect
		type.to_s.upcase
	end
end
