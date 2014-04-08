module Arel
  module Visitors
    class Dot < Arel::Visitors::Visitor
      class Node # :nodoc:
        attr_accessor :name, :id, :fields

        def initialize name, id, fields = []
          @name   = name
          @id     = id
          @fields = fields
        end
      end

      class Edge < Struct.new :name, :from, :to # :nodoc:
      end

      def initialize
        @nodes      = []
        @edges      = []
        @node_stack = []
        @edge_stack = []
        @seen       = {}
      end

      def accept object
        super
        to_dot
      end

      private
      def visit_Arel_Nodes_Ordering o, collector
        visit_edge o, collector, "expr"
      end

      def visit_Arel_Nodes_TableAlias o, collector
        collector = visit_edge o, collector, "name"
        visit_edge o, collector, "relation"
      end

      def visit_Arel_Nodes_Count o, collector
        collector = visit_edge o, collector, "expressions"
        visit_edge o, collector, "distinct"
      end

      def visit_Arel_Nodes_Values o, collector
        visit_edge o, collector, "expressions"
      end

      def visit_Arel_Nodes_StringJoin o, collector
        visit_edge o, collector, "left"
      end

      def visit_Arel_Nodes_InnerJoin o, collector
        collector = visit_edge o, collector, "left"
        visit_edge o, collector, "right"
      end
      alias :visit_Arel_Nodes_OuterJoin :visit_Arel_Nodes_InnerJoin

      def visit_Arel_Nodes_DeleteStatement o, collector
        collector = visit_edge o, collector, "relation"
        visit_edge o, collector, "wheres"
      end

      def unary o, collector
        visit_edge o, colelctor, "expr"
      end
      alias :visit_Arel_Nodes_Group             :unary
      alias :visit_Arel_Nodes_Grouping          :unary
      alias :visit_Arel_Nodes_Having            :unary
      alias :visit_Arel_Nodes_Limit             :unary
      alias :visit_Arel_Nodes_Not               :unary
      alias :visit_Arel_Nodes_Offset            :unary
      alias :visit_Arel_Nodes_On                :unary
      alias :visit_Arel_Nodes_Top               :unary
      alias :visit_Arel_Nodes_UnqualifiedColumn :unary
      alias :visit_Arel_Nodes_Preceding         :unary
      alias :visit_Arel_Nodes_Following         :unary
      alias :visit_Arel_Nodes_Rows              :unary
      alias :visit_Arel_Nodes_Range             :unary

      def window o, collector
        collector = visit_edge o, collector, "orders"
        visit_edge o, collector,  "framing"
      end
      alias :visit_Arel_Nodes_Window            :window

      def named_window o, collector
        collector = visit_edge o, collector, "orders"
        collector = visit_edge o, collector, "framing"
        visit_edge o, collector, "name"
      end
      alias :visit_Arel_Nodes_NamedWindow       :named_window

      def function o, collector
        collector = visit_edge o, collector, "expressions"
        collector = visit_edge o, collector, "distinct"
        visit_edge o, collector, "alias"
      end
      alias :visit_Arel_Nodes_Exists :function
      alias :visit_Arel_Nodes_Min    :function
      alias :visit_Arel_Nodes_Max    :function
      alias :visit_Arel_Nodes_Avg    :function
      alias :visit_Arel_Nodes_Sum    :function

      def extract o, collector
        collector = visit_edge o, collector, "expressions"
        visit_edge o, collector, "alias"
      end
      alias :visit_Arel_Nodes_Extract :extract

      def visit_Arel_Nodes_NamedFunction o, colector
        collector = visit_edge o, collector, "name"
       	collector = visit_edge o, collector, "expressions"
        collector = visit_edge o, collector, "distinct"
        visit_edge o, collector, "alias"
      end

      def visit_Arel_Nodes_InsertStatement o, collector,
        collector = visit_edge o, collector, "relation"
        collector = visit_edge o, collector, "columns"
        visit_edge o, collector, "values"
      end

      def visit_Arel_Nodes_SelectCore o, collector
        collector = visit_edge o, collector, "source"
        collector = visit_edge o, collector, "projections"
        collector = visit_edge o, collector, "wheres"
        visit_edge o, collector, "windows"
      end

      def visit_Arel_Nodes_SelectStatement o, collector
        collector = visit_edge o, collector, "cores"
        collector = visit_edge o, collector, "limit"
        collector = visit_edge o, collector, "orders"
        visit_edge o, collector, "offset"
      end

      def visit_Arel_Nodes_UpdateStatement o, collector
        collector = visit_edge o, collector, "relation"
        collector = visit_edge o, collector, "wheres"
        visit_edge o, collector, "values"
      end

      def visit_Arel_Table o, collector
        visit_edge o, collector, "name"
      end

      def visit_Arel_Attribute o, collector
        collector = visit_edge o, collector, "relation"
        visit_edge o, collector, "name"
      end
      alias :visit_Arel_Attributes_Integer :visit_Arel_Attribute
      alias :visit_Arel_Attributes_Float :visit_Arel_Attribute
      alias :visit_Arel_Attributes_String :visit_Arel_Attribute
      alias :visit_Arel_Attributes_Time :visit_Arel_Attribute
      alias :visit_Arel_Attributes_Boolean :visit_Arel_Attribute
      alias :visit_Arel_Attributes_Attribute :visit_Arel_Attribute

      def nary o, collector,
        o.children.each_with_index do |x,i|
          edge(i) { collector = visit x, collector }
        end
		return collector
      end
      alias :visit_Arel_Nodes_And :nary

      def binary o, collector
        collector = visit_edge o, collector, "left"
        visit_edge o, collector, "right"
      end
      alias :visit_Arel_Nodes_As                 :binary
      alias :visit_Arel_Nodes_Assignment         :binary
      alias :visit_Arel_Nodes_Between            :binary
      alias :visit_Arel_Nodes_DoesNotMatch       :binary
      alias :visit_Arel_Nodes_Equality           :binary
      alias :visit_Arel_Nodes_GreaterThan        :binary
      alias :visit_Arel_Nodes_GreaterThanOrEqual :binary
      alias :visit_Arel_Nodes_In                 :binary
      alias :visit_Arel_Nodes_JoinSource         :binary
      alias :visit_Arel_Nodes_LessThan           :binary
      alias :visit_Arel_Nodes_LessThanOrEqual    :binary
      alias :visit_Arel_Nodes_Matches            :binary
      alias :visit_Arel_Nodes_NotEqual           :binary
      alias :visit_Arel_Nodes_NotIn              :binary
      alias :visit_Arel_Nodes_Or                 :binary
      alias :visit_Arel_Nodes_Over               :binary

      def visit_String o, collector
        @node_stack.last.fields << o
      end
      alias :visit_Time :visit_String
      alias :visit_Date :visit_String
      alias :visit_DateTime :visit_String
      alias :visit_NilClass :visit_String
      alias :visit_TrueClass :visit_String
      alias :visit_FalseClass :visit_String
      alias :visit_Arel_Nodes_BindParam :visit_String
      alias :visit_Fixnum :visit_String
      alias :visit_BigDecimal :visit_String
      alias :visit_Float :visit_String
      alias :visit_Symbol :visit_String
      alias :visit_Arel_Nodes_SqlLiteral :visit_String

      def visit_Hash o, collector
        o.each_with_index do |pair, i|
          edge("pair_#{i}")   { collector =  visit pair, collector }
        end
		return collector 
      end

      def visit_Array o, collector
        o.each_with_index do |x,i|
          edge(i) { collector = visit x, collector }
        end
		return collector
      end

      def visit_edge o, collector, method
        edge(method) {  visit o.send(method), collector }
      end

      def visit o, collector
        if node = @seen[o.object_id]
          @edge_stack.last.to = node
          return
        end

        node = Node.new(o.class.name, o.object_id)
        @seen[node.id] = node
        @nodes << node
        with_node node do
          super
        end
      end

      def edge name
        edge = Edge.new(name, @node_stack.last)
        @edge_stack.push edge
        @edges << edge
        yield
        @edge_stack.pop
      end

      def with_node node
        if edge = @edge_stack.last
          edge.to = node
        end

        @node_stack.push node
        yield
        @node_stack.pop
      end

      def quote string
        string.to_s.gsub('"', '\"')
      end

      def to_dot
        "digraph \"Arel\" {\nnode [width=0.375,height=0.25,shape=record];\n" +
          @nodes.map { |node|
            label = "<f0>#{node.name}"

            node.fields.each_with_index do |field, i|
              label << "|<f#{i + 1}>#{quote field}"
            end

            "#{node.id} [label=\"#{label}\"];"
          }.join("\n") + "\n" + @edges.map { |edge|
            "#{edge.from.id} -> #{edge.to.id} [label=\"#{edge.name}\"];"
          }.join("\n") + "\n}"
      end
    end
  end
end
