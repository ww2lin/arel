module Arel
  module Visitors
    class Oracle < Arel::Visitors::ToSql
      private

      def visit_Arel_Nodes_SelectStatement o, collector
        o = order_hacks(o, collector)

        # if need to select first records without ORDER BY and GROUP BY and without DISTINCT
        # then can use simple ROWNUM in WHERE clause
        if o.limit && o.orders.empty? && !o.offset && o.cores.first.set_quantifier.class.to_s !~ /Distinct/
          o.cores.last.wheres.push Nodes::LessThanOrEqual.new(
            Nodes::SqlLiteral.new('ROWNUM'), o.limit.expr
          )
          return super
        end

        if o.limit && o.offset
          o        = o.dup
          limit    = o.limit.expr.to_i
          offset   = o.offset
          o.offset = nil
          sql = super(o)
          
          collector << "SELECT * FROM (
                        SELECT raw_sql_.*, rownum raw_rnum_
                        FROM (#{sql}) raw_sql_
                        WHERE rownum <= #{offset.expr.to_i + limit}
                        )
                        WHERE "
          visit offset collector
        end

        if o.limit
          o       = o.dup
          limit   = o.limit.expr
          collector << "SELECT * FROM (#{super(o)}) WHERE ROWNUM <= "
          visit limit, collector
        end

        if o.offset
          o        = o.dup
          offset   = o.offset
          o.offset = nil
          sql = super(o)
          
          collector << "SELECT * FROM (
                        SELECT raw_sql_.*, rownum raw_rnum_
                        FROM (#{sql}) raw_sql_
                        )
                        WHERE "
          visit offset collector
        end

        super
      end

      def visit_Arel_Nodes_Limit o, collector
      end

      def visit_Arel_Nodes_Offset o, collector
        collector << 'raw_rnum_ > '
        visit o.expr, collector
      end

      def visit_Arel_Nodes_Except o, collector
        collector = visit o.left collector
        collector << ' MINUS '
        visit o.right collector
      end

      def visit_Arel_Nodes_UpdateStatement o, collector
        # Oracle does not allow ORDER BY/LIMIT in UPDATEs.
        if o.orders.any? && o.limit.nil?
          # However, there is no harm in silently eating the ORDER BY clause if no LIMIT has been provided,
          # otherwise let the user deal with the error
          o = o.dup
          o.orders = []
        end

        super
      end

      ###
      # Hacks for the order clauses specific to Oracle
      def order_hacks o, collector
        return o if o.orders.empty?
        return o unless o.cores.any? do |core|
          core.projections.any? do |projection|
            /FIRST_VALUE/ === projection
          end
        end
        # Previous version with join and split broke ORDER BY clause
        # if it contained functions with several arguments (separated by ',').
        #
        # orders   = o.orders.map { |x| visit x }.join(', ').split(',')
        orders   = o.orders.map do |x|
          string = visit x, collector
          if string.include?(',')
            split_order_string(string)
          else
            string
          end
        end.flatten
        o.orders = []
        orders.each_with_index do |order, i|
          o.orders <<
            Nodes::SqlLiteral.new("alias_#{i}__#{' DESC' if /\bdesc$/i === order}")
        end
        o
      end

      # Split string by commas but count opening and closing brackets
      # and ignore commas inside brackets.
      def split_order_string(string)
        array = []
        i = 0
        string.split(',').each do |part|
          if array[i]
            array[i] << ',' << part
          else
            # to ensure that array[i] will be String and not Arel::Nodes::SqlLiteral
            array[i] = '' << part
          end
          i += 1 if array[i].count('(') == array[i].count(')')
        end
        array
      end

    end
  end
end
