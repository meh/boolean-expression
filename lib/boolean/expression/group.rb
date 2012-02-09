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

class Boolean::Expression::Group < Array
	def to_s
		'(' + map { |e| e.inspect }.join(' ') + ')'
	end

	alias inspect to_s
end
