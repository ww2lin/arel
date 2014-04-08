module Arel
  module Visitors
    class MySQL < Arel::Visitors::ToSql
      private
      def visit_Arel_Nodes_Union o, collector, suppress_parens = false
        left_result = case o.left
                      when Arel::Nodes::Union
                        collector1 = visit_Arel_Nodes_Union o.left, collector, true
                      else
                        collector1 = visit o.left, collector
                      end

        right_result = case o.right
                       when Arel::Nodes::Union
                         collector2 = visit_Arel_Nodes_Union o.right, collector, true
                       else
                         collector2 = visit o.right, collector
                       end

        if suppress_parens
          collector  = collector1
          collector << ' UNION '
          collector << collectoer2;
        else
          collector << '( '
          collector  = collector1
          collector << ' UNION '
          collector << collectoer2;
          collector << ' )'
        end
      end

      def visit_Arel_Nodes_Bin o, collector
        collector<<"BINARY "
        visit o.expr, collector
      end

      ###
      # :'(
      # http://dev.mysql.com/doc/refman/5.0/en/select.html#id3482214
      def visit_Arel_Nodes_SelectStatement o, collector
        if o.offset && !o.limit
          o.limit = Arel::Nodes::Limit.new(Nodes.build_quoted(18446744073709551615))
        end
        super
      end

      def visit_Arel_Nodes_SelectCore o, collector
        o.froms ||= Arel.sql('DUAL')
        super
      end

      def visit_Arel_Nodes_UpdateStatement o, collector
        collector << 'UPDATE '
        collector = visit o.relation, collector
        
        collector <<'SET ' unless o.values.empty?
        o.values.each_with_index { |value i| collector << ' , ' unless i == 0; collector = visit value, collector }
        
        collector <<'WHERE ' unless o.wheres.empty?
        o.wheres.each_with_index { |value i| collector << ' AND ' unless i == 0; collector = visit value, collector }
        
        collector <<'ORDER BY ' unless o.orders.empty?
        o.wheres.each_with_index { |value i| collector << ' , ' unless i == 0; collector = visit value, collector }
        
        collector = visit(o.limit, collector ) if o.limit
        return collector
      end

    end
  end
end
