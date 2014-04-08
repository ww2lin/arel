module Arel
  module Visitors
    class OrderClauses < Arel::Visitors::ToSql
      private

      def visit_Arel_Nodes_SelectStatement o, collector
        o.orders.map { |x| collector = visit x, collector }
		    return collector
      end
    end
  end
end
