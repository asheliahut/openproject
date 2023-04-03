# -- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2010-2023 the OpenProject GmbH
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
# ++

# rubocop:disable Lint/SymbolConversion
#   because some of the json attributes are written in 'singleQuotes' instead of symbols
#   for better reading.

module API
  module V3
    module WorkPackages
      class WorkPackageDeletedRepresenter < ::API::Decorators::Single
        attr_accessor :timestamps, :query

        def initialize(model, current_user:, embed_links: false, timestamps: nil, query: nil)
          @query = query
          @timestamps = timestamps || query.try(:timestamps) || []

          super(model, current_user:, embed_links:)
        end

        def self_v3_path(*)
          api_v3_paths.work_package(represented.id, timestamps:)
        end

        self_link title_getter: ->(*) { nil }

        property :_meta,
                 if: ->(*) {
                   timestamps_active?
                 },
                 getter: ->(*) {
                   {
                     # This meta property states whether the work package exists at time.
                     # https://github.com/opf/openproject/pull/11783#issuecomment-1374897874
                     'exists': represented.exists_at_timestamp?,

                     # This meta property holds the timestamp of the data of the work package.
                     #
                     'timestamp': timestamps.last.to_s,

                     # This meta property states whether the attributes of the work package at the
                     # timestamp match the filters of the query.
                     # https://github.com/opf/openproject/pull/11783
                     'matchesFilters': represented.with_query? ? represented.matches_filters_at_timestamp? : nil
                   }.compact
                 },
                 uncacheable: true,
                 exec_context: :decorator

        property :id,
                 render_nil: true

        property :attributes_by_timestamp,
                 if: ->(*) {
                   timestamps_active?
                 },
                 getter: ->(*) do
                   represented.at_timestamps.map do |work_package_at_timestamp|
                     API::V3::WorkPackages::WorkPackageAtTimestampRepresenter
                       .create(work_package_at_timestamp,
                               current_user:)
                   end
                 end,
                 embedded: true,
                 uncacheable: true,
                 exec_context: :decorator

        def _type
          'WorkPackage'
        end

        def timestamps_active?
          timestamps.any?(&:historic?)
        end
      end
    end
  end
end

# rubocop:enable Lint/SymbolConversion
