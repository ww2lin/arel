module Arel
  module Visitors
    ###
    # This class produces SQL for JOIN clauses but omits the "single-source"
    # part of the Join grammar:
    #
    #   http://www.sqlite.org/syntaxdiagrams.html#join-source
    #
    # This visitor is used in SelectManager#join_sql and is for backwards
    # compatibility with Arel V1.0
    module JoinSql
      private

      def visit_Arel_Nodes_SelectCore o, collector
        o.source.right.map { |j| collector = visit j, collector }.join ' '
        return collector
	  end
    end
  end
end
