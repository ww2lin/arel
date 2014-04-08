module Arel
  module Visitors
    class PostgreSQL < Arel::Visitors::ToSql
      private

      def visit_Arel_Nodes_Matches o, collector
       	collector = visit o.left collector 
		    collector << " ILIKE "
		    visit o.right
      end

      def visit_Arel_Nodes_DoesNotMatch o, collector
	      collector = visit o.left collector
	      collector = " NOT ILIKE "
	      visit o.right collector
      end

      def visit_Arel_Nodes_DistinctOn o, collector
	      collector = "DISTICT ON ( "
		    collector << visit o.expr collector
		    collector <<" )"
      end
    end
  end
end
