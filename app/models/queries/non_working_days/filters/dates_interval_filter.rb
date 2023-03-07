#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2023 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

class Queries::NonWorkingDays::Filters::DatesIntervalFilter < Queries::NonWorkingDays::Filters::NonWorkingDayFilter
  include Queries::Operators::DateRangeClauses

  def type
    :date
  end

  def self.key
    :date
  end

  def where
    lower_boundary, upper_boundary = values.map { |v| v.blank? ? nil : Date.parse(v) }
    lower_boundary ||= Date.current.beginning_of_year
    upper_boundary ||= Date.current.end_of_year

    <<-SQL.squish
      (#{date_range_clause('"non_working_days"', '"date"', lower_boundary, upper_boundary)})
    SQL
  end

  def type_strategy
    @type_strategy ||= Queries::Filters::Strategies::DateInterval.new(self)
  end

  def connection
    ActiveRecord::Base::connection
  end
end