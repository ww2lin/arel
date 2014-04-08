module Arel
  module Visitors
    class WhereSql < Arel::Visitors::ToSql
      def visit_Arel_Nodes_SelectCore o, collector
        collector << 'WHERE '
        o.wheres.each_with_index { |x i| collector << ' AND ' unless i == 0; collector = visit x, collector}
        return collector
      end
    end
  end
end
