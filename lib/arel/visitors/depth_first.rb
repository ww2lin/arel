module Arel
  module Visitors
    class DepthFirst < Arel::Visitors::Visitor
      def initialize block = nil
        @block = block || Proc.new
      end

      private

      def visit o, collector
        super
        @block.call o, collector
      end

      def unary o, collector
        visit o.expr, collector
      end
      alias :visit_Arel_Nodes_Group             :unary
      alias :visit_Arel_Nodes_Grouping          :unary
      alias :visit_Arel_Nodes_Having            :unary
      alias :visit_Arel_Nodes_Limit             :unary
      alias :visit_Arel_Nodes_Not               :unary
      alias :visit_Arel_Nodes_Offset            :unary
      alias :visit_Arel_Nodes_On                :unary
      alias :visit_Arel_Nodes_Ordering          :unary
      alias :visit_Arel_Nodes_Ascending         :unary
      alias :visit_Arel_Nodes_Descending        :unary
      alias :visit_Arel_Nodes_Top               :unary
      alias :visit_Arel_Nodes_UnqualifiedColumn :unary

      def function o, collector,
        collector = visit o.expressions, collector
        collector = visit o.alias, collector
        visit o.distinct, collector
      end
      alias :visit_Arel_Nodes_Avg    :function
      alias :visit_Arel_Nodes_Exists :function
      alias :visit_Arel_Nodes_Max    :function
      alias :visit_Arel_Nodes_Min    :function
      alias :visit_Arel_Nodes_Sum    :function

      def visit_Arel_Nodes_NamedFunction o, collector
        collector = visit o.name, collector
        collector = visit o.expressions, collector
        collector = visit o.distinct, collector
        visit o.alias, collector
      end

      def visit_Arel_Nodes_Count o, collector
        collector = visit o.expressions, collector
        collector = visit o.alias, collector
        visit o.distinct, collector
      end

      def nary o, collector
        o.children.each { |child| visit child, collector}
      end
      alias :visit_Arel_Nodes_And :nary

      def binary o, collector
        collector = visit o.left, collector
        visit o.right, collector
      end
      alias :visit_Arel_Nodes_As                 :binary
      alias :visit_Arel_Nodes_Assignment         :binary
      alias :visit_Arel_Nodes_Between            :binary
      alias :visit_Arel_Nodes_DeleteStatement    :binary
      alias :visit_Arel_Nodes_DoesNotMatch       :binary
      alias :visit_Arel_Nodes_Equality           :binary
      alias :visit_Arel_Nodes_GreaterThan        :binary
      alias :visit_Arel_Nodes_GreaterThanOrEqual :binary
      alias :visit_Arel_Nodes_In                 :binary
      alias :visit_Arel_Nodes_InfixOperation     :binary
      alias :visit_Arel_Nodes_JoinSource         :binary
      alias :visit_Arel_Nodes_InnerJoin          :binary
      alias :visit_Arel_Nodes_LessThan           :binary
      alias :visit_Arel_Nodes_LessThanOrEqual    :binary
      alias :visit_Arel_Nodes_Matches            :binary
      alias :visit_Arel_Nodes_NotEqual           :binary
      alias :visit_Arel_Nodes_NotIn              :binary
      alias :visit_Arel_Nodes_Or                 :binary
      alias :visit_Arel_Nodes_OuterJoin          :binary
      alias :visit_Arel_Nodes_TableAlias         :binary
      alias :visit_Arel_Nodes_Values             :binary

      def visit_Arel_Nodes_StringJoin o, collector
        visit o.left, collector
      end

      def visit_Arel_Attribute o, collector
        collector = visit o.relation, collector
        visit o.name, collector
      end
      alias :visit_Arel_Attributes_Integer :visit_Arel_Attribute
      alias :visit_Arel_Attributes_Float :visit_Arel_Attribute
      alias :visit_Arel_Attributes_String :visit_Arel_Attribute
      alias :visit_Arel_Attributes_Time :visit_Arel_Attribute
      alias :visit_Arel_Attributes_Boolean :visit_Arel_Attribute
      alias :visit_Arel_Attributes_Attribute :visit_Arel_Attribute
      alias :visit_Arel_Attributes_Decimal :visit_Arel_Attribute

      def visit_Arel_Table o, collector
        visit o.name, collector
      end

      def terminal o, collector
      end
      alias :visit_ActiveSupport_Multibyte_Chars :terminal
      alias :visit_ActiveSupport_StringInquirer  :terminal
      alias :visit_Arel_Nodes_Lock               :terminal
      alias :visit_Arel_Nodes_Node               :terminal
      alias :visit_Arel_Nodes_SqlLiteral         :terminal
      alias :visit_Arel_Nodes_BindParam          :terminal
      alias :visit_Arel_Nodes_Window             :terminal
      alias :visit_BigDecimal                    :terminal
      alias :visit_Bignum                        :terminal
      alias :visit_Class                         :terminal
      alias :visit_Date                          :terminal
      alias :visit_DateTime                      :terminal
      alias :visit_FalseClass                    :terminal
      alias :visit_Fixnum                        :terminal
      alias :visit_Float                         :terminal
      alias :visit_NilClass                      :terminal
      alias :visit_String                        :terminal
      alias :visit_Symbol                        :terminal
      alias :visit_Time                          :terminal
      alias :visit_TrueClass                     :terminal

      def visit_Arel_Nodes_InsertStatement o, collector
        collector = visit o.relation, collector
        collector = visit o.columns, collector
        visit o.values, collector
      end

      def visit_Arel_Nodes_SelectCore o, collector
        collector = visit o.projections, collector
        collector = visit o.source, collector
        collector = visit o.wheres, collector
        collector = visit o.groups, collector
        collector = visit o.windows, collector
        visit o.having, collector
      end

      def visit_Arel_Nodes_SelectStatement o, collector
        collector = visit o.cores, collector
        collector = visit o.orders, collector
        collector = visit o.limit, collector
        collector = visit o.lock, collector
        visit o.offset, collector
      end

      def visit_Arel_Nodes_UpdateStatement o, collector
        collector = visit o.relation, collector
        collector = visit o.values, collector
        collector = visit o.wheres, collector
        collector = visit o.orders, collector
        visit o.limit, collector
      end

      def visit_Array o, collector
        o.each { |i| collector = visit i , collector}
		return collector
      end

      def visit_Hash o, collector
        o.each { |k,v| collector = visit(k, collector); 
					   collector = visit(v, collector) }
		return collector
      end
    end
  end
end
