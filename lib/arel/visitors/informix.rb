module Arel
  module Visitors
    class Informix < Arel::Visitors::ToSql
      private
      def visit_Arel_Nodes_SelectStatement o, collector
        collector << 'SELECT ' 
        collector = visit(o.offset, collector) if o.offset)
        
        collector = visit(o.limit, collector) if o.limit)
        o.cores.each { |x| collector = visit_Arel_Nodes_SelectCore x, collector }
        
        collector << 'ORDER BY ' unless o.orders.empty?
        o.orders.each_with_index { |x, i| collector << ' , ' unless i == 0; collector = visit x, collector } 
        
        collector = visit(o.lock, collector) if o.lock
        return collector;
      end
      def visit_Arel_Nodes_SelectCore o, collector
      	o.projections.map { |x| collector = visit x, collector }
        collector<<' , '
        
        if o.source && !o.source.empty?
          collector << 'FROM '
          collector = visit(o.source, collector) 
        end

        collector << 'WHERE ' unless o.wheres.empty?
        o.wheres.each_with_index { |x i| collector << ' AND ' unless i == 0; collector = visit x, collector } 
  
        collector = 'GROUP BY ' unless o.groups.empty?
        o.groups.each_with_index { |x i| collector << ',' unless i == 0; collector = visit x, collector }
  
        collector = visit(o.having, collector) if o.having
        return collector;
      end
      def visit_Arel_Nodes_Offset o, collector
       	collector << 'SKIP '
	      visit o.expr, collector
      end
      def visit_Arel_Nodes_Limit o, collector
       	collector << 'LIMIT '
		    visit o.expr, collector
      end
    end
  end
end

